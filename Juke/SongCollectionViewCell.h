//
//  SongCollectionViewCell.h
//  Juke
//
//  Created by Stefan Britton on 2/12/15.
//  Copyright (c) 2015 Greathouse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Spotify/Spotify.h>
#import "CachedImageView.h"

@interface SongCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet CachedImageView *imageView;
@property (strong, nonatomic) SPTPartialTrack *track;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *artistLabel;

- (void)initWithPartialTrack:(SPTPartialTrack*)partialTrack;
@end
