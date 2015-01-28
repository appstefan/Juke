//
//  Utility.m
//  FiveBy
//
//  Created by Cameron Saul on 4/9/13.
//  Copyright (c) 2013 FiveBy. All rights reserved.
//

#import "Utility.h"
#import "AppDelegate.h"

BOOL is_ipad() {
	return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

BOOL is_iphone() {
	return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
}

BOOL is_iphone_5() {
	return is_iphone() && [UIScreen mainScreen].bounds.size.height > 500.0f;
}

BOOL is_landscape() {
	if (is_iphone()) return YES; // iphone is always in landscape for this version of the app.
	
	// device orientation seems to be the most accurate and up-to-date, but since face up / face down are considered valid orientations we can't always rely on device orientation.
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	if (UIDeviceOrientationIsLandscape(orientation)) {
		return YES;
	} else if (UIDeviceOrientationIsPortrait(orientation)) {
		return NO;
	}
	
	// inspect the toInterfaceOrientation of the modal view controller if it exists and it implements the ToInterfaceOrientation property
//	__weak UIViewController *presentedViewController = APP_DELEGATE.rootViewController.presentedViewController;
//	if (presentedViewController && [presentedViewController conformsToProtocol:@protocol(ToInterfaceOrientation)]) {
//		__weak UIViewController<ToInterfaceOrientation> *presentedVC = (UIViewController<ToInterfaceOrientation> *)presentedViewController;
//		if ([presentedVC toInterfaceOrientation] != 0) {
//			return UIInterfaceOrientationIsLandscape([presentedVC toInterfaceOrientation]);
//		}
//	}
//	
//	return UIDeviceOrientationIsLandscape([(UIViewController<ToInterfaceOrientation> *)(APP_DELEGATE.rootViewController) toInterfaceOrientation]);
    return NULL;
}

BOOL is_portrait() {
	return !is_landscape();
}

BOOL is_ipad_landscape() {
	return is_ipad() && is_landscape();
}

BOOL is_ipad_portrait() {
	return is_ipad() && is_portrait();
}

BOOL is_retina() {
	return [UIScreen mainScreen].scale > 1;
}

void dispatch_next_run_loop(dispatch_block_t block) {
	double delayInSeconds = 0.001;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), block);
}

void dispatch_on_new_thread(NSString *threadname, dispatch_block_t block, dispatch_block_t finishblock){
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSThread currentThread] setName:threadname ? threadname : @"Unnamed Fiveby thread"];
//        NSLog(@"Executing first block");
        block();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            finishblock();
//            NSLog(@"Executing final block");
        });
    });
}

void dispatch_on_new_thread_with_priority(NSString *threadname, long priority, dispatch_block_t block, dispatch_block_t finishblock){
    dispatch_async(dispatch_get_global_queue(priority, 0), ^{
        [[NSThread currentThread] setName:threadname ? threadname : @"Unnamed Fiveby thread"];
//        NSLog(@"Executing first block");
        block();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            finishblock();
//            NSLog(@"Executing final block");
        });
    });
}

NSString *formattedVideoTime(NSTimeInterval time) {
    int minutes = 0;
    int seconds = 0;
    if (floor(time) == 60){
        return @"1:00";
    }
    
    if (time > 60){
        minutes = floor(time/60);
        seconds = floor(time - (minutes*60));
    }else{
        seconds = floor(time);
    }
    NSString *minutesString = [NSString stringWithFormat:@"%i",minutes];
    NSString *secondsString = [NSString stringWithFormat:@"%i",seconds];
    
    //    if (minutes < 10){
    //        minutesString = [NSString stringWithFormat:@"0%i",minutes];
    //    }
    if (seconds < 10){
        if (seconds < 0){
            seconds = 0;
        }
        secondsString = [NSString stringWithFormat:@"0%i",seconds];
    }
    
    return [NSString stringWithFormat:@"%@:%@",minutesString,secondsString];
}

NSDictionary *sizeAndNumberOfLinesForLabel(UILabel *label, float maxWidth) {
    
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          label.font, NSFontAttributeName,
                                          nil];
    
    CGRect frame = [label.text boundingRectWithSize:CGSizeMake(maxWidth, 2000.0) //2000.0 is undetermined value
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:attributesDictionary
                                            context:nil];
    
    CGSize size = frame.size;
    
    NSError *error = NULL;
    NSRange lineBreakRange = [label.text rangeOfString:@"\n" options:NSCaseInsensitiveSearch];
    NSUInteger numberOfLineBreaks = 0;
    if (lineBreakRange.length != 0) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\n" options:NSRegularExpressionCaseInsensitive error:&error];
        numberOfLineBreaks = [regex numberOfMatchesInString:label.text options:0 range:NSMakeRange(0, [label.text length])];
