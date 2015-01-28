//
//  ImageQueue.m
//  FiveBy
//
//  Created by Cameron Saul on 4/29/13.
//  Copyright (c) 2013 FiveBy. All rights reserved.
//

#import "Utility.h"
#import "ImageCache.h"
#import "Log.h"

static NSMutableDictionary *ic_inMemoryCache;
static NSInteger ic_inMemoryCacheSize;
#define ImageCacheMaxSize (16 * 1024 * 1024)

@interface ImageCacheLine : NSObject
@property (nonatomic, strong) NSDate *lastUpdate;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, weak) id key;
@end

@implementation ImageCacheLine
@end

@implementation ImageQueue

+ (id)sharedManager {
    static ImageQueue *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.name = @"Image Fetch Queue";
    }
    return self;
}

@end

@implementation ImageCache

+(void) initCache
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ic_inMemoryCache = [NSMutableDictionary dictionary];
    });
}

+ (NSString *)filePathForImageURL:(NSURL *)imageURL {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cacheDir = [paths objectAtIndex:0];
	return [cacheDir stringByAppendingPathComponent:[[imageURL description] stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
}	

+ (void)getASyncImage:(NSURL *)imageURL imageFetchNeeded:(ImageFetchNeededBlock)imageFetchNeededBlock imageAvailable:(ImageAvailableBlock)imageAvailableBlock {
	NSString *filePath = [ImageCache filePathForImageURL:imageURL];
	Log(LogCategoryImageCacheVerbose, @"ImageCache: Filepath is %@", filePath);
	NSData *existingData = [NSData dataWithContentsOfFile:filePath];
	if (existingData) {
		Log(LogCategoryImageCacheVerbose, @"ImageCache: image %@ is present in cache.", imageURL);
		if (imageAvailableBlock) imageAvailableBlock([UIImage imageWithData:existingData]);
		return;
	}
	
	Log(LogCategoryImageCacheVerbose, @"ImageCache: fetching image %@.", imageURL);
	if (imageFetchNeededBlock) imageFetchNeededBlock();
	
	dispatch_next_run_loop(^{
		NSURLRequest *request = [NSURLRequest requestWithURL:imageURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f];
		[NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
			if (error || !data) {
				Log(LogCategoryImageCacheVerbose, @"ImageCache: image %@ unavailable.", imageURL);
				if (imageAvailableBlock) imageAvailableBlock(nil);
				return;
			}
			
			error = nil;
			[data writeToFile:filePath options:NSDataWritingAtomic error:&error];
			if (error) {
				Log(LogCategoryImageCache, @"Error saving image to disk: %@", error);
			}
			
			UIImage *image = [UIImage imageWithData:data];
			Log(LogCategoryImageCacheVerbose, @"ImageCache: image %@ fetched.", imageURL);
			if (imageAvailableBlock) imageAvailableBlock(image);
			return;
		}];
	});
}

+ (void)getImage:(NSURL *)imageURL imageFetchNeeded:(ImageFetchNeededBlock)imageFetchNeededBlock imageAvailable:(ImageAvailableBlock)imageAvailableBlock {
    
    UIImage *cacheImage = [self memoryCacheGetImage:imageURL];
    if(cacheImage && imageAvailableBlock)
    {
        imageAvailableBlock(cacheImage);
        return;
    }
    
	NSString *filePath = [ImageCache filePathForImageURL:imageURL];
	Log(LogCategoryImageCacheVerbose, @"ImageCache: Filepath is %@", filePath);
	NSData *existingData = [NSData dataWithContentsOfFile:filePath];
	if (existingData) {
        UIImage *foundImage = [UIImage imageWithData:existingData];
        [self memoryCacheAddImage:foundImage fromURL:imageURL];
		Log(LogCategoryImageCacheVerbose, @"ImageCache: image %@ is present in cache.", imageURL);
		if (imageAvailableBlock) imageAvailableBlock(foundImage);
		return;
	}
	
	Log(LogCategoryImageCacheVerbose, @"ImageCache: fetching image %@.", imageURL);
	if (imageFetchNeededBlock) imageFetchNeededBlock();
	
		NSURLRequest *request = [NSURLRequest requestWithURL:imageURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f];
        NSError *error = nil;
        NSHTTPURLResponse *responseCode = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
        
			if (error || !data) {
				Log(LogCategoryImageCacheVerbose, @"ImageCache: image %@ unavailable.", imageURL);
				if (imageAvailableBlock) imageAvailableBlock(nil);
				return;
			}
			
			error = nil;
			[data writeToFile:filePath options:NSDataWritingAtomic error:&error];
			if (error) {
				Log(LogCategoryImageCache, @"Error saving image to disk: %@", error);
			}
			
			UIImage *image = [UIImage imageWithData:data];
            [self memoryCacheAddImage:image fromURL:imageURL];
			Log(LogCategoryImageCacheVerbose, @"ImageCache: image %@ fetched.", imageURL);
			if (imageAvailableBlock) imageAvailableBlock(image);
			return;
}


+ (void)prefetchImageIfNeeded:(NSURL *)imageURL {
    NSOperationQueue *imageQueue = [ImageQueue sharedManager];
    [imageQueue addOperationWithBlock:^{
       [ImageCache getImage:imageURL imageFetchNeeded:nil imageAvailable:nil];
    }];
}

+ (UIImage *)cachedImageForURL:(NSURL *)imageURL {
    
    UIImage *image = [self memoryCacheGetImage:imageURL];
    if(image)
        return image;
    
	NSString *filePath = [ImageCache filePathForImageURL:imageURL];
//    NSLog(@"Loading from cache: %@", filePath);
	NSData *existingData = [NSData dataWithContentsOfFile:filePath];
    
    image = existingData ? [UIImage imageWithData:existingData] : nil;
    
    if(image != nil)
        [self memoryCacheAddImage:image fromURL:imageURL];
    
    return image;
}

+ (void)listCache {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cacheDir = [paths objectAtIndex:0];
    //-----> LIST ALL FILES <-----//
//    NSLog(@"LISTING ALL FILES FOUND");
    
    int count;
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cacheDir error:NULL];
    for (count = 0; count < (int)[directoryContent count]; count++)
    {
//        NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
    }
}

