//
//  AppDelegate.h
//  Juke
//
//  Created by Stefan Britton on 1/24/15.
//  Copyright (c) 2015 Greathouse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Spotify/Spotify.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SPTSession *session;


@end