//        NSLog(@"Found %i extra linebreaks",numberOfLineBreaks);
    }
    
    int numberOfLines = ceil((double)size.height/(double)label.font.pointSize) + numberOfLineBreaks + 1;
//    NSLog(@"Height:%f Number of extra lines:%i Total number of lines: %i", size.height, numberOfLineBreaks, numberOfLines);
    return @{ @"width": [NSString stringWithFormat:@"%f", size.width], @"height": [NSString stringWithFormat:@"%f", size.height], @"lines": [NSString stringWithFormat:@"%i", numberOfLines]};
}

//To calculate textView height
CGFloat textViewHeightForAttributedText(NSAttributedString* text, CGFloat width) {
    UITextView *calculationView = [[UITextView alloc] init];
    [calculationView setAttributedText:text];
    CGSize size = [calculationView sizeThatFits:CGSizeMake(width, FLT_MAX)];
    return size.height;
}

//To calculate uilabel height
CGFloat labelHeightForAttributedText(NSAttributedString* text, CGFloat width) {
    if ([text length] > 1) {
        UILabel *calculationView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 21)];
        calculationView.numberOfLines = 0; // allows label to have as many lines as needed
        [calculationView setAttributedText:text];
        [calculationView sizeToFit];
        return calculationView.frame.size.height+4; // 76 is a constant to add room for stash button.
    } else {
        return 0;
    }
}

CGFloat labelWidthWithAttributedString(NSAttributedString* string) {
    UILabel *sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 16, 44)];
    [sizeLabel setNumberOfLines:1];
    [sizeLabel setAttributedText:string];
    [sizeLabel sizeToFit];
    return sizeLabel.frame.size.width;
}

NSString* formatElapsedTime(NSDate *startDate, NSDate *endDate)
{
    
    NSTimeInterval timeZoneSeconds = [[NSTimeZone localTimeZone] secondsFromGMT];
    NSDate *dateInLocalTimezone = [startDate dateByAddingTimeInterval:timeZoneSeconds];

    
    
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSDateComponents *components = [gregorian components:unitFlags
                                                fromDate:dateInLocalTimezone
                                                  toDate:endDate options:0];
    NSInteger minutes = ABS([components minute]);
    NSInteger hours = ABS([components hour]);
    NSInteger days = ABS([components day]);
    NSInteger months = ABS([components month]);
    
    NSString *timeSincePosted;
    if (months > 0) {
        timeSincePosted = [NSString stringWithFormat:@"%dM", (int)months];
    } else if (days > 0) {
        timeSincePosted = [NSString stringWithFormat:@"%dD", (int)days];
    } else if (hours > 0){
        timeSincePosted = [NSString stringWithFormat:@"%dH", (int)hours];
    } else {
        if (minutes < 1) {
            timeSincePosted = @"NOW";
        }else{
            timeSincePosted = [NSString stringWithFormat:@"%ld %@", (long)minutes, minutes > 1 ? @"MINS" : @"MIN"];
        }
    }
    return timeSincePosted;
}

NSString* formatTimeSince(NSDate *startDate, NSDate *endDate)
{
    return formatElapsedTime(startDate, endDate);
}

NSString* formatLongElapsedTime(NSDate *startDate, NSDate *endDate)
{
    NSTimeInterval timeZoneSeconds = [[NSTimeZone localTimeZone] secondsFromGMT];
    NSDate *dateInLocalTimezone = [startDate dateByAddingTimeInterval:timeZoneSeconds];
    
    
    
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSDateComponents *components = [gregorian components:unitFlags
                                                fromDate:dateInLocalTimezone
                                                  toDate:endDate options:0];
    NSInteger minutes = ABS([components minute]);
    NSInteger hours = ABS([components hour]);
    NSInteger days = ABS([components day]);
    NSInteger months = ABS([components month]);
    
    NSString *timeSincePosted;
    if (months > 0) {
        timeSincePosted = [NSString stringWithFormat:@"%d %@ AGO, FROM", (int)months, months > 1 ? @"MONTHS" : @"MONTH"];
    } else if (days > 0) {
        timeSincePosted = [NSString stringWithFormat:@"%d %@ AGO, FROM", (int)days, days > 1 ? @"DAYS" : @"DAY"];
    } else if (hours > 0){
        timeSincePosted = [NSString stringWithFormat:@"%d %@ AGO, FROM", (int)hours, hours > 1 ? @"HOURS" : @"HOUR"];
    } else {
        if (minutes < 1) {
            timeSincePosted = @"NOW, FROM";
        }else{
            timeSincePosted = [NSString stringWithFormat:@"%d %@ AGO, FROM", (int)minutes, minutes > 1 ? @"MINUTES" : @"MINUTE"];
        }
    }
    return timeSincePosted;
}

