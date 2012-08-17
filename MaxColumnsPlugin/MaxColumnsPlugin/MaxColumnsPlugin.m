//
//  MaxColumnsPlugin.m
//  MaxColumnsPlugin
//
//  Created by Guillaume Algis on 16/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <objc/runtime.h>
#import <objc/message.h>

#import "MaxColumnsPlugin.h"
#import "NSString+SSToolkitAdditions.h"
#import "NSString+MCWrap.h"

NSBundle *GMGetMaxColumnsBundle(void) 
{
	return [NSBundle bundleForClass:[MCMaxColumnsPlugin class]];
}

#define DEFAULT_MAX_COLUMNS 80
static int maxColumns = DEFAULT_MAX_COLUMNS; // Is overrided at initialize time by Info.plist (MCMaxColumnsWrap)

@implementation MCMaxColumnsPlugin

+ (void) initialize 
{
	[super initialize];
    
	//We attempt to get a reference to the MVMailBundle class so we can swap superclasses, failing that 
	//we disable ourselves and are done since this is an undefined state
	Class mvMailBundleClass = NSClassFromString(@"MVMailBundle");
	if(!mvMailBundleClass)
    {
		NSLog(@"[ERR]  Mail.app does not have a MVMailBundle class available");
        exit(1);
    }
	else
	{
		class_setSuperclass([self class], mvMailBundleClass);
        
		[MCMaxColumnsPlugin registerBundle];
        
        maxColumns = [(NSNumber *)[GMGetMaxColumnsBundle() objectForInfoDictionaryKey:@"MCMaxColumnsWrap"] intValue];
        maxColumns = maxColumns > 1 ? maxColumns : DEFAULT_MAX_COLUMNS;
        
		NSLog(@"[INFO] Loaded MaxColumnsPlugin %@", [GMGetMaxColumnsBundle() objectForInfoDictionaryKey:@"CFBundleShortVersionString"]);
        
        if ([MCMaxColumnsPlugin overrideSendMethod]) {
            NSLog(@"[INFO] MaxColumnsPlugin successfully overrided send: method");
        }
        else {
            NSLog(@"[ERR]  MaxColumnsPlugin could not override send: method");
        }
    }
}

+ (void)registerBundle 
{
    if(class_getClassMethod(NSClassFromString(@"MVMailBundle"), @selector(registerBundle)))
        [NSClassFromString(@"MVMailBundle") performSelector:@selector(registerBundle)];
}

+ (BOOL)overrideSendMethod
{
    IMP sendWithWrapImp = nil;
    Method sendWithWrapMethod = nil;
    
    Method originalSendMethod = nil;
    Method newSendMethod = nil;
    Class mailDocumentEditorClass = NSClassFromString(@"MailDocumentEditor");
    
    // Check if we found the class
    if(!mailDocumentEditorClass)
    {
		NSLog(@"[ERR]  Could not find the MailDocumentEditor class");
        return NO;
    }
    
    // First we add a new sendWithWrap method to the Mail.app MailDocumentEditor class
    sendWithWrapMethod = class_getInstanceMethod([self class], @selector(sendWithWrap:));
    sendWithWrapImp = class_getMethodImplementation([self class], @selector(sendWithWrap:));
    BOOL methodAdded = class_addMethod(mailDocumentEditorClass,
                                       @selector(sendWithWrap:),
                                       sendWithWrapImp,
                                       method_getTypeEncoding(sendWithWrapMethod));

    if(!methodAdded)
    {
		NSLog(@"[ERR]  Could not add the sendWithWrap method to the MailDocumentEditor class");
        return NO;
    }
    
    // We take the two methods (the original send: and the freshly added sendWithWrap:)
    originalSendMethod = class_getInstanceMethod(mailDocumentEditorClass, @selector(send:));
    if (originalSendMethod == nil)
    {
      	NSLog(@"[ERR]  Could not find the send: method of MailDocumentEditor");
        return NO;
    }
    
    newSendMethod = class_getInstanceMethod(mailDocumentEditorClass, @selector(sendWithWrap:));
    if (newSendMethod == nil)
    {
      	NSLog(@"[ERR]  Could not find the sendWithWrap: method of MailDocumentEditor");
        return NO;
    }
    
    // And swap their implementation
    method_exchangeImplementations(originalSendMethod, newSendMethod);
    
    return YES;
}

- (void)sendWithWrap:(id)sender
{
    // We go through the objects members to find our message
    id document = objc_msgSend(self, @selector(document));
    id htmlDocument = objc_msgSend(document, @selector(htmlDocument));
    id body = objc_msgSend(htmlDocument, @selector(body));
    NSString *innerText = (NSString *)objc_msgSend(body, @selector(innerText));
    
    // Detecting if the message is plain text
    // Note: This rely on the class="ApplePlainTextBody" attribute of the <body> elemement
    //       I don't think this is the safest way to do this
    NSString *bodyClassName = objc_msgSend(body, @selector(className));
    NSRange range = [bodyClassName rangeOfString:@"ApplePlainTextBody" options:NSCaseInsensitiveSearch];
    if(range.location == NSNotFound) {
        // Not plain text, we just send the message
        [self sendWithWrap:sender];
        return;
    }

    // We wrap all lines to maxColumns
    NSArray *chunks = [innerText componentsSeparatedByString: @"\n"];
    NSMutableArray *mutableChunks = [NSMutableArray arrayWithCapacity:[chunks count]];
    [mutableChunks setArray:chunks];
    
    for (int i = 0; i < [mutableChunks count]; ++i) {
        NSString *line = [mutableChunks objectAtIndex:i];
        line = [[line stringByTrimmingTrailingWhitespaceAndNewlineCharacters]
                stringByWrappingToMaxColumns:maxColumns];
        [mutableChunks replaceObjectAtIndex:i withObject:line];
    }
    
    innerText = [mutableChunks componentsJoinedByString:@"\n"];
    
    // And replace the message body with our wrapped one
    objc_msgSend(body, @selector(setInnerText:), innerText);
    
    // Finally, we call the default send: method (which is now sendWithWrap:)
    [self sendWithWrap:sender];
}



// Used for debug

//#define logVar(x) (NSLog( @"DUMP :: Value of %s = %@",#x, x))
//
//+ (void) dumpObj:(id)obj
//{
//    NSLog(@"==================================");
//    logVar(obj);
//    
//    id inst = obj;
//    int unsigned numMethods;
//    Method *methods = class_copyMethodList(object_getClass(inst), &numMethods);
//    NSLog(@"%u Methods", numMethods);
//    for (int i = 0; i < numMethods; i++) {
//        NSLog(@"%d : %@", i, NSStringFromSelector(method_getName(methods[i])));
//    }
//    
//    NSLog(@"            ###              ");
//    
//    int unsigned numProp;
//    objc_property_t *props = class_copyPropertyList(object_getClass(inst), &numProp);
//    NSLog(@"%u Properties", numProp);
//    for (int i = 0; i < numProp; i++) {
//        NSLog(@"%d : %s = %s", i, property_getName(props[i]), property_getAttributes(props[i]));
//    }
//    NSLog(@"++++++++++++++++++++++++++++++++++");
//}

@end
