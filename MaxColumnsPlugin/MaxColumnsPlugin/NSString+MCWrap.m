//
//  NSString+MCWrap.m
//  MaxColumnsPlugin
//
//  Created by Guillaume Algis on 17/08/12.
//  Copyright (c) 2012 Guillaume Algis. All rights reserved.
//

#import "NSString+MCWrap.h"
#import "NSCharacterSet+MCExtendedWhitespaces.h"

// Debug macro
//#define dumpRange(x) (NSLog( @"RangeDump :: Value of %s = { %lu, %lu } : \"%@\"",#x, x.location, x.length, x.location != NSNotFound ? [self substringWithRange:x] : @"##NSNotFound"))

@implementation NSString (MCWrap)

//- (NSString *)stringByWrappingToMaxColumns:(NSInteger)maxCols {
//    NSMutableString *mutableString = [NSMutableString stringWithCapacity:[self length]];
//    
//    NSRange searchRange = {0, maxCols };
//    NSRange rangeOfLastUnwantedCharacter;
//    NSRange substringRange;
//    BOOL isLastLineChunk = NO;
//    
//    // We iterate on the line, by chunks of maxCols characters
//    // The stop condition is the last chunk's range which will be out of bounds
//    while (YES) {
//        
//        @try {
//            // We find the last whitespace character in the chunk
//            rangeOfLastUnwantedCharacter = [self rangeOfCharacterFromSet:
//                                          [NSCharacterSet extendedWhitespaceAndNewlineCharacterSet]
//                                                                        options:NSBackwardsSearch
//                                                                          range:searchRange];
//            
//            if (rangeOfLastUnwantedCharacter.location == NSNotFound) {
//                // In the case of a contiguous chunk of non-whitespaces chars, we take the whole chunks
//                rangeOfLastUnwantedCharacter.location = searchRange.location + searchRange.length;
//                rangeOfLastUnwantedCharacter.length = 0;
//            }
//            
//            // Prepare for the selection of the "interesting" part of the chunk
//            substringRange.length = rangeOfLastUnwantedCharacter.location - searchRange.location;
//        }
//        @catch (NSException *exception) {
//            // We reached the end of the line, the last chunk was too long
//            substringRange.length = [self length] - searchRange.location;
//            isLastLineChunk = YES;
//            break;
//        }
//        @finally {
//            // We take the "interesting" part of the chunk and append it to our message, with a trailing newline
//            substringRange.location = searchRange.location;
//            [mutableString appendString:[self substringWithRange:substringRange]];
//            
//            if (!isLastLineChunk)
//                [mutableString appendString:@"\n"];
//            
//            // Set the next chunk position for next iteration
//            searchRange.location = rangeOfLastUnwantedCharacter.location + rangeOfLastUnwantedCharacter.length;
//        }
//    }
//    
//    return [mutableString copy];
//}
//
//- (NSArray *)componentsOfLength:(NSInteger)componentLength {
//    NSInteger nbComponents = self.length / componentLength + 1;
//    NSMutableArray *components = [NSMutableArray arrayWithCapacity:nbComponents];
//    
//    NSRange componentRange = { 0, componentLength };
//    NSString *component = nil;
//
//    for (uint i = 0; i < nbComponents; ++i) {
//        @try {
//            component = [self substringWithRange:componentRange];
//        }
//        @catch (NSException *exception) {
//            // We are on the last component, which is shorter than componentLength
//            componentRange.length = self.length - componentRange.location;
//            component = [self substringWithRange:componentRange];
//        }
//        @finally {
//            [components addObject:component];
//            componentRange.location += componentLength + 1;
//        }
//    }
//    
//    return [components copy];
//}

- (NSArray *)componentsOfLength:(NSInteger)componentLength {
    NSInteger nbComponents = self.length / componentLength + 1;
    NSMutableArray *components = [NSMutableArray arrayWithCapacity:nbComponents];
    
    NSRange searchRange = {0, componentLength };
    NSRange rangeOfLastUnwantedCharacter;
    NSRange substringRange;
    
    // We iterate on the string, by chunks of maxCols characters
    // The stop condition is the last chunk's range which will be out of bounds
    while (YES) {
        @try {
            // We find the last whitespace character in the chunk
            rangeOfLastUnwantedCharacter = [self rangeOfCharacterFromSet:[NSCharacterSet extendedWhitespaceAndNewlineCharacterSet]
                                                                 options:NSBackwardsSearch
                                                                   range:searchRange];
            
            if (rangeOfLastUnwantedCharacter.location == NSNotFound) {
                // In the case of a contiguous chunk of non-whitespaces chars, we take the whole chunk
                rangeOfLastUnwantedCharacter.location = searchRange.location + searchRange.length;
                rangeOfLastUnwantedCharacter.length = 0;
            }
            
            // Prepare for the selection of the "interesting" part of the chunk
            substringRange.length = rangeOfLastUnwantedCharacter.location - searchRange.location;
        }
        @catch (NSException *exception) {
            // We reached the end of the line, the last chunk was too long
            substringRange.length = [self length] - searchRange.location;
            break;
        }
        @finally {
            // We take the "interesting" part of the chunk and append it to our message, with a trailing newline
            substringRange.location = searchRange.location;
            [components addObject:[self substringWithRange:substringRange]];
            
            // Set the next chunk position for next iteration
            searchRange.location = rangeOfLastUnwantedCharacter.location + rangeOfLastUnwantedCharacter.length;
            // Reset the search length to the default length
            //(we already done the first chunk, the offset is no longer needed)
            searchRange.length = componentLength;
        }
    }
    
    return [components copy];
}



@end