NSDate* dateFromString(NSString *dateString){
    /*
     Returns a user-visible date time string that corresponds to the specified
     RFC 3339 date time string. Note that this does not handle all possible
     RFC 3339 date time strings, just one of the most common styles.
     */
    if ([dateString isKindOfClass:[NSNull class]]) {
        return nil;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    // Convert the RFC 3339 date time string to an NSDate.
    NSDate *date = [dateFormatter dateFromString:dateString];
    
    return date;
}

UIImage* croppedImageWithImage(UIImage *image, CGFloat zoom) {
    CGFloat zoomReciprocal = 1.0f / zoom;
    CGPoint offset = CGPointMake(40, 40);
    CGRect croppedRect = CGRectMake(offset.x, offset.y, image.size.width * zoomReciprocal, image.size.height * zoomReciprocal);
    CGImageRef croppedImageRef = CGImageCreateWithImageInRect([image CGImage], croppedRect);
    UIImage* croppedImage = [[UIImage alloc] initWithCGImage:croppedImageRef scale:[image scale] orientation:[image imageOrientation]];
    CGImageRelease(croppedImageRef);
    return croppedImage;
}

@implementation BaseConversion

// Uses the alphabet length as base.
+(NSString*) formatNumber:(NSUInteger)n usingAlphabet:(NSString*)alphabet
{
    NSUInteger base = [alphabet length];
    if (n<base){
        // direct conversion
        NSRange range = NSMakeRange(n, 1);
        return [alphabet substringWithRange:range];
    } else {
        return [NSString stringWithFormat:@"%@%@",
                
                // Get the number minus the last digit and do a recursive call.
                // Note that division between integer drops the decimals, eg: 769/10 = 76
                [self formatNumber:n/base usingAlphabet:alphabet],
                
                // Get the last digit and perform direct conversion with the result.
                [alphabet substringWithRange:NSMakeRange(n%base, 1)]];
    }
}

+(NSString*) formatNumber:(NSUInteger)n toBase:(NSUInteger)base
{
    NSString *alphabet = @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"; // 62 digits
    NSAssert([alphabet length]>=base,@"Not enough characters. Use base %ld or lower.",(unsigned long)[alphabet length]);
    return [self formatNumber:n usingAlphabet:[alphabet substringWithRange:NSMakeRange (0, base)]];
}

UIColor* averageColorForImage(UIImage* image) {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char rgba[4];
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), image.CGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    UIColor *color;
    if(rgba[3] > 0) {
        CGFloat alpha = ((CGFloat)rgba[3])/255.0;
        CGFloat multiplier = alpha/255.0;
        color = [UIColor colorWithRed:((CGFloat)rgba[0])*multiplier
                                green:((CGFloat)rgba[1])*multiplier
                                 blue:((CGFloat)rgba[2])*multiplier
                                alpha:alpha];
    }
    else {
        color = [UIColor colorWithRed:((CGFloat)rgba[0])/255.0
                                green:((CGFloat)rgba[1])/255.0
                                 blue:((CGFloat)rgba[2])/255.0
                                alpha:((CGFloat)rgba[3])/255.0];
    }
    CGFloat h, s, b, a;
    [color getHue:&h saturation:&s brightness:&b alpha:&a];
    return [UIColor colorWithHue:h saturation:s brightness:b * 0.75 alpha:a];
}


NSString* getFormattedTime(CGFloat timeInSeconds) {
    NSInteger seconds = (NSInteger) round(timeInSeconds);
    NSInteger hours = seconds / (60 * 60);
    seconds %= (60 * 60);
    
    NSInteger minutes = seconds / 60;
    seconds %= 60;
    
    if (hours > 0) {
        return [NSString stringWithFormat:@"%ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
    } else {
        return [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];
    }
}


@end