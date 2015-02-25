//
//  AppDelegate.m
//  Juke
//
//  Created by Stefan Britton on 1/24/15.
//  Copyright (c) 2015 Greathouse. All rights reserved.
//

#import "AppDelegate.h"
#import "CreateViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

static NSString * const kClientId = @"421e715a799b47f79925e26f05f5c5cf";
static NSString * const kCallbackURL = @"juke://callback";
static NSString * const kTokenSwapURL = @"https://aqueous-meadow-3841.herokuapp.com/swap";

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [Parse enableLocalDatastore];
    [Parse setApplicationId:@"CICE0jQBKUWhJGZmmxCF6FxmdOJP4r7JGZvgAMi4"
                  clientKey:@"k4YUxTYIWM2SvTOJ5ApOSXXgbMRIVg2WP97XLFum"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [PFFacebookUtils initializeFacebook];
    [FBProfilePictureView class];
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    if ([[SPTAuth defaultInstance] canHandleURL:url withDeclaredRedirectURL:[NSURL URLWithString:kCallbackURL]]) {
        [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:url tokenSwapServiceEndpointAtURL:[NSURL URLWithString:kTokenSwapURL] callback:^(NSError *error, SPTSession *session) {
            if (error != nil) {
                NSLog(@"***Auth Error :%@", error);
                return;
            }
            _session = session;
            NSData *sessionData = [NSKeyedArchiver archivedDataWithRootObject:_session];
            [[NSUserDefaults standardUserDefaults] setObject:sessionData forKey:@"session"];
            
            UIStoryboard *storyboard = ((UIStoryboard*)[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]]);
            CreateViewController* createViewController = (CreateViewController*)[storyboard instantiateViewControllerWithIdentifier:@"CreateViewController"];
            [self.startViewController presentViewController:createViewController animated:YES completion:^{
                //
            }];
        }];
        return YES;
    }
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
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

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
