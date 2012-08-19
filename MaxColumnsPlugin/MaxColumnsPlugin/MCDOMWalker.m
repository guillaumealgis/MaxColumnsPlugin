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
    
    // We leave a character on each line for the newlines chars
    maxColumns -= 1;
    
    // And we transform the text to an array of maxColums length strings, which we join
    NSMutableArray *textWrappedLines = [NSMutableArray array];
    for (NSString *line in [outerText componentsSeparatedByString:@"\n"] ) {
        [textWrappedLines addObject:[[line componentsOfLength:maxColumns] componentsJoinedByString:@"\n"]];
    }
    outerTextWrapped = [textWrappedLines componentsJoinedByString:@""];
    
    NSLog(@"INNER HTML BEFORE\n%@", [rootElement innerHTML]);
    NSLog(@"OUTER TEXT\n%@", outerText);
    NSLog(@"OUTER TEXT WRAPPED\n%@", outerTextWrapped);
    
    [self walkNode:rootElement AndInjectText:outerTextWrapped];
    
    NSLog(@"INNER HTML AFTER\n%@", [rootElement innerHTML]);
}

- (void) walkNode:(DOMNode *)aNode AndInjectText:(NSString *)wrappedText {
    if ([aNode nodeType] == DOM_TEXT_NODE) {
        NSLog(@"%d : %@ : |%@|", [aNode nodeType], [aNode nodeName], [aNode nodeValue]);
        
        NSMutableString *newTextNodeValue = [NSMutableString string];
        
        unichar nodeValueChar = 0;
        unichar wrappedTextChar = 0;        
    
        uint i = 0;
        while (i < [[aNode nodeValue] length]) {
            nodeValueChar = [[aNode nodeValue] characterAtIndex:i];
            wrappedTextChar = [wrappedText characterAtIndex:self.charCount];
            
//            NSLog(@"[@%u '%C'] [@%ld '%C']", i, nodeValueChar, self.charCount, wrappedTextChar);
            if (nodeValueChar == wrappedTextChar) {
                [newTextNodeValue appendFormat:@"%C", wrappedTextChar];
                
                ++self.charCount;
                ++i;
            }
            else if (wrappedTextChar == '\n') {
                if ([newTextNodeValue length] > 0) {
                    NSLog(@"+ '%@'", newTextNodeValue);
                    [self insertTextNodeBefore:[newTextNodeValue copy] refNode:aNode];
                    [newTextNodeValue setString:@""];
                }
                NSLog(@"+ <br>");
                DOMElement *brNode = [self.domHtmlDocument createElement:@"BR"];
                [[aNode parentNode] insertBefore:brNode refChild:aNode];
                
                ++self.charCount;
                if ([[NSCharacterSet extendedWhitespaceAndNewlineCharacterSet] characterIsMember:nodeValueChar]) {
                    ++i;
                }
            }
            else {
                NSLog(@"[ERR]  Non matching characters when recomposing the mail content : '%C' '%C'", nodeValueChar, wrappedTextChar);
                ++self.charCount;
                break;
            }
//            // FIXME DEBUG
//            struct timespec a;
//            a.tv_nsec = 5000000;
//            a.tv_sec = 0;
//            nanosleep(&a, nil);
//            // FIXME DEBUG
        }
        if ([newTextNodeValue length] > 0) {
            NSLog(@"+ '%@'", newTextNodeValue);
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

//-(void)wrapDomContentAtMaxColumns:(NSInteger)maxColumns {
//    DOMHTMLElement *rootElement = [self.domHtmlDocument body];
//    DOMNodeList *children = [rootElement childNodes];    
//    
//    NSLog(@"INNER HTML BEFORE\n%@", [rootElement innerHTML]);
//    
//    // We leave a character on each line for the newlines chars
//    maxColumns -= 1;
//    
//    NSMutableArray *iterableChildren = [NSMutableArray arrayWithCapacity:[children length]];
//    for (uint i = 0; i < [children length]; ++i) {
//        NSLog(@"%@", [[children item:i] nodeName]);
//        [iterableChildren addObject:[children item:i]];
//    }
//    
//    for (DOMNode *child in iterableChildren) {
//        [self walkNode:child AndWrapAt:maxColumns];
//    }
//    
//    NSLog(@"INNER HTML AFTER\n%@", [rootElement innerHTML]);
//}
//
//-(void)walkNode:(DOMNode *)aNode AndWrapAt:(NSInteger)maxColumns {
//    NSLog(@"%d : %@ : |%@|", [aNode nodeType], [aNode nodeName], [aNode nodeValue]);
//    if ([aNode nodeType] == DOM_TEXT_NODE) {
//        NSString *nodeText = [aNode nodeValue];
//        NSLog(@"New chunk ++ offset is at %ld", self.charCount);
//        if (self.charCount + [nodeText length] > maxColumns) {
//            DOMNode *parentNode = [aNode parentNode];
//            NSArray *components = [nodeText componentsOfLength:maxColumns withOffset:self.charCount];
//            
//            for (uint i = 0; i < [components count]; ++i) {
//                DOMText *newTextNode = [self.domHtmlDocument createTextNode:[components objectAtIndex:i]];
//                DOMElement *newBrNode = [self.domHtmlDocument createElement:@"br"];
//                
//                NSLog(@"C = %@", [components objectAtIndex:i]);
//                [parentNode insertBefore:newTextNode refChild:aNode];
//                
//                if (i != [components count] - 1) {
//                    [parentNode insertBefore:newBrNode refChild:aNode];
//                }
//            }
//            [parentNode removeChild:aNode];
//            
//            self.charCount = [[components lastObject] length];
//        }
//        else {
//            // We don't need to modify this text node
//            NSLog(@"C = %@", nodeText);
//            self.charCount += [nodeText length];
//        }
//    }
//    else {
//        if ([aNode nodeType] == DOM_ELEMENT_NODE &&
//            [BLOCK_HTML_ELTS containsObject:[aNode nodeName]]) {
//            NSLog(@"IS BLOCK ELT");
//            self.charCount = 0;
//        }
//        
//        DOMNodeList *children = [aNode childNodes];
//        NSMutableArray *iterableChildren = [NSMutableArray arrayWithCapacity:[children length]];
//        
//        for (uint i = 0; i < [children length]; ++i) {
//            [iterableChildren addObject:[children item:i]];
//        }
//        
//        for (DOMNode *child in iterableChildren) {
//            [self walkNode:child AndWrapAt:maxColumns];
//        }
//    }
//}

@end
