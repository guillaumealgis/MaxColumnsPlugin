//
//  NSCharacterSet+MCExtendedWhitespaces.h
//  MaxColumnsPlugin
//
//  Created by Guillaume Algis on 17/08/12.
//  Copyright (c) 2012 Guillaume Algis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSCharacterSet (MCExtendedWhitespaces)

+ (id)extendedWhitespaceCharacterSet;
+ (id)extendedWhitespaceAndNewlineCharacterSet;

@end
