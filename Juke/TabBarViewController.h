//
//  TabBarViewController.h
//  Juke
//
//  Created by Stefan Britton on 2/11/15.
//  Copyright (c) 2015 Greathouse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

typedef enum : NSUInteger {
    PartyViewHost,
    PartyViewGuest,
} PartyView;

@interface TabBarViewController : UIViewController
@property (nonatomic) PartyView partyView;
@property (strong, nonatomic) PFObject *party;
@end
