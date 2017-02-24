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
@end
@interface MPUChronologicalProgressView:UIView
@end
@interface MPUMediaControlsTitlesView:UIView
@end
@interface MPUNowPlayingArtworkView:UIView
@end
@interface MusicArtworkView:UIView
@end

%hook MPUNowPlayingArtworkView
- (void)setFrame:(CGRect)frame{
	if(self.superview.frame.size.height == [UIScreen mainScreen].bounds.size.height){
		CGRect rc = CGRectMake(0,0,100,100);
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

-(void)layoutSubviews{
	%orig;

	UIView* volumeView = MSHookIvar<MPUMediaControlsVolumeView *>(self, "_volumeView");
	UIView* timeView = MSHookIvar<MPUChronologicalProgressView *>(self, "_timeView");
	UIView* titlesView = MSHookIvar<MPUMediaControlsTitlesView *>(self, "_titlesView");
	CGRect newVolumeRect = volumeView.frame;
	newVolumeRect.origin.y = [UIScreen mainScreen].bounds.size.height+100;
	CGRect newTimeRect = timeView.frame;
	newTimeRect.origin.y = [UIScreen mainScreen].bounds.size.height-100-50;
	CGRect newTitlesRect = titlesView.frame;
	newTitlesRect.origin.y = [UIScreen mainScreen].bounds.size.height-100-100;
	volumeView.frame = newVolumeRect;
	timeView.frame = newTimeRect;
	titlesView.frame = newTitlesRect;
}
%end
