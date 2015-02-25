//
//  CodeViewController.m
//  Juke
//
//  Created by Stefan Britton on 2/12/15.
//  Copyright (c) 2015 Greathouse. All rights reserved.
//

#import "CodeViewController.h"
#import "TabBarViewController.h"
#import <Parse/Parse.h>

@interface CodeViewController () <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *codeField;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) IBOutlet UIButton *nameButton;
@property (strong, nonatomic) PFObject *party;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation CodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.codeField.delegate = self;
    // Do any additional setup after loading the view.
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.codeField resignFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(tryCode) userInfo:nil repeats:YES];
    return YES;
}

- (void)tryCode {
    self.party = [PFQuery getObjectOfClass:@"Party" objectId:self.codeField.text];
    if (self.party) {
        [self foundParty];
    } else {
        NSLog(@"no party");
    }
    [self.timer invalidate];
}

- (void)foundParty {
    NSLog(@"Party found");
    NSString *name = [NSString stringWithFormat:@"Join %@", self.party[@"name"]];
    [self.nameButton setTitle:name forState:UIControlStateNormal];
    [self.messageLabel setText:@"You're in. Enjoy the night. 👹"];
    [UIView animateWithDuration:0.4f animations:^{
        self.nameButton.alpha = 1.0f;
        self.codeField.alpha = 0.0f;
    } completion:^(BOOL finished) {
    
    }];
}

- (IBAction)joinButton:(id)sender {
    [self performSegueWithIdentifier:@"JoinSegue" sender:self];
}

- (IBAction)closeButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    TabBarViewController *tabBarViewController = (TabBarViewController*)segue.destinationViewController;
    tabBarViewController.party = self.party;
}


@end
