//
//  Log.m
//  FiveBy
//
//  Created by Cameron Saul on 4/29/13.
//  Copyright (c) 2013 FiveBy. All rights reserved.
//

#import "Log.h"

bool log_enable_category(LogCategory category) {
	switch (category) {
		case LogCategoryAPI:                    return true;
		case LogCategoryModels:                 return false;
		case LogCategoryImageCache:             return false;
		case LogCategoryViews:                  return false;
		case LogCategoryNavigation:             return false;
        case LogCategoryWalkthrough:            return false;
		case LogCategoryConciege:               return true;
		case LogCategoryFacebook:               return false;
		case LogCategoryQueue:                  return true;
		case LogCategoryVideoPlayer:            return true;
        case LogCategoryComments:               return true;
        case LogCategoryYoutubePlayer:          return false;
        case LogCategorySocial:                 return true;
        case LogCategoryProfile:                return false;
        case LogCategoryTracking:               return true;
			
		case LogCategoryViewsVerbose:           return false;
		case LogCategoryConciegeVerbose:        return true;
		case LogCategoryAPIVerbose:             return true;
		case LogCategoryModelsVerbose:          return false;
		case LogCategoryImageCacheVerbose:      return false;
        case LogCategoryWalkthroughVerbose:     return false;
		case LogCategoryQueueVerbose:           return true;
		case LogCategoryVideoPlayerVerbose:     return true;
        case LogCategoryYoutubePlayerVerbose:	return false;
        case LogCategoryCommentsVerbose:        return true;
        case LogCategorySocialVerbose:          return true;
        case LogCategoryProfileVerbose:         return false;
        case LogCategoryTrackingVerbose:        return true;

		default: return true;
	}
}

void Log(LogCategory category, NSString *format, ...) {
	if (!DISABLE_ALL_LOGGING && log_enable_category(category)) {
		va_list ap;
		va_start(ap, format);
		NSLogv(format, ap);
		va_end(ap);
	}
}