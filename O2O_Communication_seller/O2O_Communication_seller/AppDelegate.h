//
//  AppDelegate.h
//  O2O_XiCheSeller
//
//  Created by 密码为空！ on 15/6/18.
//  Copyright (c) 2015年 zongyoutec.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

-(void)dealFuncTab;

-(void)dealPush:(NSDictionary*)userinof bopenwith:(BOOL)bopenwith;
@end

