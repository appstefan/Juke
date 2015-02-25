//
//  StartViewController.m
//  Juke
//
//  Created by Stefan Britton on 2/10/15.
//  Copyright (c) 2015 Greathouse. All rights reserved.
//

#import "StartViewController.h"
#import <Spotify/Spotify.h>
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "TabBarViewController.h"

static NSString * const kClientId = @"421e715a799b47f79925e26f05f5c5cf";
static NSString * const kCallbackURL = @"juke://callback";
static NSString * const kTokenSwapURL = @"https://aqueous-meadow-3841.herokuapp.com/swap";

@interface StartViewController ()
@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePictureView;
@property (strong, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) PFObject *party;

@end

@implementation StartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadInterface];
    [self loadUser];
    self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.appDelegate.startViewController = self;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    PFQuery *query = [PFQuery queryWithClassName:@"Party"];
    [query fromPinWithName:@"CurrentParty"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (object && !error) {
            self.party = object;
            [self.party fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                TabBarViewController *tabBarViewController = (TabBarViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"TabBarViewController"];
                tabBarViewController.party = self.party;
                PFUser *host = self.party[@"host"];
                if ([host.objectId isEqualToString:[PFUser currentUser].objectId]) {
                    tabBarViewController.partyView = PartyViewHost;
                } else {
                    tabBarViewController.partyView = PartyViewGuest;
                }
                [self presentViewController:tabBarViewController animated:NO completion:nil];
            }];
        }
    }];
    
}

- (void)loadInterface {
    self.profilePictureView.backgroundColor = [UIColor clearColor];
    self.profilePictureView.layer.cornerRadius = 40.0f;
    self.profilePictureView.layer.masksToBounds = YES;
}

- (void)loadUser {
    [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
        if (!error) {
            self.profilePictureView = [self.profilePictureView initWithProfileID:user.objectID pictureCropping:FBProfilePictureCroppingSquare];
            NSString *nameString = [NSString stringWithFormat:@"What's up, %@?", user.first_name];
            NSDictionary *defaultAttributes = @{NSFontAttributeName : [UIFont fontWithName:@"GothamHTF-Light" size:19.0f], NSForegroundColorAttributeName : [UIColor whiteColor]};
            NSDictionary *nameAttributes = @{NSFontAttributeName : [UIFont fontWithName:@"GothamHTF-Book" size:19.0f], NSForegroundColorAttributeName : [UIColor whiteColor]};
            NSMutableAttributedString *welcomeString = [[NSMutableAttributedString alloc] initWithString:nameString attributes:defaultAttributes];
            [welcomeString setAttributes:nameAttributes range:NSMakeRange(welcomeString.length - (user.first_name.length+1), user.first_name.length)];
            [self.welcomeLabel setAttributedText:welcomeString];
        }
    }];
}

- (IBAction)hostButton:(id)sender {
    if (self.appDelegate.session.isValid) {
        [self performSegueWithIdentifier:@"CreateSegue" sender:self];
    } else {
        SPTAuth *auth = [SPTAuth defaultInstance];
        NSURL *loginURL = [auth loginURLForClientId:kClientId declaredRedirectURL:[NSURL URLWithString:kCallbackURL] scopes:@[SPTAuthStreamingScope, SPTAuthUserLibraryReadScope, SPTAuthPlaylistModifyPublicScope]];
        [[UIApplication sharedApplication] performSelector:@selector(openURL:) withObject:loginURL afterDelay:0.1f];
    }
    
}

@end
