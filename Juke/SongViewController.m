//
//  SongViewController.m
//  Juke
//
//  Created by Stefan Britton on 2/12/15.
//  Copyright (c) 2015 Greathouse. All rights reserved.
//

#import "SongViewController.h"
#import "CachedImageView.h"
#import "SOZOChromoplast.h"
#import "UIImage+Tint.h"

@interface SongViewController () <CachedImageViewDelegate>
@property (strong, nonatomic) IBOutlet CachedImageView *albumImage;
@property (strong, nonatomic) IBOutlet UIView *cardView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *artistLabel;
@property (strong, nonatomic) IBOutlet UIView *buttonsView;
@property (strong, nonatomic) IBOutlet UIButton *addButton;
@property (strong, nonatomic) IBOutlet UILabel *addLabel;
@property (strong, nonatomic) IBOutlet UIButton *playNextButton;
@property (strong, nonatomic) IBOutlet UILabel *playNextLabel;

@end

@implementation SongViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadInterface];
    [self loadTrack];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

- (void)loadInterface {
    self.cardView.hidden = YES;
}

- (void)loadTrack {
    if (self.track) {
        self.titleLabel.text = self.track.name;
        SPTArtist *artist = [self.track.artists firstObject];
        self.artistLabel.text = artist.name;
        [SPTTrack trackWithURI:self.track.uri session:nil callback:^(NSError *error, id object) {
            dispatch_async(dispatch_get_main_queue(), ^{
                SPTTrack *track = (SPTTrack*)object;
                NSArray *covers = track.album.covers;
                SPTImage *cover = [covers lastObject];
                self.albumImage.delegate = self;
                self.albumImage.imageURL = cover.imageURL;
            });
        }];
    }
}

- (void)cachedImageViewDidChangeImage:(CachedImageView *)imageView {
    SOZOChromoplast *chromoplast = [[SOZOChromoplast alloc] initWithImage:imageView.image];
    self.cardView.backgroundColor = chromoplast.dominantColor;
    self.titleLabel.textColor = chromoplast.firstHighlight;
    self.artistLabel.textColor = chromoplast.firstHighlight;
    self.addLabel.textColor = chromoplast.firstHighlight;
    self.playNextLabel.textColor = chromoplast.firstHighlight;
    self.buttonsView.backgroundColor = [chromoplast.secondHighlight colorWithAlphaComponent:0.3f];
    UIImage *addImage = [[UIImage imageNamed:@"ic_queue"] imageTintedWithColor:chromoplast.firstHighlight];
    UIImage *nextImage = [[UIImage imageNamed:@"ic_next"] imageTintedWithColor:chromoplast.firstHighlight];
    [self.addButton setImage:[addImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [self.playNextButton setImage:[nextImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    
    CGFloat offset = [[UIScreen mainScreen] bounds].size.height - self.cardView.frame.origin.y;
    self.cardView.transform = CGAffineTransformMakeTranslation(0.0f, offset);
    self.cardView.hidden = NO;
    [UIView animateWithDuration:0.7f delay:0.0f usingSpringWithDamping:0.5f initialSpringVelocity:0.5f options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.cardView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        //
    }];
}

- (IBAction)addButton:(id)sender {
//    PFObject *song = [PFObject objectWithClassName:@"Song" dictionary:@{@"identifier" : self.track.identifier,
//                                                                        @"name": self.track.name,
//                                                                        }];
//    

    NSMutableArray *array = (NSMutableArray*)self.party[@"songs"];
    if (array) {
        [array addObject:self.track.identifier];
    } else {
        array = [[NSMutableArray alloc] initWithObjects:self.track.identifier, nil];
    }
    self.party[@"songs"] = array;
    [self.party saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error && succeeded) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            //Error
        }
    }];
}

- (IBAction)closeButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
