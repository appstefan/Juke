//
//  ImageQueue.h
//  FiveBy
//
//  Created by Cameron Saul on 4/29/13.
//  Copyright (c) 2013 FiveBy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageQueue : NSOperationQueue
+ (id)sharedManager;
@end

typedef void(^ImageFetchNeededBlock)();
typedef void(^ImageAvailableBlock)(UIImage *image);

/**
 * ImageCache fetches images from the internet and stores them on disk. When you request an image that is already present in the cache,
 * imageAvailableBlock will be called immediately (imageFetchNeededBlock will NOT be called).
 * When you request an image that must be fetched, imageFetchNeededBlock will be called IMMEDIATELY (so you can display a loading spinner) and 
 * imageAvailableBlock will be called when the image has been fetched. If the image is not available at that URL, imageAvailableBlock will have nil
 * as a parameter.
 */
@interface ImageCache : NSObject

+(void) initCache;

+ (void)getImage:(NSURL *)imageURL imageFetchNeeded:(ImageFetchNeededBlock)imageFetchNeededBlock imageAvailable:(ImageAvailableBlock)imageAvailableBlock;

+ (void)getASyncImage:(NSURL *)imageURL imageFetchNeeded:(ImageFetchNeededBlock)imageFetchNeededBlock imageAvailable:(ImageAvailableBlock)imageAvailableBlock;

/**
 * Fetches an image and saves to disk if not already present
 */
+ (void)prefetchImageIfNeeded:(NSURL *)imageURL;

/**
 * Returns image if it has been downloaded, or nil if not
 */
+ (UIImage *)cachedImageForURL:(NSURL *)imageURL;

/**
 * Logs files in cache
 */
+ (void)listCache;

@end
