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

@implementation MCExtendedMailDocumentEditor

- (void) removeTrailingWhitespaces {
    // TODO: To be implemented
    NSLog(@"[IMPL] removeTrailingWhitespaces");
}

- (void) wrapMessageToMaxColumns {
    NSInteger maxColumns = [[MCMaxColumnsPlugin sharedInstance] maxColumns];

    // We go through the objects members to find our message
    id document = objc_msgSend(self, @selector(document));
    DOMHTMLDocument *domHtmlDocument = objc_msgSend(document, @selector(htmlDocument));
    
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
//    [self sendWithCleanup:sender];
}

@end
