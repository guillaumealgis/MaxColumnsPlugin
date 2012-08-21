//
//  MaxColumnsPlugin.h
//  MaxColumnsPlugin
//
//  Created by Guillaume Algis on 16/08/12.
//  Copyright (c) 2012 Guillaume Algis. All rights reserved.
//

#import <Python/Python.h>

@interface MCMaxColumnsPlugin : NSObject {
    NSInteger maxColumns;
    PyObject *pyFillFunc;
}

@property (nonatomic, assign) NSInteger maxColumns;
@property (nonatomic, assign) PyObject *pyFillFunc;

#pragma mark - MVMailBundle methods

+ (void) initialize;
+ (void)registerBundle;
+ (id)sharedInstance;

#pragma mark - MCMaxColumnsPlugin methods

+ (NSBundle *)getOwnBundle;

- (id) init;
- (BOOL) extendMailDocumentEditor;
- (BOOL) injectMailDocumentEditorMethodFromClass:(Class)aClass withSelector:(SEL)aSelector;
- (BOOL) swizzleMailDocumentEditorMethods:(SEL)orig and:(SEL)new;
- (BOOL) loadPythonFillMethod;

@end
