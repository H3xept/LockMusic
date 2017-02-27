#import <rocketbootstrap/rocketbootstrap.h>

#include "LLIPC.h"
#include "LLLog.h"

#define __DBG__ 
#ifdef __DBG__
#define LOG(X) LLLogPrint((char*)X)
#else
#define LOG(X)
#endif

#define BUNDLEPATH @"/Library/PreferenceBundles/lockmusicprefs.bundle"

static NSMutableDictionary *preferences = nil;
static CFStringRef applicationID = (__bridge CFStringRef)@"com.fl00d.lockmusicprefs";

static void LoadPreferences();

%ctor{

    assert(lllog_register_service("net.jndok.logserver") == 0);

	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL,
	                              	(CFNotificationCallback)LoadPreferences,
	                               	(__bridge CFStringRef)@"LockMusicPrefsChangedNotification",
	                               	NULL,
	                               	CFNotificationSuspensionBehaviorDeliverImmediately);
	        LoadPreferences();
	    });

}

BOOL isEnabled(void)
{	
	BOOL rt =  (preferences) ? [preferences[@"kEnabled"] boolValue] : NO;
	return rt;
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
- (void)fakeSetFrame:(CGRect)frame;
- (void)refreshDisposition;
@end
@interface MusicArtworkView:UIView
@end
@interface MPUTransportControlsView:UIView
@end
@interface NCNotificationListViewController:UICollectionViewController
@end

@interface SBMediaController:NSObject
+(id)sharedInstance;
-(BOOL)likeTrack;
-(BOOL)banTrack;
- (id)_nowPlayingInfo;
-(BOOL)changeTrack:(int)arg1;
@end

@interface AspectController : NSObject
@property (nonatomic) BOOL notificationsPresent;
@property (nonatomic) CGRect previousTimeRect;
@property (nonatomic) CGRect previousControlsRect;
@property (nonatomic) CGRect previousTitleRect;
@property (nonatomic) CGRect previousArtworkRect;
@property (nonatomic,strong) MPUNowPlayingArtworkView* artwork;
@property (nonatomic,strong) UIButton* button;
@property (nonatomic) CGRect originalArtworkSize;
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

static void LoadPreferences() {
    if (CFPreferencesAppSynchronize(applicationID)) {
        CFArrayRef keyList = CFPreferencesCopyKeyList(applicationID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
        if (keyList) {
            preferences = [(NSDictionary *)CFPreferencesCopyMultiple(keyList, applicationID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost) mutableCopy];
            CFRelease(keyList);
        }
    }
}

void refreshNotificationStatus(){
	BOOL rt = NO;
	if([notificationController collectionView:(UICollectionView*)notificationController numberOfItemsInSection:0])
		rt = YES;
	[AspectController sharedInstance].notificationsPresent = rt;
}

%hook MPUNowPlayingArtworkView

- (void)layoutSubviews{
	%orig;
	if(self.superview.frame.size.height == [UIScreen mainScreen].bounds.size.height){
		if(![AspectController sharedInstance].artwork)[AspectController sharedInstance].artwork = self;
	}
}

%new
- (void)fakeSetFrame:(CGRect)frame{
	if(isEnabled()){
		[UIView setAnimationsEnabled:NO];
		[self setFrame:frame];
		[UIView setAnimationsEnabled:YES];
	}
}

- (void)setFrame:(CGRect)frame{

	BOOL isLockscreen = self.superview.frame.size.height == [UIScreen mainScreen].bounds.size.height;

// --- DISPATCH ONCE -- MUST BE EXECUTED
	if(isLockscreen && frame.size.width > 0){
	static dispatch_once_t onceTokenToGetOriginalFrameForArtwork;
	dispatch_once(&onceTokenToGetOriginalFrameForArtwork, ^{
    [AspectController sharedInstance].originalArtworkSize = frame;
	    });
	}
// ---

	if(!isEnabled()){
		__unused CGRect _frame = (isLockscreen) ? [AspectController sharedInstance].originalArtworkSize : frame;
		%orig(_frame);
		return;
	}

	if(isLockscreen){
		if(![AspectController sharedInstance].artwork) [AspectController sharedInstance].artwork = self;
		CGRect rc = frame;
		if([AspectController sharedInstance].notificationsPresent){
			rc.origin = CGPointMake(20,40);
			rc.size = CGSizeMake(120,120);
		}else{
			rc.origin.y -= frame.size.height/2 + 68;
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

    if (!isEnabled()) {
        %orig(alpha);
        return;
    }

	if(self.superview.frame.size.height == [UIScreen mainScreen].bounds.size.height){
		%orig(1.0);
		return;
	}
	%orig(alpha);
}
%end

%hook SBDashBoardView

%new
- (void)musicButtonPressed{

#define belloColor [UIColor colorWithRed:1.00 green:0.18 blue:0.33 alpha:1.0]

    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    [actionSheet addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

    }]];

	UIAlertAction* shuffle = [UIAlertAction actionWithTitle:@"Next shuffle track" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[[objc_getClass("SBMediaController") sharedInstance] changeTrack:6];
	}];
    [actionSheet addAction:shuffle];

    UIAlertAction* like = [UIAlertAction actionWithTitle:@"Like" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[[objc_getClass("SBMediaController") sharedInstance] likeTrack];
    }];
    [like setValue:[[UIImage alloc] initWithContentsOfFile:[[[NSBundle alloc] initWithPath:BUNDLEPATH] pathForResource:@"Hearth" ofType:@"png"]] forKey:@"image"];
    [like setValue:belloColor forKey:@"imageTintColor"];
    [actionSheet addAction:like];

	UIAlertAction* dislike = [UIAlertAction actionWithTitle:@"Dislike" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[[objc_getClass("SBMediaController") sharedInstance] banTrack];
	}];
    [dislike setValue:belloColor forKey:@"imageTintColor"];
    [dislike setValue:[[UIImage alloc] initWithContentsOfFile:[[[NSBundle alloc] initWithPath:BUNDLEPATH] pathForResource:@"Hearth_Line" ofType:@"png"]] forKey:@"image"];
    [actionSheet addAction:dislike];

	[[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:actionSheet animated:YES completion:nil];

}

