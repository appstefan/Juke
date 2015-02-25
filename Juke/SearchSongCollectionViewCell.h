//
//  SearchSongCollectionViewCell.h
//  Juke
//
//  Created by Stefan Britton on 2/12/15.
//  Copyright (c) 2015 Greathouse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Spotify/Spotify.h>
#import "CachedImageView.h"

@interface SearchSongCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UILabel *artistLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet CachedImageView *albumImage;
@property (strong, nonatomic) SPTPartialTrack *track;

- (void)initWithPartialTrack:(SPTPartialTrack*)partialTrack;

@end
