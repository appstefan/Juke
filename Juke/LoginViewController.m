//
//  LoginViewController.m
//  Juke
//
//  Created by Stefan Britton on 1/27/15.
//  Copyright (c) 2015 Greathouse. All rights reserved.
//

#import "LoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface LoginViewController ()
@property (strong, nonatomic) IBOutlet FBLoginView *loginView;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loginView.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    
}


@end
