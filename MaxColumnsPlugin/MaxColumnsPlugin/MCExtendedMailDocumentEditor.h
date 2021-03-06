//
//  MCExtendedMailDocumentEditor.h
//  MaxColumnsPlugin
//
//  Created by Guillaume Algis on 18/08/12.
//  Copyright (c) 2012 Guillaume Algis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCExtendedMailDocumentEditor : NSObject

#pragma mark - MailDocumentEditor methods

- (id)document;

#pragma mark - MCExtendedMailDocumentEditor methods

- (void) removeTrailingWhitespaces;
- (void) wrapMessageToMaxColumns;
- (void) sendWithCleanup:(id)sender;

@end
