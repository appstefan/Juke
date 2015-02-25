//
//  SearchSongCollectionViewCell.m
//  Juke
//
//  Created by Stefan Britton on 2/12/15.
//  Copyright (c) 2015 Greathouse. All rights reserved.
//

#import "SearchSongCollectionViewCell.h"

@implementation SearchSongCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)initWithPartialTrack:(SPTPartialTrack *)partialTrack
{
    _track = partialTrack;
    self.titleLabel.text = partialTrack.name;
    
    SPTArtist *artist = (SPTArtist*)[partialTrack.artists firstObject];
    
    self.artistLabel.text = artist.name;
    
    [SPTTrack trackWithURI:partialTrack.uri session:nil callback:^(NSError *error, id object) {
        dispatch_async(dispatch_get_main_queue(), ^{
            SPTTrack *track = (SPTTrack*)object;
            NSArray *covers = track.album.covers;
            SPTImage *cover = [covers firstObject];
            self.albumImage.imageURL = cover.imageURL;
        });
    }];
}

@end
