//
//  NSString+MCWrap.m
//  MaxColumnsPlugin
//
//  Created by Guillaume Algis on 17/08/12.
//  Copyright (c) 2012 Guillaume Algis. All rights reserved.
//

#import "NSString+MCWrap.h"
#import "MCMaxColumnsPlugin.h"
#import "NSCharacterSet+MCExtendedWhitespaces.h"

@implementation NSString (MCWrap)

- (NSString *)stringByWrappingToMaxColumns:(NSInteger)maxCols {  
    // theargs = ()
    PyObject *theargs = PyTuple_New(2);
    
    // theargs[0] = the text to wrap
    PyTuple_SetItem(theargs, 0, PyString_FromString([self UTF8String]));
    
    // theargs[1] = max columns
    PyTuple_SetItem(theargs, 1, PyInt_FromLong(maxCols));
    
    // f = thefunc.__call__(*theargs)
    PyObject *result = PyObject_CallObject([[MCMaxColumnsPlugin sharedInstance] pyFillFunc], theargs);

    if(!result){
        NSLog(@"[ERR]  Could not call the Python textwrap.fill() method");
        return @"";
    }

    return [NSString stringWithCString:PyString_AsString(result) encoding:NSUTF8StringEncoding];
}

/*
 * DEPRECIATED
 * Use stringByWrappingToMaxColumns: instead
 */
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
