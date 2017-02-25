#include <rocketbootstrap/rocketbootstrap.h>

#include "./tools/LLIPC.h"
#include "./tools/LLLog.h"

#define __DBG__

#ifdef __DBG__
#define LOG(X) LLLogPrint((char *)X);
#else
#define LOG(X)
#endif

#define BUNDLEPATH @"/Library/PreferenceBundles/lockmusicprefs.bundle"

static NSMutableDictionary *preferences = nil;
static CFStringRef applicationID = (__bridge CFStringRef)@"com.fl00d.lockmusicprefs";

static void LoadPreferences() {
    if (CFPreferencesAppSynchronize(applicationID)) {
        CFArrayRef keyList = CFPreferencesCopyKeyList(applicationID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
        if (keyList) {
            preferences = [(NSDictionary *)CFPreferencesCopyMultiple(keyList, applicationID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost) mutableCopy];
            CFRelease(keyList);
        }
    }
}

%ctor{
	assert(lllog_register_service("net.jndok.logserver") == 0);

	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL,
	                              	(CFNotificationCallback)LoadPreferences,
	                               	(__bridge CFStringRef)@"LockMusicPreferencesChangedNotification",
	                               	NULL,
	                               	CFNotificationSuspensionBehaviorDeliverImmediately);
	        LoadPreferences();
	    });

}

BOOL isEnabled(void)
{
	return (preferences) ? [preferences[@"kEnabled"] boolValue] : NO;
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
- (void)refreshDisposition;
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
@property (nonatomic) CGRect previousArtworkRect;
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

MPUNowPlayingArtworkView* artwork = nil;
%hook MPUNowPlayingArtworkView

- (void)setFrame:(CGRect)frame{

	if(self.superview.frame.size.height == [UIScreen mainScreen].bounds.size.height){
		if(!artwork) artwork = self;
		CGRect rc = frame;
		if([AspectController sharedInstance].notificationsPresent){
			rc.origin = CGPointMake(10,40);
			rc.size = CGSizeMake(120,120);
		}else{
			rc.origin.y -= frame.size.height/2 + 30;
		}
		if([AspectController sharedInstance].previousArtworkRect.origin.y == rc.origin.y){
			return;}
		else {
			[UIView animateWithDuration:.3f
                 animations:^(){
					[UIView setAnimationsEnabled:NO];
					%orig(rc);
					[UIView setAnimationsEnabled:YES];
                 }
                 completion:nil];
		}
		[AspectController sharedInstance].previousArtworkRect = rc;
		return;
	}
	if(frame.size.width != 0)
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


// NSString *string = @"AYyy";

// UIActivityViewController *activityViewController =
//   [[UIActivityViewController alloc] initWithActivityItems:@[string]
//                                     applicationActivities:nil];
// [self presentViewController:activityViewController
//                                       animated:YES
//                                     completion:nil];

%hook SBDashBoardView
-(void)layoutSubviews{
	%orig;

	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	UIScrollView* scroll = MSHookIvar<UIScrollView *>(self, "_scrollView");
	[button setImage:[[UIImage alloc] initWithContentsOfFile:[[[NSBundle alloc] initWithPath:BUNDLEPATH] pathForResource:@"Group@3x" ofType:@"png"]] forState:UIControlStateNormal];
	button.frame = CGRectMake([UIScreen mainScreen].bounds.size.width*2-(36+8), [UIScreen mainScreen].bounds.size.height-(8+8), 36.0, 8.0);
	button.contentMode = UIViewContentModeScaleAspectFit;
	button.layer.masksToBounds = YES;
	button.alpha = .5f;
	[scroll addSubview:button];

}

- (void)drawRect:(CGRect)rect{
	%orig(rect);

static dispatch_once_t onceToken;

#define belloColor [UIColor colorWithRed:1.00 green:0.18 blue:0.33 alpha:1.0]

    dispatch_once (&onceToken, ^{
    
	    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

	    [actionSheet addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

	    }]];	

	    UIAlertAction* like = [UIAlertAction actionWithTitle:@"Like" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
	    [like setValue:[[UIImage alloc] initWithContentsOfFile:[[[NSBundle alloc] initWithPath:BUNDLEPATH] pathForResource:@"Hearth@3x" ofType:@"png"]] forKey:@"image"];
	    [like setValue:belloColor forKey:@"imageTintColor"];
	    [actionSheet addAction:like];

		UIAlertAction* dislike = [UIAlertAction actionWithTitle:@"Dislike" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
	    [dislike setValue:belloColor forKey:@"imageTintColor"];
	    [dislike setValue:[[UIImage alloc] initWithContentsOfFile:[[[NSBundle alloc] initWithPath:BUNDLEPATH] pathForResource:@"Hearth_Line@3x" ofType:@"png"]] forKey:@"image"];
	    [actionSheet addAction:dislike];

		[[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:actionSheet animated:YES completion:nil];
    });

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
		newTimeRect.origin.y = 160;
		newTitlesRect.origin.y = 30;
		newTitlesRect.origin.x = 120+10-5;
		newTitlesRect.size.width = [UIScreen mainScreen].bounds.size.width-120-40;
		newControlsRect.origin.y = 90;
		newControlsRect.size.width = newTitlesRect.size.width-20;
		newControlsRect.origin.x = [UIScreen mainScreen].bounds.size.width-(newTitlesRect.size.width/2 + newControlsRect.size.width/2 + 30+5);
	}else{
		newVolumeRect.origin.y = [UIScreen mainScreen].bounds.size.height+100;
		newTimeRect.origin.y = [UIScreen mainScreen].bounds.size.height-100-100;
		newTitlesRect.origin.y = [UIScreen mainScreen].bounds.size.height-100-120-50;
		newControlsRect.origin.y = [UIScreen mainScreen].bounds.size.height-150;
	}


	[artwork setFrame:CGRectZero];
	[UIView setAnimationsEnabled:NO];

	timeView.alpha = .0f;
	transportControls.alpha = .0f;
	titlesView.alpha = .0f;

	transportControls.frame = newControlsRect;
	volumeView.frame = newVolumeRect;
	timeView.frame = newTimeRect;
	titlesView.frame = newTitlesRect;

	[UIView setAnimationsEnabled:YES];
	[UIView setAnimationDuration:.25f];
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
