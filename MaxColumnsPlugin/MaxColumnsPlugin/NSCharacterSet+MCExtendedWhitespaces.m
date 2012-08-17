//
//  NSCharacterSet+MCExtendedWhitespaces.m
//  MaxColumnsPlugin
//
//  Created by Guillaume Algis on 17/08/12.
//  Copyright (c) 2012 Guillaume Algis. All rights reserved.
//

#import "NSCharacterSet+MCExtendedWhitespaces.h"

@implementation NSCharacterSet (MCExtendedWhitespaces)

+ (id)extendedWhitespaceAndNewlineCharacterSet {
    // This custom charset adds the
    // 0x00a0 (NO-BREAK SPACE) and
    // 0x0009 (CHARACTER TABULATION) characters to the Cocoa whitespaceAndNewlineCharacterSet
    
    NSMutableCharacterSet *workingSet = [[NSCharacterSet whitespaceAndNewlineCharacterSet] mutableCopy];
    UniChar chars[] = {0x00a0, 0x0009};
    NSString *string = [[NSString alloc] initWithCharacters:chars
                                                     length:sizeof(chars) / sizeof(UniChar)];
    [workingSet addCharactersInString:string];
    return [workingSet copy];
}

@end
