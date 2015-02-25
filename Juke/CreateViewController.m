//
//  CreateViewController.m
//  Juke
//
//  Created by Stefan Britton on 2/10/15.
//  Copyright (c) 2015 Greathouse. All rights reserved.
//

#import "CreateViewController.h"
#import <Parse/Parse.h>
#import <Spotify/Spotify.h>
#import "AppDelegate.h"
#import "TabBarViewController.h"

@interface CreateViewController ()
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UIButton *nameButton;
@property (strong, nonatomic) PFObject *party;

@end

@implementation CreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadInterface];
}


- (void)loadInterface {
    NSAttributedString *placeholder = [[NSAttributedString alloc] initWithString:@"Party Name" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"GothamHTF-Book" size:21.0f],
                                                                                                            NSForegroundColorAttributeName : [UIColor colorWithRed:122/255.0f
                                                                                                                                                             green:122/255.0f
                                                                                                                                                              blue:122/255.0f alpha:1.0f]}];
    [self.nameField setAttributedPlaceholder:placeholder];
}

- (IBAction)closeButton:(id)sender {
    [self.nameField resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)createButton:(id)sender {
    if (self.nameField.text.length > 0) {
        SPTSession* session = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).session;
        [SPTRequest playlistsForUserInSession:session callback:^(NSError *error, id object) {
            if (!error) {
                SPTPlaylistList *playlists = (SPTPlaylistList*)object;
                [playlists createPlaylistWithName:self.nameField.text publicFlag:YES session:session callback:^(NSError *error, SPTPlaylistSnapshot *playlist) {
                    if (!error) {
                        [self createPartyWithPlaylist:playlist];
                    } else {
                        
                    }
                }];
            } else {
                //Error
            }
        }];
    }
}

- (void)createPartyWithPlaylist:(SPTPlaylistSnapshot*)playlist {
    self.party = [PFObject objectWithClassName:@"Party" dictionary:@{@"name" : playlist.name,
                                                                          @"host" : [PFUser currentUser],
                                                                          @"playlistURI": [playlist.uri absoluteString]}];
    [self.party saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error && succeeded) {
            [self partyCreated];
        } else {
            //Error
        }
    }];
}

- (void)partyCreated
{
    [self.nameButton setTitle:self.nameField.text forState:UIControlStateNormal];
    [UIView animateWithDuration:0.4f animations:^{
        self.nameField.alpha = 0.0f;
        self.nameButton.alpha = 1.0f;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"PartySegue" sender:self];
        });
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PartySegue"]) {
        TabBarViewController *tabBarViewController = (TabBarViewController*)segue.destinationViewController;
        tabBarViewController.party = self.party;
        tabBarViewController.partyView = PartyViewHost;
    }
}

@end
