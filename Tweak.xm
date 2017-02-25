#include <rocketbootstrap/rocketbootstrap.h>

#include "./tools/LLIPC.h"
#include "./tools/LLLog.h"

#define LOG(X) LLLogPrint((char *)X);

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
	const char* str = [[NSString stringWithFormat:@"%ld",(long)[notificationController collectionView:(UICollectionView*)notificationController numberOfItemsInSection:0]] UTF8String];
	LOG(str);
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

	CGRect newVolumeRect = volumeView.frame;
	CGRect newTimeRect = timeView.frame;
	CGRect newTitlesRect = titlesView.frame;
	CGRect newControlsRect = transportControls.frame;
	
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


	transportControls.frame = newControlsRect;
	volumeView.frame = newVolumeRect;
	timeView.frame = newTimeRect;
	titlesView.frame = newTitlesRect;
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

// - (void)loadView{
// 	%orig();
// 	if(self.view.superview)
// 		notificationController = self;
// }

- (void)deleteItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths{
	LOG("REMOVE");

	%orig(indexPaths);
	[[NSNotificationCenter defaultCenter] 
        postNotificationName:@"refresh.lock" 
        object:nil];
}

-(id)collectionView:(id)arg1 cellForItemAtIndexPath:(id)arg2{

	[[NSNotificationCenter defaultCenter] 
        postNotificationName:@"refresh.lock" 
        object:nil];
	return %orig(arg1,arg2);
}
-(void)clearAll{
	LOG("CLEAR ALL");
	%orig;
	[[NSNotificationCenter defaultCenter] 
        postNotificationName:@"refresh.lock" 
        object:nil];
}
-(void)clearAllNonPersistent{
	LOG("CLEAR NON PERSISTENT");

	%orig;	
	[[NSNotificationCenter defaultCenter] 
        postNotificationName:@"refresh.lock" 
        object:nil];
}
-(void)notificationListCell:(id)arg1 requestsClearingNotificationRequest:(id)arg2{
	LOG("REQUEST CLEAR");

	%orig(arg1,arg2);
	[[NSNotificationCenter defaultCenter] 
        postNotificationName:@"refresh.lock" 
        object:nil];
}
%end
