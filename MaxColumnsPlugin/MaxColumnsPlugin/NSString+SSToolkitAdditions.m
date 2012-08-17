//
//  NSString+SSToolkitAdditions.m
//  MaxColumnsPlugin
//
//  Created by MattDiPasquale.
//  Adapted by Guillaume Algis for MaxColumnsPlugin
//  See http://stackoverflow.com/questions/5689288#5691567
//

#import "NSString+SSToolkitAdditions.h"
#import "NSCharacterSet+MCExtendedWhitespaces.h"

@implementation NSString (SSToolkitAdditions)

#pragma mark Trimming Methods

- (NSString *)stringByTrimmingLeadingCharactersInSet:(NSCharacterSet *)characterSet {
    NSRange rangeOfFirstWantedCharacter = [self rangeOfCharacterFromSet:[characterSet invertedSet]];
    if (rangeOfFirstWantedCharacter.location == NSNotFound) {
        return @"";
    }
    return [self substringFromIndex:rangeOfFirstWantedCharacter.location];
}

- (NSString *)stringByTrimmingLeadingWhitespaceAndNewlineCharacters {
    return [self stringByTrimmingLeadingCharactersInSet:
            [NSCharacterSet extendedWhitespaceAndNewlineCharacterSet]];
}

- (NSString *)stringByTrimmingTrailingCharactersInSet:(NSCharacterSet *)characterSet {
    NSRange rangeOfLastWantedCharacter = [self rangeOfCharacterFromSet:[characterSet invertedSet]
                                                               options:NSBackwardsSearch];

    if (rangeOfLastWantedCharacter.location == NSNotFound) {
        return @"";
    }
    
    return [self substringToIndex:rangeOfLastWantedCharacter.location+1]; // non-inclusive
}

- (NSString *)stringByTrimmingTrailingWhitespaceAndNewlineCharacters {
    return [self stringByTrimmingTrailingCharactersInSet:
            [NSCharacterSet extendedWhitespaceAndNewlineCharacterSet]];
}


@end
