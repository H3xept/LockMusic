#import "SharedHelper.h"
#import "YoloViewController.h"


@implementation SharedHelper
+ (instancetype)sharedInstance {
	static SharedHelper* helper = nil;
	if(!helper) {
		helper = [[SharedHelper alloc] init];
		helper.songState = 0;
		helper.panelActive = NO;
		helper.isMusicApp = NO;
	}
	return helper;
}

- (void)notifyPaneOfSongStateUpdate {
	if(_likeDislikePane) {
		[((YoloViewController*)_likeDislikePane) receivedStateChange:_songState];
	}
}
@end