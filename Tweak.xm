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
%hook MPULockScreenMediaControlsViewController

-(void)viewWillLayoutSubviews
{
	%orig;
	MPUNowPlayingArtworkView* artworkView = MSHookIvar<MPUNowPlayingArtworkView *>(self, "_artworkView");
	CGRect newArtworkFrame = artworkView.frame;
	newArtworkFrame.origin.y = 0;
	artworkView.frame = newArtworkFrame;
	const char* str = [[NSString stringWithFormat:@"%f",artworkView.alpha] UTF8String];
	LOG(str);
}

%end

@interface MusicArtworkView:UIView
@end

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
%hook MPULockScreenMediaControlsViewController
-(void)viewDidLoad{
	%orig;

	UIView* artWork = MSHookIvar<UIView *>(self, "_artworkView");
	CGRect newArtworkRect = artWork.frame;
	newArtworkRect.origin.y = [UIScreen mainScreen].bounds.size.height-100-70-200;
	artWork.frame = newArtworkRect;
}
%end