//
//  AppDelegate.m
//  push
//
//  Created by 王展 on 15/10/4.
//  Copyright (c) 2015年 王展. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self registerLocalNotification];
    
    NSDictionary * userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
        NSLog(@"Receive userInfo when launch: %@", userInfo);
        [self alertWithMessage:@"userinfo launch"];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"Regisger success: %@", deviceToken);
    
    // 1. 从系统偏好取之前的token
    NSData *oldToken = [[NSUserDefaults standardUserDefaults]objectForKey:@"deviceToken"];
    // 2. 新旧token进行比较
    if (![oldToken isEqualToData:deviceToken]) {
        // 3. 如果不一致，保存token到系统偏好
        [[NSUserDefaults standardUserDefaults]setObject:deviceToken forKey:@"deviceToken"];
        
        // 4. 使用post请求传输新旧token至服务器
        // 1) url
        // 具体的URL地址以及POST请求中的参数和格式，是由公司的后端程序员提供的
        // 2) request POST body（包含新旧token的数据）
        // 3) connection 的异步
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Register failed: %@", error);
    [self alertWithMessage:@"register failed"];
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    if (application.applicationState == UIApplicationStateActive) {
        NSLog(@"Receive userinfo on active: %@", userInfo);
        [self alertWithMessage:@"userinfo active"];
    }
    else {
        NSLog(@"Receive userinfo on background: %@", userInfo);
        [self alertWithMessage:@"userinfo background"];
    }
}

- (void)application:(UIApplication *) application handleActionWithIdentifier: (NSString *) identifier forRemoteNotification:(nonnull NSDictionary *)userInfo completionHandler:(nonnull void (^)())completionHandler {
    
    if ([identifier isEqualToString: @"ACCEPT_IDENTIFIER"]) {
        [self alertWithMessage:identifier];
    }
    
    // Must be called when finished
    completionHandler();
}

- (void)alertWithMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notification" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

- (void)registerLocalNotification {
    
    float sysVersion=[[UIDevice currentDevice]systemVersion].floatValue;
    
    if (sysVersion>=8.0) {
        UIMutableUserNotificationAction *acceptAction = [[UIMutableUserNotificationAction alloc] init];
        acceptAction.identifier = @"ACCEPT_IDENTIFIER";
        acceptAction.title = @"Accept";
        acceptAction.activationMode = UIUserNotificationActivationModeForeground;
        acceptAction.destructive = NO;
        acceptAction.authenticationRequired = YES;
        
        UIMutableUserNotificationAction *maybeAction = [[UIMutableUserNotificationAction alloc] init];
        maybeAction.identifier = @"MAYBE_IDENTIFIER";
        maybeAction.title = @"maybe";
        maybeAction.activationMode = UIUserNotificationActivationModeBackground;
        maybeAction.destructive = NO;
        maybeAction.authenticationRequired = NO;
        
        UIMutableUserNotificationAction *declineAction = [[UIMutableUserNotificationAction alloc] init];
        declineAction.identifier = @"DECLINE_IDENTIFIER";
        declineAction.title = @"decline";
        declineAction.activationMode = UIUserNotificationActivationModeBackground;
        declineAction.destructive = YES;
        
        // custom category
        UIMutableUserNotificationCategory *inviteCategory =
        [[UIMutableUserNotificationCategory alloc] init];
        inviteCategory.identifier = @"INVITE_CATEGORY";
        [inviteCategory setActions:@[acceptAction, maybeAction, declineAction]
                        forContext:UIUserNotificationActionContextDefault];
        [inviteCategory setActions:@[acceptAction, declineAction]
                        forContext:UIUserNotificationActionContextMinimal];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:
         [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:[NSSet setWithObject:inviteCategory]]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound];
    }
}

@end
