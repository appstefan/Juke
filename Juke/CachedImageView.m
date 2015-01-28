//
//  CachedImageView.m
//  5by
//
//  Created by Adam Bellmore on 1/7/15.
//  Copyright (c) 2015 5by. All rights reserved.
//

#import "ImageCache.h"
#import "CachedImageView.h"
#import "Utility.h"

@interface CachedImageView ()

@property (nonatomic, strong) NSURL *currentCacheURL;
@property (nonatomic, strong) NSString *queueName;

@end

static NSInteger civ_queueCount = 0;

@implementation CachedImageView

-(void) setImage:(UIImage *)image
{
    if(image != nil)
    {
        NSLog(@"WARNING: setting image on a cache image view manually");
    }
    
    [super setImage:image];
}

-(void) setThumbnail:(UIImage *)image forURL:(NSURL *)url
{
    // Set the thumbnail only if it is the image for the current URL.
    if([url isEqual:self.currentCacheURL])
    {
        [super setImage:image];
        if(self.delegate)
            [self.delegate cachedImageViewDidChangeImage:self];
    }
}

-(void) setImageURL:(NSURL *)imageURL
{
    if(self.queueName == nil)
    {
        self.queueName = [NSString stringWithFormat:@"image_queue_%ld", civ_queueCount++];
    }
    
    _imageURL = imageURL;
    
    __block NSURL *thumbUrl = imageURL;
    __block UIImage *cachedImage = [ImageCache cachedImageForURL:thumbUrl];
    
    dispatch_queue_t myQueue;
    const char *queueName =  [self.queueName cStringUsingEncoding:NSASCIIStringEncoding];
    myQueue = dispatch_queue_create(queueName, NULL);
    
    self.currentCacheURL = thumbUrl;
    
    if (cachedImage && cachedImage != self.image) {
        if (cachedImage != nil) {
            dispatch_async(myQueue, ^{
                // Decompress image
                if (cachedImage) {
                    UIGraphicsBeginImageContextWithOptions(cachedImage.size, NO, cachedImage.scale);
                    
                    [cachedImage drawAtPoint:CGPointZero];
                    
                    cachedImage = UIGraphicsGetImageFromCurrentImageContext();
                    
                    UIGraphicsEndImageContext();
                }
                // Configure the UI with pre-decompressed UIImage
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setThumbnail:cachedImage forURL:thumbUrl];
                });
            });
        }
    } else if (!cachedImage) {
        __block UIImage *fetchedThumbImage = [UIImage new];
        dispatch_on_new_thread(@"thumb", ^{
            self.image = nil;
            [ImageCache getImage:thumbUrl imageFetchNeeded:nil imageAvailable:^(UIImage *image) {
                fetchedThumbImage = image;
            }];
        }, ^{
            [self setThumbnail:fetchedThumbImage forURL:thumbUrl];
        });
    }

}

@end
