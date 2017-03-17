#import "headers.h"
#import <pthread.h>

@protocol RARunningAppsProviderDelegate
@optional
- (void)appDidStart:(__unsafe_unretained SBApplication*)app;
- (void)appDidDie:(__unsafe_unretained SBApplication*)app;
@end

@interface RARunningAppsProvider : NSObject {
	NSMutableArray *apps;
	NSMutableArray *targets;
	pthread_mutex_t mutex;
}
+ (instancetype)sharedInstance;

- (void)addRunningApp:(__unsafe_unretained SBApplication*)app;
- (void)removeRunningApp:(__unsafe_unretained SBApplication*)app;

- (void)addTarget:(__weak NSObject<RARunningAppsProviderDelegate>*)target;
- (void)removeTarget:(__weak NSObject<RARunningAppsProviderDelegate>*)target;

- (NSArray*)runningApplications;
@end
