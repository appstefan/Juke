//
//  LoginViewController.m
//  Juke
//
//  Created by Stefan Britton on 1/27/15.
//  Copyright (c) 2015 Greathouse. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <Parse/Parse.h>
#import "StartViewController.h"

@interface LoginViewController ()
@property (strong, nonatomic) IBOutlet UIButton *facebookButton;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.facebookButton.layer.cornerRadius = 22.0f;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([PFUser currentUser] && // Check if user is cached
        [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) { // Check if user is linked to Facebook
        StartViewController *startViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"StartViewController"];
        [self presentViewController:startViewController animated:NO completion:nil];
    }
}

- (IBAction)facebookButton:(id)sender {
    [PFFacebookUtils logInWithPermissions:@[@"public_profile", @"email", @"user_friends"] block:^(PFUser *user, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!user) {
                NSLog(@"%@", error);
            } else if (user.isNew) {
                NSLog(@"User signed up and logged in through Facebook!");
                [self performSegueWithIdentifier:@"FacebookLoginSegue" sender:self];
            } else {
                NSLog(@"User logged in through Facebook!");
                [self performSegueWithIdentifier:@"FacebookLoginSegue" sender:self];
            }
        });
    }];
}

@end
