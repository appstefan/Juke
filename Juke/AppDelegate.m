//
//  AppDelegate.m
//  Juke
//
//  Created by Stefan Britton on 1/24/15.
//  Copyright (c) 2015 Greathouse. All rights reserved.
//

#import "AppDelegate.h"
#import <Spotify/Spotify.h>

@interface AppDelegate ()

@end

static NSString * const kClientId = @"421e715a799b47f79925e26f05f5c5cf";
static NSString * const kCallbackURL = @"juke://callback";
static NSString * const kTokenSwapURL = @"https://aqueous-meadow-3841.herokuapp.com/swap";

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([[SPTAuth defaultInstance] canHandleURL:url withDeclaredRedirectURL:[NSURL URLWithString:kCallbackURL]]) {
        [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:url tokenSwapServiceEndpointAtURL:[NSURL URLWithString:kTokenSwapURL] callback:^(NSError *error, SPTSession *session) {
            if (error != nil) {
                NSLog(@"***Auth Error :%@", error);
                return;
            }
            _session = session;
        }];
        return YES;
    }
    return NO;
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
