//
//  MCExtendedMailDocumentEditor.m
//  MaxColumnsPlugin
//
//  Created by Guillaume Algis on 18/08/12.
//  Copyright (c) 2012 Guillaume Algis. All rights reserved.
//

#import <WebKit/WebKit.h>
#import <objc/message.h>

#import "MCExtendedMailDocumentEditor.h"
#import "MCMaxColumnsPlugin.h"
#import "MCDOMWalker.h"

@class EditableWebMessageDocument; // Will be defined by Mail

@implementation MCExtendedMailDocumentEditor

#pragma mark - MailDocumentEditor methods

- (id)document {
    // This method is herited from MailDocumentEditor.
    // This stub is only here for easy compilation.
    // It should not be called.
    @throw [NSException exceptionWithName:@"NSInternalInconsistencyException"
                                   reason:@"Method stub"
                                 userInfo:nil];
}

#pragma mark - MCExtendedMailDocumentEditor methods

- (void) removeTrailingWhitespaces {
    // TODO: To be implemented
    NSLog(@"[IMPL] removeTrailingWhitespaces");
}

- (void) wrapMessageToMaxColumns {
    NSInteger maxColumns = [[MCMaxColumnsPlugin sharedInstance] maxColumns];

    // We go through the objects members to find our message
    EditableWebMessageDocument *document = [self document];
    DOMHTMLDocument *domHtmlDocument = objc_msgSend(document, @selector(htmlDocument));
    
    // Detecting if the message is plain text
    // Note: This rely on the class="ApplePlainTextBody" attribute of the <body> element
    // it may not be the safest way to do this
    DOMHTMLElement *domBody = [domHtmlDocument body];
    NSString *bodyClassName = [domBody className];
    NSRange range = [bodyClassName rangeOfString:@"ApplePlainTextBody" options:NSCaseInsensitiveSearch];
    if(range.location == NSNotFound) {
        // Not plain text, we don't wrap
        return;
    }

    MCDOMWalker *domWalker = [[MCDOMWalker alloc] initWithDOMHTMLDocument:domHtmlDocument];
    [domWalker wrapDomContentAtMaxColumns:maxColumns];
    
    domWalker = nil;    
}

- (void) sendWithCleanup:(id)sender {
    NSDate *cleanupStart = [NSDate date];
    [self wrapMessageToMaxColumns];
    [self removeTrailingWhitespaces];
    
    NSLog(@"[INFO] MaxColumnsPlugin finished cleaning the message (took %fs)",
          [cleanupStart timeIntervalSinceNow] * -1);
    
    // Finally we call the default send: implementation
    [self sendWithCleanup:sender];
}

@end
