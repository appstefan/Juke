//
//  CachedImageView.h
//  5by
//
//  Created by Adam Bellmore on 1/7/15.
//  Copyright (c) 2015 5by. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CachedImageView;

@protocol CachedImageViewDelegate <NSObject>

-(void) cachedImageViewDidChangeImage:(CachedImageView *)imageView;

@end

@interface CachedImageView : UIImageView

@property (nonatomic, copy) NSURL *imageURL;
@property (nonatomic, weak) id<CachedImageViewDelegate> delegate;

@end
