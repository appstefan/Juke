//
//  SongViewController.h
//  Juke
//
//  Created by Stefan Britton on 2/12/15.
//  Copyright (c) 2015 Greathouse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Spotify/Spotify.h>
#import <Parse/Parse.h>

@interface SongViewController : UIViewController
@property (strong, nonatomic) SPTPartialTrack *track;
@property (strong, nonatomic) PFObject *party;

@end
