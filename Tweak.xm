#include <rocketbootstrap/rocketbootstrap.h>

#include "./tools/LLIPC.h"
#include "./tools/LLLog.h"

#define __DBG__

#ifdef __DBG__
#define LOG(X) LLLogPrint((char *)X);
#else 
#define LOG(X)
#endif

%ctor{
	assert(lllog_register_service("net.jndok.logserver") == 0);
}

@interface SBDashBoardMediaArtworkViewController:UIViewController
@end
@interface MPUMediaRemoteControlsView:UIView
@end
@interface MPUMediaControlsVolumeView:UIView
@end
@interface MPULockScreenMediaControlsView : UIView
- (void)refreshDisposition;
@end
@interface MPUChronologicalProgressView:UIView
@end
@interface MPUMediaControlsTitlesView:UIView
@end
@interface MPUNowPlayingArtworkView:UIView
@end
@interface MusicArtworkView:UIView
@end
@interface MPUTransportControlsView:UIView
@end
@interface NCNotificationListViewController:UICollectionViewController
@end

@interface AspectController : NSObject
@property (nonatomic) BOOL notificationsPresent;
@property (nonatomic) CGRect previousTimeRect;
@property (nonatomic) CGRect previousControlsRect;
@property (nonatomic) CGRect previousTitleRect;
@end

@implementation AspectController
+ (instancetype)sharedInstance{
	static AspectController* privInst = nil;
	if(!privInst){
		privInst = [[AspectController alloc] init];
		privInst.notificationsPresent = NO;
	}
	return privInst;
}
@end

NCNotificationListViewController* notificationController = nil;
void refreshNotificationStatus(){
	BOOL rt = NO;
	if([notificationController collectionView:(UICollectionView*)notificationController numberOfItemsInSection:0])
		rt = YES;

	[AspectController sharedInstance].notificationsPresent = rt;
}

%hook MPUNowPlayingArtworkView
- (void)setFrame:(CGRect)frame{
	if(self.superview.frame.size.height == [UIScreen mainScreen].bounds.size.height){
		CGRect rc = frame;
		rc.origin.y -= frame.size.height/2 + 30;
		%orig(rc);
		return;
	}
	%orig(frame);
}
- (void)setAlpha:(double)alpha{
	if(self.superview.frame.size.height == [UIScreen mainScreen].bounds.size.height){
		%orig(1.0);
		return;
	}
	%orig(alpha);
}
%end

%hook MPULockScreenMediaControlsView

- (instancetype)init{
	id rt = %orig();
	[[NSNotificationCenter defaultCenter] addObserver:rt
	        selector:@selector(refreshDisposition) 
	        name:@"refresh.lock"
	        object:nil];
	return rt;
}

%new
- (void)refreshDisposition{
	LOG("Refreshing...");
	[self layoutSubviews];
}

-(void)layoutSubviews{
	%orig;

	refreshNotificationStatus();

	UIView* volumeView = MSHookIvar<MPUMediaControlsVolumeView *>(self, "_volumeView");
	UIView* timeView = MSHookIvar<MPUChronologicalProgressView *>(self, "_timeView");
	UIView* titlesView = MSHookIvar<MPUMediaControlsTitlesView *>(self, "_titlesView");
	UIView* transportControls = MSHookIvar<MPUTransportControlsView *>(self, "_transportControls");

	volumeView.alpha = .0f;

	CGRect newVolumeRect = volumeView.frame;
	CGRect newTimeRect = timeView.frame;
	CGRect newTitlesRect = titlesView.frame;
	CGRect newControlsRect = transportControls.frame;

	AspectController* aspect = [AspectController sharedInstance];
	BOOL rt = NO;
	if(aspect.previousTimeRect.origin.y == timeView.frame.origin.y)rt=YES;
	//Setup 
	timeView.frame = (aspect.previousTimeRect.size.width) ? aspect.previousTimeRect : timeView.frame;
	transportControls.frame = (aspect.previousControlsRect.size.width) ? aspect.previousControlsRect : transportControls.frame;
	titlesView.frame = (aspect.previousTitleRect.size.width) ? aspect.previousTitleRect : titlesView.frame;
	// --
	if(rt)return;
	

	if([AspectController sharedInstance].notificationsPresent){
		newVolumeRect.origin.y = -100;
		newTimeRect.origin.y = 120;
		newTitlesRect.origin.y = 30;
		newTitlesRect.origin.x = newTitlesRect.size.width/2-20;
		newTitlesRect.size.width /= 2;
		newTitlesRect.size.width += 20;
		newControlsRect.origin.y = 60;
		newControlsRect.origin.x = (newControlsRect.size.width*3)/4;
		newControlsRect.size.width = (newControlsRect.size.width*3)/4;
	}else{
		newVolumeRect.origin.y = [UIScreen mainScreen].bounds.size.height+100;
		newTimeRect.origin.y = [UIScreen mainScreen].bounds.size.height-100-100;
		newTitlesRect.origin.y = [UIScreen mainScreen].bounds.size.height-100-120-50;
		newControlsRect.origin.y = [UIScreen mainScreen].bounds.size.height-150;
	}



	[UIView setAnimationsEnabled:NO];

	timeView.alpha = .0f;
	transportControls.alpha = .0f;
	titlesView.alpha = .0f;

	transportControls.frame = newControlsRect;
	volumeView.frame = newVolumeRect;
	timeView.frame = newTimeRect;
	titlesView.frame = newTitlesRect;

	[UIView setAnimationsEnabled:YES];
	[UIView setAnimationDuration:.4f];
	timeView.alpha = 1.0f;
	transportControls.alpha = 1.0f;
	titlesView.alpha = 1.0f;

	aspect.previousTitleRect = titlesView.frame;
	aspect.previousControlsRect = transportControls.frame;
	aspect.previousTimeRect = timeView.frame;

}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	UIView* transportControls = MSHookIvar<MPUTransportControlsView *>(self, "_transportControls");
    CGPoint pointInControls = [transportControls convertPoint:point fromView:self];
    if (CGRectContainsPoint(transportControls.bounds, pointInControls)) {
        return [transportControls hitTest:pointInControls withEvent:event];
    }
    return %orig(point,event);
}

%end

%hook SBDashBoardNotificationListViewController
-(void)loadView{
	%orig();
	NCNotificationListViewController* listView = MSHookIvar<NCNotificationListViewController *>(self, "_listViewController");
	if(![notificationController isEqual:listView])
		notificationController = listView;
}
%end

%hook NCNotificationListViewController
-(void)collectionView:(id)arg1 performUpdatesAlongsideLayout:(id)arg2{
	%orig(arg1,arg2);
	[[NSNotificationCenter defaultCenter] 
        postNotificationName:@"refresh.lock" 
        object:nil];
}
%end
