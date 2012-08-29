//
//  MCDOMWalker.m
//  MaxColumnsPlugin
//
//  Created by Guillaume Algis on 17/08/12.
//  Copyright (c) 2012 Guillaume Algis. All rights reserved.
//

#import "MCDOMWalker.h"
#import "NSString+MCWrap.h"
#import "NSCharacterSet+MCExtendedWhitespaces.h"

@interface MCDOMWalker ()

- (void) walkNode:(DOMNode *)aNode AndInjectText:(NSString *)wrappedText;

@end

@implementation MCDOMWalker

@synthesize domHtmlDocument = _domHtmlDocument;
@synthesize charCount = _charCount;

- (id) initWithDOMHTMLDocument:(DOMHTMLDocument *)aDomHtmlDocument {
    if (self = [super init])
    {
        self.charCount = 0;
        self.domHtmlDocument = aDomHtmlDocument;
    }
    return self;
}

- (void) wrapDomContentAtMaxColumns:(NSInteger)maxColumns {
    DOMHTMLElement *rootElement = [self.domHtmlDocument body];
    NSString *outerText = [rootElement outerText];
    NSString *outerTextWrapped = nil;
    
    // Clean the HTML document from useless \n (added by Mail for no reason ?)
    rootElement.innerHTML = [rootElement.innerHTML stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    // And we transform the text to an array of maxColums length strings, which we join
    NSMutableArray *textWrappedLines = [NSMutableArray array];
    for (NSString *line in [outerText componentsSeparatedByString:@"\n"] ) {
        [textWrappedLines addObject:[line stringByWrappingToMaxColumns:maxColumns]];
    }
    outerTextWrapped = [textWrappedLines componentsJoinedByString:@""];
    
    [self walkNode:rootElement AndInjectText:outerTextWrapped];
}

- (void) walkNode:(DOMNode *)aNode AndInjectText:(NSString *)wrappedText {
    if ([aNode nodeType] == DOM_TEXT_NODE) {        
        NSMutableString *newTextNodeValue = [NSMutableString string];

        unichar nodeValueChar = 0;
        unichar wrappedTextChar = 0;        
    
        uint i = 0;
        while (i < [[aNode nodeValue] length]) {
            nodeValueChar = [[aNode nodeValue] characterAtIndex:i];
            wrappedTextChar = [wrappedText characterAtIndex:self.charCount];
            
            if (nodeValueChar == wrappedTextChar) {
                [newTextNodeValue appendFormat:@"%C", wrappedTextChar];
                
                ++self.charCount;
                ++i;
            }
            else if (wrappedTextChar == '\n') {
                if ([newTextNodeValue length] > 0) {
                    [self insertTextNodeBefore:[newTextNodeValue copy] refNode:aNode];
                    [newTextNodeValue setString:@""];
                }

                DOMElement *brNode = [self.domHtmlDocument createElement:@"BR"];
                [[aNode parentNode] insertBefore:brNode refChild:aNode];
                
                ++self.charCount;
                if ([[NSCharacterSet extendedWhitespaceAndNewlineCharacterSet] characterIsMember:nodeValueChar]) {
                    ++i;
                }
            }
            else if (nodeValueChar == 0x20) {
                ++i;
            }
            else {
                NSLog(@"[ERR]  Non matching characters when recomposing the mail content : '%C' '%C' (0x%x 0x%x)",
                      nodeValueChar, wrappedTextChar, nodeValueChar, wrappedTextChar);
                ++self.charCount;
                break;
            }
        }
        if ([newTextNodeValue length] > 0) {
            [self insertTextNodeBefore:[newTextNodeValue copy] refNode:aNode];
        }
        
        // "Move" to the last added replacement node
        DOMNode *oldTextNode = aNode;
        aNode = [aNode previousSibling];
        
        // Remove the old text node
        [[oldTextNode parentNode] removeChild:oldTextNode];
        oldTextNode = nil;
    }
    
    if ([aNode firstChild]) {
        [self walkNode:[aNode firstChild] AndInjectText:wrappedText];
    }
    
    if ([aNode nextSibling]) {
        [self walkNode:[aNode nextSibling] AndInjectText:wrappedText];
    }
}

- (void) insertTextNodeBefore:(NSString *)textValue refNode:(DOMNode *)refChild {
    DOMText *newTextNode = [self.domHtmlDocument createTextNode:textValue];
    [[refChild parentNode] insertBefore:newTextNode refChild:refChild];
}

@end
