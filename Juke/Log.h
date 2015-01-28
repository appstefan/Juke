//
//  Log.h
//  FiveBy
//
//  Created by Cameron Saul on 4/29/13.
//  Copyright (c) 2013 FiveBy. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * The general concept behind these categories is that something non-verbose is something you'd probably want to
 * leave on all the time (e.g. NavigationService's "pushedViewController..." messages) while verbose categories
 * are something you'd want to leave disabled most of the time unless you're working on a specific feature related
 * to those logs (e.g. APIVerbose returns the API response for each request; this is usually needless clutter that
 * negatively affects performance, but when implementing API code you'd want this on).
 */
typedef enum : NSUInteger {
	LogCategoryAPI,
	LogCategoryAPIVerbose,
	LogCategoryModels,
	LogCategoryModelsVerbose,
	LogCategoryImageCache,
	LogCategoryImageCacheVerbose,
	LogCategoryViews,
	LogCategoryViewsVerbose,
	LogCategoryNavigation,
	LogCategoryWalkthrough,
	LogCategoryWalkthroughVerbose,
	LogCategoryConciege,
	LogCategoryConciegeVerbose,
	LogCategoryQueue,
	LogCategoryQueueVerbose,
	LogCategoryVideoPlayer,
	LogCategoryVideoPlayerVerbose,
    LogCategoryComments,
    LogCategoryCommentsVerbose,
    LogCategoryYoutubePlayer,
	LogCategoryYoutubePlayerVerbose,
	LogCategoryFacebook,
    LogCategorySocial,
    LogCategorySocialVerbose,
    LogCategoryProfile,
    LogCategoryProfileVerbose,
    LogCategoryTracking,
    LogCategoryTrackingVerbose
} LogCategory;

/**
 * TODO - In release builds set this to 1 to disable all logging
 * !!! Also should disable all assertions in prod builds
 */
#define DISABLE_ALL_LOGGING 0

/**
 * Returns true/false if a logging category is enabled.
 * (You can enable/disable various logging categories in the implementation file)
 */
bool log_enable_category(LogCategory category);

void Log(LogCategory category, NSString *format, ...);