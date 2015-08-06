#import "RASpringBoardKeyboardActivation.h"
#import "headers.h"
#import <AppSupport/CPDistributedMessagingCenter.h>
#import "RAMessaging.h"
#import "RAMessagingClient.h"
#import "RAKeyboardWindow.h"
#import "RARemoteKeyboardView.h"

extern BOOL overrideDisableForStatusBar;
RAKeyboardWindow *keyboardWindow;

@implementation RASpringBoardKeyboardActivation
+(id) sharedInstance
{
    SHARED_INSTANCE(RASpringBoardKeyboardActivation);
}

-(void) showKeyboardForAppWithIdentifier:(NSString*)identifier
{
    if (keyboardWindow)
    {
        NSLog(@"[ReachApp] springboard cancelling");
        return;
    }

    keyboardWindow = [[RAKeyboardWindow alloc] init];   
    overrideDisableForStatusBar = YES;
    [keyboardWindow setupForKeyboardAndShow:identifier];
    overrideDisableForStatusBar = NO;
}

-(void) hideKeyboard
{
    NSLog(@"[ReachApp] remove kb window");
    keyboardWindow.hidden = YES;
    [keyboardWindow removeKeyboard];
    keyboardWindow = nil;
}
@end