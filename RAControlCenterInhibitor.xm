#import "RAControlCenterInhibitor.h"
#import <UIKit/UIKit.h>

BOOL overrideCC = NO;

@implementation RAControlCenterInhibitor : NSObject
+ (void)setInhibited:(BOOL)value {
	overrideCC = value;
}

+ (BOOL)isInhibited {
	return overrideCC;
}
@end

%hook SBUIController
- (void)_showControlCenterGestureBeganWithLocation:(CGPoint)arg1 {
	if (!overrideCC) {
		return;
	}
	%orig;
}

- (void)handleShowControlCenterSystemGesture:(__unsafe_unretained id)arg1 {
	if (!overrideCC) {
		return;
	}
	%orig;
}
%end

%hook SBControlCenterController
- (void)presentAnimated:(BOOL)arg1 completion:(id)arg2 {
	if (!overrideCC) {
		return;
	}
	%orig;
}
%end