+(UIImage *) memoryCacheGetImage:(NSURL *)url
{
    if(![NSThread isMainThread])
        return nil;
    
    ImageCacheLine *cacheLine = [ic_inMemoryCache objectForKey:url];
    if(cacheLine == nil)
    {
        Log(LogCategoryImageCache, @"IN MEMORY CACHE: Miss - %@", url);
        return nil;
    }
    cacheLine.lastUpdate = [NSDate date];
    Log(LogCategoryImageCache, @"IN MEMORY CACHE: Hit  - %@", url);
    return cacheLine.image;
}

+(void) memoryCacheAddImage:(UIImage *)image fromURL:(NSURL *)url
{
    if(![NSThread isMainThread])
        return;
    
    NSInteger size = image.size.width * image.size.height * sizeof(UInt32);
    
    if(size + ic_inMemoryCacheSize > ImageCacheMaxSize)
    {
        [self memoryCacheEjectOldest];
    }
    
    ImageCacheLine *line = [[ImageCacheLine alloc] init];
    line.lastUpdate = [NSDate date];
    line.image = image;
    line.key = url;
    [ic_inMemoryCache setObject:line forKey:url];
    ic_inMemoryCacheSize += size;
}

+(void) memoryCacheEjectOldest
{
    if(![NSThread isMainThread])
        return;
    
    NSArray *lines = [[ic_inMemoryCache allValues] sortedArrayUsingComparator:^NSComparisonResult(ImageCacheLine *l1, ImageCacheLine *l2) {
        return [l2.lastUpdate compare:l1.lastUpdate];
    }];
    if(lines.count > 0)
    {
        ImageCacheLine *eject = lines[0];
        
        NSLog(@"IN MEMORY CACHE: Ejec - %@ (%ld > %ld)", eject.key, ic_inMemoryCacheSize, (long)ImageCacheMaxSize);
        if (eject.key) {
            [ic_inMemoryCache removeObjectForKey:eject.key];
        }
        NSInteger size = eject.image.size.width * eject.image.size.height * sizeof(NSInteger);
        ic_inMemoryCacheSize -= size;
        ic_inMemoryCacheSize = MIN(0, ic_inMemoryCacheSize);
        eject.image = nil;
        eject.lastUpdate = nil;
    }
}

@end
