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
@interface MPUTransportControlsView:UIView
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
	UIView* transportControls = MSHookIvar<MPUTransportControlsView *>(self, "_transportControls");

	CGRect newVolumeRect = volumeView.frame;
	newVolumeRect.origin.y = [UIScreen mainScreen].bounds.size.height+100;
	CGRect newTimeRect = timeView.frame;
	newTimeRect.origin.y = [UIScreen mainScreen].bounds.size.height-100-100;
	CGRect newTitlesRect = titlesView.frame;
	CGRect newControlsRect = transportControls.frame;
	newControlsRect.origin.y = [UIScreen mainScreen].bounds.size.height-100;
	transportControls.frame = newControlsRect;
	newTitlesRect.origin.y = [UIScreen mainScreen].bounds.size.height-100-120-50;
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
