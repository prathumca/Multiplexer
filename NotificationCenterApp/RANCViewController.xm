#import "RANCViewController.h"
#import "RAHostedAppView.h"
#import "RASettings.h"

@implementation SBNCColumnViewController // dummy impl. for compiler
@end

@interface RANCViewController () {
	RAHostedAppView *appView;
	UILabel *isLockedLabel;
}
@end

extern RANCViewController *ncAppViewController;
extern BOOL shouldLoadView;

@implementation RANCViewController
+ (instancetype)sharedViewController {
	return ncAppViewController;
}

- (void)forceReloadAppLikelyBecauseTheSettingChanged {
	[appView unloadApp];
	[appView removeFromSuperview];
	appView = nil;
}


int patchOrientation(int in) {
	if (in == 3) {
		return 1;
	}
	return in;
}

int rotationDegsForOrientation(int o) {
	if (o == UIInterfaceOrientationLandscapeRight) {
		return 270;
	} else if (o == UIInterfaceOrientationLandscapeLeft) {
		return 90;
	}
	return 0;
}

//-(void)hostWillPresent;
//-(void)hostDidPresent;
//-(void)hostWillDismiss;
//-(void)hostDidDismiss;

- (void)insertAppropriateViewWithContent {
	[self viewDidAppear:YES];
}

- (void)insertTableView {

}

- (void)viewWillLayoutSubviews {
	[self viewDidAppear:YES];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if (IS_IOS_OR_NEWER(iOS_10_0) && !shouldLoadView) {
		return;
	}

	if ([[%c(SBLockScreenManager) sharedInstance] isUILocked]) {
		if (!isLockedLabel) {
			isLockedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 400)];
			isLockedLabel.numberOfLines = 2;
			isLockedLabel.textAlignment = NSTextAlignmentCenter;
			isLockedLabel.textColor = [UIColor whiteColor];
			isLockedLabel.font = [UIFont systemFontOfSize:IS_IPAD ? 36 : 30];
			[self.view addSubview:isLockedLabel];
		}

		isLockedLabel.frame = CGRectMake((self.view.frame.size.width - isLockedLabel.frame.size.width) / 2, (self.view.frame.size.height - isLockedLabel.frame.size.height) / 2, isLockedLabel.frame.size.width, isLockedLabel.frame.size.height);

		isLockedLabel.text = LOCALIZE(@"UNLOCK_FOR_NCAPP");
		return;
	} else if (isLockedLabel) {
		[isLockedLabel removeFromSuperview];
		isLockedLabel = nil;
	}

	if (!appView) {
		NSString *ident = [RASettings.sharedInstance NCApp];
		appView = [[RAHostedAppView alloc] initWithBundleIdentifier:ident];
		appView.frame = UIScreen.mainScreen.bounds;
		[self.view addSubview:appView];

		[appView preloadApp];
	}

	[appView loadApp];
	appView.hideStatusBar = YES;

	if (NO) {// (UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation))
		appView.autosizesApp = YES;
		appView.allowHidingStatusBar = YES;
		appView.transform = CGAffineTransformIdentity;
		appView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
	} else {
		appView.autosizesApp = NO;
		appView.allowHidingStatusBar = YES;

		// Reset
		appView.transform = CGAffineTransformIdentity;
		appView.frame = UIScreen.mainScreen.bounds;

		appView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(rotationDegsForOrientation(UIApplication.sharedApplication.statusBarOrientation))); // Explicitly, SpringBoard's status bar since the NC is shown in SpringBoard
		CGFloat scale = self.view.frame.size.height / UIScreen.mainScreen.RA_interfaceOrientedBounds.size.height;
		appView.transform = CGAffineTransformScale(appView.transform, scale, scale);

		// Align vertically
		CGRect f = appView.frame;
		f.origin.y = 0;
		f.origin.x = (self.view.frame.size.width - f.size.width) / 2.0;
		appView.frame = f;
	}
	//[appView rotateToOrientation:UIApplication.sharedApplication.statusBarOrientation];


	if (IS_IOS_BETWEEN(iOS_9_0, iOS_9_3)) { // Must manually place view controller :(
		CGRect frame = self.view.frame;
		frame.origin.x = UIScreen.mainScreen.bounds.size.width * 2.0;
		self.view.frame = frame;
	}
}

- (void)hostDidDismiss {
	if (appView.isCurrentlyHosting) {
		appView.hideStatusBar = NO;
		[appView unloadApp];
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];

	appView.hideStatusBar = NO;
	if (appView.isCurrentlyHosting) {
		[appView unloadApp];
	}
}

- (RAHostedAppView*)hostedApp {
	return appView;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
	// Override
	LogDebug(@"[ReachApp] RANCViewController: ignoring invocation: %@", anInvocation);
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
	NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
	if (!signature && class_respondsToSelector(%c(SBBulletinObserverViewController), aSelector)) {
		signature = [%c(SBBulletinObserverViewController) instanceMethodSignatureForSelector:aSelector];
	}
	return signature;
}

- (BOOL)isKindOfClass:(Class)aClass {
	if (aClass == %c(SBBulletinObserverViewController) || aClass == %c(SBNCColumnViewController)) {
		return YES;
	} else {
		return [super isKindOfClass:aClass];
	}
}
@end
