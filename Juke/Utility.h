//
//  Utility.h
//  FiveBy
//
//  Created by Cameron Saul on 4/9/13.
//  Copyright (c) 2013 FiveBy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define SYSTEM_VERSION_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

BOOL is_ipad();
BOOL is_iphone();
BOOL is_iphone_5();
BOOL is_landscape();
BOOL is_portrait();
BOOL is_ipad_landscape();
BOOL is_ipad_portrait();
BOOL is_retina();

CGSize current_screen_size();

void dispatch_next_run_loop(dispatch_block_t block);
void dispatch_on_new_thread(NSString *threadname, dispatch_block_t block, dispatch_block_t finishblock);
void dispatch_on_new_thread_with_priority(NSString *threadname, long priority, dispatch_block_t block, dispatch_block_t finishblock);

NSString *formattedVideoTime(NSTimeInterval time);
NSDictionary *sizeAndNumberOfLinesForLabel(UILabel *label, float maxWidth);

CGFloat labelHeightForAttributedText(NSAttributedString* text, CGFloat width);
CGFloat textViewHeightForAttributedText(NSAttributedString* text, CGFloat width);
CGFloat labelWidthWithAttributedString(NSAttributedString* string);

NSString* formatElapsedTime(NSDate *startDate, NSDate *endDate);
NSString* formatLongElapsedTime(NSDate *startDate, NSDate *endDate);
NSDate* dateFromString(NSString *dateString);
NSString* formatTimeSince(NSDate *startDate, NSDate *endDate);

UIImage* croppedImageWithImage(UIImage *image, CGFloat zoom);
UIColor* averageColorForImage(UIImage* image);

NSString* getFormattedTime(CGFloat timeInSeconds);


@interface BaseConversion : NSObject
+(NSString*) formatNumber:(NSUInteger)n toBase:(NSUInteger)base;
+(NSString*) formatNumber:(NSUInteger)n usingAlphabet:(NSString*)alphabet;

@end