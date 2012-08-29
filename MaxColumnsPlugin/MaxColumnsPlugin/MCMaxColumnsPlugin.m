//
//  MaxColumnsPlugin.m
//  MaxColumnsPlugin
//
//  Created by Guillaume Algis on 16/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <objc/runtime.h>

#import "MCMaxColumnsPlugin.h"
#import "MCExtendedMailDocumentEditor.h"

#define DEFAULT_MAX_COLUMNS 77

@implementation MCMaxColumnsPlugin

#pragma mark - Properties

@synthesize maxColumns = _maxColumns;
@synthesize textWrapperInst = _textWrapperInst;

#pragma mark - MVMailBundle methods overriding

+ (void) initialize 
{
	[super initialize];
    
    NSDate *initStart = [NSDate date];
    
	//We attempt to get a reference to the MVMailBundle class so we can swap superclasses, failing that 
	//we disable ourselves and are done since this is an undefined state
	Class mvMailBundleClass = NSClassFromString(@"MVMailBundle");
	if(!mvMailBundleClass)
    {
		NSLog(@"[ERR]  Mail.app does not have a MVMailBundle class available");
        exit(1);
    }
    
    // If you find a workaround for this depreciated method, please let me know
    class_setSuperclass([self class], mvMailBundleClass);
        
    [MCMaxColumnsPlugin registerBundle];
        
    // Fetch the sharedInstance to call the init method
    [MCMaxColumnsPlugin sharedInstance];

    NSLog(@"[INFO] Finished loading MaxColumnsPlugin %@ (took %fs)",
            [[MCMaxColumnsPlugin getOwnBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
            [initStart timeIntervalSinceNow] * -1);
}

+ (void)registerBundle 
{
    if(class_getClassMethod(NSClassFromString(@"MVMailBundle"), @selector(registerBundle)))
        [NSClassFromString(@"MVMailBundle") performSelector:@selector(registerBundle)];
}

#pragma mark - MaxColumns bundle implementation

+ (NSBundle *)getOwnBundle {
	return [NSBundle bundleForClass:[MCMaxColumnsPlugin class]];
}

- (id) init {
    if (self = [super init])
    {
        // Initialize maxColumns from Info.plist
        self.maxColumns = [(NSNumber *)[[[self class] getOwnBundle]
                                        objectForInfoDictionaryKey:@"MCMaxColumnsWrap"] intValue];
        self.maxColumns = self.maxColumns > 1 ? self.maxColumns : DEFAULT_MAX_COLUMNS;
        
        // Load Python's textwrap.fill() function
        if ([self loadPythonFillMethod]) {
            NSLog(@"[INFO] MaxColumnsPlugin successfully loaded Python textwrap.fill method");
        }
        else {
            NSLog(@"[ERR]  MaxColumnsPlugin could not load Python textwrap.fill method");
            exit(1);
        }
        
        // Extends the MailDocumentEditor class
        if ([self extendMailDocumentEditor]) {
            NSLog(@"[INFO] MaxColumnsPlugin successfully extended MailDocumentEditor");
        }
        else {
            NSLog(@"[ERR]  MaxColumnsPlugin could not extend MailDocumentEditor");
            exit(1);
        }
    }
    return self;
}

- (BOOL)extendMailDocumentEditor {
    BOOL success = YES;
    
    // Injecting removeTrailingWhitespaces method
    success &= [self injectMailDocumentEditorMethodFromClass:[MCExtendedMailDocumentEditor class]
                                                withSelector:@selector(removeTrailingWhitespaces)];
    
    // Injecting wrapMessageToMaxColumns method
    success &= [self injectMailDocumentEditorMethodFromClass:[MCExtendedMailDocumentEditor class]
                                                withSelector:@selector(wrapMessageToMaxColumns)];
    
    // Injecting sendWithCleanup: method
    success &= [self injectMailDocumentEditorMethodFromClass:[MCExtendedMailDocumentEditor class]
                                                withSelector:@selector(sendWithCleanup:)];
    
    success &= [self swizzleMailDocumentEditorMethods:@selector(send:)
                                                  and:@selector(sendWithCleanup:)];
    
    return success;
}

- (BOOL) injectMailDocumentEditorMethodFromClass:(Class)aClass withSelector:(SEL)aSelector {
    Class mailDocumentEditorClass = NSClassFromString(@"MailDocumentEditor");
    Method injectedMethod = class_getInstanceMethod(aClass, aSelector);
    IMP injectedMethodImpl = class_getMethodImplementation(aClass, aSelector);
    BOOL methodInjected = NO;
    
    // Fail if the MailDocumentEditor class is not found
    if(!mailDocumentEditorClass)
    {
		NSLog(@"[ERR]  Could not find the MailDocumentEditor class");
        return NO;
    }
    
    // Proper method injection
    methodInjected = class_addMethod(mailDocumentEditorClass,
                                     aSelector,
                                     injectedMethodImpl,
                                     method_getTypeEncoding(injectedMethod));
    
    if(!methodInjected) {
		NSLog(@"[ERR]  Could not add the sendWithWrap method to the MailDocumentEditor class");
    }
    
    return methodInjected;
}

- (BOOL) swizzleMailDocumentEditorMethods:(SEL)orig and:(SEL)new {
    Class mailDocumentEditorClass = NSClassFromString(@"MailDocumentEditor");
    Method origMethod = class_getInstanceMethod(mailDocumentEditorClass, orig);
    Method newMethod = class_getInstanceMethod(mailDocumentEditorClass, new);
    
    if (!origMethod || !newMethod) {
      	NSLog(@"[ERR]  Could not find method of MailDocumentEditor with selector %@", NSStringFromSelector(orig ? new : orig));
        return NO;
    }
    
    method_exchangeImplementations(origMethod, newMethod);
    
    return YES;
}

/*
 * Courtesy of dbr @ http://stackoverflow.com/a/791077/404321
 */
- (BOOL) loadPythonFillMethod {
    Py_Initialize();
    
    // Import textwrap
    PyObject *textWrapModule = PyImport_ImportModule("textwrap");
    
    if (PyErr_Occurred()) {
        NSLog(@"[ERR]  Error while fetching Python textwrap module");
        return NO;
    }
    
    // Instanciate the TextWrapper class
    PyObject *textWrapperClass = PyObject_GetAttrString(textWrapModule, "TextWrapper");
    PyObject *args = Py_BuildValue("()");
    PyObject *kwargs = Py_BuildValue("{sisisisi}",
                                     "width", self.maxColumns,
                                     "expand_tabs", false,
                                     "replace_whitespace", false,
                                     "drop_whitespace", false);
    self.textWrapperInst = PyObject_Call(textWrapperClass, args, kwargs);
    
    if (PyErr_Occurred()) {
        NSLog(@"[ERR]  Error while initializing TextWrapper class");
        return NO;
    }
    
    return YES;
}

@end
