//
//  NSString+MCWrap.h
//  MaxColumnsPlugin
//
//  Created by Guillaume Algis on 17/08/12.
//  Copyright (c) 2012 Guillaume Algis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MCWrap)

- (NSString *)stringByWrappingToMaxColumns:(NSInteger)maxCols;

- (NSArray *)componentsOfLength:(NSInteger)componentLength __attribute__((deprecated));

@end
