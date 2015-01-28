//
//  SearchCollectionViewCell.h
//  Juke
//
//  Created by Stefan Britton on 1/24/15.
//  Copyright (c) 2015 Greathouse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CachedImageView.h"
#import <Spotify/Spotify.h>

@interface SearchCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *artistLabel;
@property (strong, nonatomic) IBOutlet CachedImageView *coverImage;

- (void)initWithPartialTrack:(SPTPartialTrack*)partialTrack;

@end