-(void)layoutSubviews{
	%orig;

    if (!isEnabled()) {
        return;
    }
    if(![AspectController sharedInstance].button.superview){
		UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
		UIScrollView* scroll = MSHookIvar<UIScrollView *>(self, "_scrollView");
		[button setImage:[[UIImage alloc] initWithContentsOfFile:[[[NSBundle alloc] initWithPath:BUNDLEPATH] pathForResource:@"Group" ofType:@"png"]] forState:UIControlStateNormal];
		button.frame = CGRectMake([UIScreen mainScreen].bounds.size.width*2-(48), [UIScreen mainScreen].bounds.size.height-(24), 48.0f, 24.0f);

		button.contentMode = UIViewContentModeBottom;
		[scroll addSubview:button];
		[button addTarget:self
		             action:@selector(musicButtonPressed)
		   forControlEvents:UIControlEventTouchUpInside];
		button.hidden = YES;
		[AspectController sharedInstance].button = button;
	}
}

%end

@interface MPUNowPlayingController:NSObject
-(BOOL)isPlaying;
@end

%hook MPULockScreenMediaControlsViewController

- (void)viewWillAppear:(BOOL)animated{
	%orig(animated);
	[AspectController sharedInstance].button.hidden = ![[objc_getClass("SBMediaController") sharedInstance]isPlaying];
	[UIView setAnimationsEnabled:NO];
	[[AspectController sharedInstance].artwork setFrame:[AspectController sharedInstance].originalArtworkSize];
	[UIView setAnimationsEnabled:YES];
}

-(void)nowPlayingController:(id)arg1 playbackStateDidChange:(BOOL)arg2{
	%orig(arg1,arg2);

    if (!isEnabled()) {
        return;
    }

	if(arg2){
		[AspectController sharedInstance].button.hidden = NO;
	}else{
		[AspectController sharedInstance].button.hidden = YES;
	}
}
%end

%hook MPULockScreenMediaControlsView

- (instancetype)init{
	id rt = %orig();

    if (!isEnabled()) {
        return rt;
    }

	[[NSNotificationCenter defaultCenter] addObserver:rt
	        selector:@selector(refreshDisposition)
	        name:@"refresh.lock"
	        object:nil];
	return rt;
}

%new
- (void)refreshDisposition{
	[self layoutSubviews];
}

-(void)layoutSubviews{
	%orig;

    if (!isEnabled()) {
    	UIView* volumeView = MSHookIvar<MPUMediaControlsVolumeView *>(self, "_volumeView");
    	volumeView.alpha = 1.0f;
        return;
    }

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
	const char* str = [[NSString stringWithFormat:@"%f - %f",newTitlesRect.origin.y,titlesView.frame.origin.y] UTF8String];
	LOG(str);
	if(newTitlesRect.origin.y == titlesView.frame.origin.y) return;
	[[AspectController sharedInstance].artwork fakeSetFrame:CGRectZero];
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

    if (!isEnabled()) {
        return %orig(point, event);
    }

	UIView* transportControls = MSHookIvar<MPUTransportControlsView *>(self, "_transportControls");
    CGPoint pointInControls = [transportControls convertPoint:point fromView:self];
    if (CGRectContainsPoint(transportControls.bounds, pointInControls)) {
        return [transportControls hitTest:pointInControls withEvent:event];
    }

	UIView* timeView = MSHookIvar<MPUTransportControlsView *>(self, "_timeView");
    CGPoint pointInTime = [timeView convertPoint:point fromView:self];
    if (CGRectContainsPoint(timeView.bounds, pointInTime)) {
        return [timeView hitTest:pointInTime withEvent:event];
    }

    return %orig(point,event);
}

%end

%hook SBDashBoardNotificationListViewController
-(void)loadView{
	%orig();

    if (!isEnabled()) {
        return;
    }

	NCNotificationListViewController* listView = MSHookIvar<NCNotificationListViewController *>(self, "_listViewController");
	if(![notificationController isEqual:listView])
		notificationController = listView;
}
%end

%hook NCNotificationListViewController
-(void)collectionView:(id)arg1 performUpdatesAlongsideLayout:(id)arg2{
	%orig(arg1,arg2);

    if (!isEnabled()) {
        return;
    }

	[[NSNotificationCenter defaultCenter]
        postNotificationName:@"refresh.lock"
        object:nil];
}

%end

