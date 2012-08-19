//
//  MaxColumnsPlugin.h
//  MaxColumnsPlugin
//
//  Created by Guillaume Algis on 16/08/12.
//  Copyright (c) 2012 Guillaume Algis. All rights reserved.
//

@interface MCMaxColumnsPlugin : NSObject {
    NSInteger maxColumns;
}

@property (nonatomic, assign) NSInteger maxColumns;

#pragma mark - MVMailBundle methods

+ (void)registerBundle;
+ (id)sharedInstance;
+ (BOOL)hasPreferencesPanel;
+ (id)preferencesOwnerClassName;
+ (id)preferencesPanelName;

#pragma mark - MCMaxColumnsPlugin methods

//- (BOOL) 

@end
