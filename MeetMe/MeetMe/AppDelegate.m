//
//  AppDelegate.m
//  MeetMe
//
//  Created by Anas Bouzoubaa on 22/09/15.
//  Copyright © 2015 Anas Bouzoubaa. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "CurrentUser.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

// First thing called when app runs
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Load current user
    [[CurrentUser sharedInstance] loadCustomObject];
    
    // UITabBar
    UIColor *blueColor = [UIColor colorWithRed:0.19 green:0.44 blue:0.86 alpha:1.0];
    [[UITabBar appearance] setTintColor:blueColor];
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : blueColor }
                                             forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : blueColor }
                                             forState:UIControlStateSelected];
    
    // [Optional] Power your app with Local Datastore. For more info, go to
    // https://parse.com/docs/ios_guide#localdatastore/iOS
    [Parse enableLocalDatastore];
    
    // Initialize Parse.
    [Parse setApplicationId:@"CS75y3DfeewpexaaCNLCPh5182ZM1Q8XXAV8XMOF"
                  clientKey:@"P0D3Dp4gPd6kWwHX6mgYfQitzbcqjG0uPCO8s6TO"];
    
    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    currentInstallation[@"username"] = [[CurrentUser sharedInstance] phoneNumber];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Clear notifications
    [application cancelAllLocalNotifications];

    // New meeting time was set
    if ([[userInfo objectForKey:@"meetingFound"] isEqualToString:@"YES"]) {
        
        [SVProgressHUD showSuccessWithStatus:@"Found a Meeting Time!"];
        
        // Post notification to reload meetings and save new one
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_MEETING_TO_SAVE" object:self userInfo:userInfo];

        return;
    
    } else if ([[userInfo objectForKey:@"meetingFound"] isEqualToString:@"NO"]) {
        [SVProgressHUD showInfoWithStatus:@"No time could be found for your meeting"];
    }
    
    // Update list of meetings
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_MEETINGS" object:nil];
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

@end
