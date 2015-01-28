//
//  SearchCollectionViewCell.m
//  Juke
//
//  Created by Stefan Britton on 1/24/15.
//  Copyright (c) 2015 Greathouse. All rights reserved.
//

#import "SearchCollectionViewCell.h"

@implementation SearchCollectionViewCell

- (void)initWithPartialTrack:(SPTPartialTrack *)partialTrack
{
    self.titleLabel.text = partialTrack.name;
    
    SPTArtist *artist = (SPTArtist*)[partialTrack.artists firstObject];
    
    self.artistLabel.text = artist.name;
    
    [SPTTrack trackWithURI:partialTrack.uri session:nil callback:^(NSError *error, id object) {
        SPTTrack *track = (SPTTrack*)object;
        NSArray *covers = track.album.covers;
        SPTImage *cover = [covers firstObject];
        self.coverImage.imageURL = cover.imageURL;
    }];
}

@end
