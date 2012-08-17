//
//  NSString+SSToolkitAdditions.h
//  MaxColumnsPlugin
//
//  Created by MattDiPasquale.
//  Adapted by Guillaume Algis for MaxColumnsPlugin
//  See http://stackoverflow.com/questions/5689288#5691567
//

#import <Foundation/Foundation.h>

@interface NSString (SSToolkitAdditions)

- (NSString *)stringByTrimmingLeadingCharactersInSet:(NSCharacterSet *)characterSet;

- (NSString *)stringByTrimmingLeadingWhitespaceAndNewlineCharacters;

- (NSString *)stringByTrimmingTrailingCharactersInSet:(NSCharacterSet *)characterSet;

- (NSString *)stringByTrimmingTrailingWhitespaceAndNewlineCharacters;

@end
