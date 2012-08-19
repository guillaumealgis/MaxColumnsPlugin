//
//  MCDOMWalker.h
//  MaxColumnsPlugin
//
//  Created by Guillaume Algis on 17/08/12.
//  Copyright (c) 2012 Guillaume Algis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface MCDOMWalker : NSObject {
    DOMHTMLDocument *domHtmlDocument;
    NSInteger charCount;
}

@property (nonatomic, retain) DOMHTMLDocument *domHtmlDocument;
@property (nonatomic, assign) NSInteger charCount;

-(id)initWithDOMHTMLDocument:(DOMHTMLDocument *)domHtmlDocument;
-(void)wrapDomContentAtMaxColumns:(NSInteger)maxColumns;

@end
