#import <rocketbootstrap/rocketbootstrap.h>
#import "YoloViewController.h"
#import "SharedHelper.h"
#import "FakeInterfaces.h"

#include "LLIPC.h"
#include "LLLog.h"

#define __DBG__

#ifdef __DBG__
#define ASSERTALO assert(lllog_register_service("net.jndok.logserver") == 0)
#define LOG(X) LLLogPrint((char*)X)
#define FLOG(X) LLLogPrint((char*)[[NSString stringWithFormat:@"%f",X] UTF8String])
#define BLOG(X) LLLogPrint((char*)[[NSString stringWithFormat:@"%d",X] UTF8String])
#define DLOG(X) LLLogPrint((char*)[[NSString stringWithFormat:@"%lld",X] UTF8String])
#define FRLOG(X) LLLogPrint((char*)[[NSString stringWithFormat:@"%@",NSStringFromCGRect(X)] UTF8String])
#else
#define LOG(X)
#define ASSERTALO
#define FLOG(X)
#define BLOG(X)
#define FRLOG(X)
#endif

#define BUNDLEPATH @"/Library/PreferenceBundles/lockmusicprefs.bundle"

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))
#define IS_ZOOMED (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH >= 736.0)

static NSMutableDictionary *preferences = nil;
static CFStringRef applicationID = (__bridge CFStringRef)@"com.fl00d.lockmusicprefs";
NCNotificationListViewController* notificationController = nil;

static void LoadPreferences();

%ctor{

    ASSERTALO;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL,
	                              	(CFNotificationCallback)LoadPreferences,
	                               	(__bridge CFStringRef)@"LockMusicPrefsChangedNotification",
	                               	NULL,
	                               	CFNotificationSuspensionBehaviorDeliverImmediately);
	    });
    LoadPreferences();

}

// preferences checks
BOOL isEnabled(void){BOOL rt =  (preferences) ? [preferences[@"kEnabled"] boolValue] : YES;return rt;}
BOOL threeDotsEnabled(void){BOOL rt = (preferences) ? [preferences[@"kDotsEnabled"] boolValue] : YES;return rt;}
unsigned int threeDotsPositioning(void){BOOL rt = (preferences) ? [preferences[@"kDotsPositioning"] integerValue] : 1;return rt;}
BOOL volumeSliderEnabledForMode0(void){return (preferences) ? [preferences[@"kVolumeSliderEnabledMode0"] boolValue] : NO;}
BOOL volumeSliderEnabledForMode1(void){return (preferences) ? [preferences[@"kVolumeSliderEnabledMode1"] boolValue] : NO;}
unsigned int styleForNoNotification(void){return (preferences) ? [preferences[@"kNoNotificationStyle"] integerValue] : 1;}
unsigned int styleForNotification(void){return (preferences) ? [preferences[@"kNotificationStyle"] integerValue] : 1;}
// --

@interface AspectController : NSObject
@property (nonatomic) BOOL notificationsPresent;
@property (nonatomic) CGRect previousTimeRect;
@property (nonatomic) CGRect previousControlsRect;
@property (nonatomic) CGRect previousTitleRect;
@property (nonatomic) CGRect previousVolumeRect;
@property (nonatomic) CGRect previousArtworkRect;
@property (nonatomic,strong) MPUNowPlayingArtworkView* artwork;
@property (nonatomic,strong) UIButton* button;
@property (nonatomic) CGRect originalArtworkSize;
@property (nonatomic,strong) SBMainScreenAlertWindowViewController* presentationVC;
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

static void LoadPreferences() {
    if (CFPreferencesAppSynchronize(applicationID)) {
        CFArrayRef keyList = CFPreferencesCopyKeyList(applicationID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
        if (keyList) {
            preferences = [(NSDictionary *)CFPreferencesCopyMultiple(keyList, applicationID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost) mutableCopy];
            CFRelease(keyList);
        }
    }

	[[NSNotificationCenter defaultCenter]
        postNotificationName:@"refresh.lock"
        object:nil];
}

void refreshNotificationStatus(){
	BOOL rt = NO;
	if([notificationController collectionView:(UICollectionView*)notificationController numberOfItemsInSection:0])
		rt = YES;
	[AspectController sharedInstance].notificationsPresent = rt;
}

%hook SBMainScreenAlertWindowViewController
-(void)loadView{
	[AspectController sharedInstance].presentationVC = self;
	%orig();
}
%end

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

	if(!isEnabled()) {
		__unused CGRect _frame = (isLockscreen) ? [AspectController sharedInstance].originalArtworkSize : frame;
		%orig(_frame);
		return;
	}

	if(isLockscreen) {
		if(![AspectController sharedInstance].artwork) [AspectController sharedInstance].artwork = self;
		CGRect rc = frame;
		if([AspectController sharedInstance].notificationsPresent){
			rc.origin = CGPointMake(20,40);
			rc.size = CGSizeMake(120,120);
		}else{
			if(IS_IPHONE_5){
				rc.origin.y -= frame.size.height/2 + 68;
			}else if(IS_IPHONE_6){
				rc.origin.y -= frame.size.height/2 + 38;
			}else if(IS_IPHONE_6P){
				rc.origin.y -= frame.size.height/2 + 38;
			}
			
		}
		if([AspectController sharedInstance].previousArtworkRect.origin.y == rc.origin.y)
			return;
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
	if([SharedHelper sharedInstance].isMusicApp){
		YoloViewController* yoloVC = [[YoloViewController alloc] init];
		[yoloVC setModalPresentationStyle:UIModalPresentationOverCurrentContext];
		[[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:yoloVC animated:NO completion:nil];
		[SharedHelper sharedInstance].panelActive = YES;
	}
}

-(void)layoutSubviews{
	%orig;
    if (!isEnabled()) {
        return;
    }
    if(![AspectController sharedInstance].button.superview && threeDotsEnabled()){
		UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
		UIScrollView* scroll = MSHookIvar<UIScrollView *>(self, "_scrollView");
		[button setImage:[[UIImage alloc] initWithContentsOfFile:[[[NSBundle alloc] initWithPath:BUNDLEPATH] pathForResource:@"Group" ofType:@"png"]] forState:UIControlStateNormal];
		
		CGRect dotsRect;
		if(scroll.contentSize.width == [UIScreen mainScreen].bounds.size.width*3) { // Complete 3 screens
			dotsRect = (threeDotsPositioning()) ? 
				CGRectMake(([UIScreen mainScreen].bounds.size.width*2)-(48), [UIScreen mainScreen].bounds.size.height-(24), 48.0f, 24.0f):
				CGRectMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-(24), 48.0f, 24.0f);
		}else {
			dotsRect = (threeDotsPositioning()) ? 
				CGRectMake(([UIScreen mainScreen].bounds.size.width)-(48), [UIScreen mainScreen].bounds.size.height-(24), 48.0f, 24.0f):
				CGRectMake(0, [UIScreen mainScreen].bounds.size.height-(24), 48.0f, 24.0f);
		}
		
		button.frame = dotsRect;
		button.contentMode = UIViewContentModeBottom;
		[scroll addSubview:button];
		[button addTarget:self
		             action:@selector(musicButtonPressed)
		   forControlEvents:UIControlEventTouchUpInside];
		[AspectController sharedInstance].button = button;
	}

	if([[objc_getClass("SBMediaController") sharedInstance] isPlaying]){
		if([SharedHelper sharedInstance].isMusicApp){
			[AspectController sharedInstance].button.hidden = NO;
		}else [AspectController sharedInstance].button.hidden = YES;
	}else [AspectController sharedInstance].button.hidden = YES;}

%end

%hook MPULockScreenMediaControlsViewController

- (void)viewWillAppear:(BOOL)animated {
	%orig(animated);

	[UIView setAnimationsEnabled:NO];
	[[AspectController sharedInstance].artwork setFrame:[AspectController sharedInstance].originalArtworkSize];
	[UIView setAnimationsEnabled:YES];

    if (!isEnabled()) {
        return;
    }

	if([[objc_getClass("SBMediaController") sharedInstance] isPlaying]){
		if([SharedHelper sharedInstance].isMusicApp){
			[AspectController sharedInstance].button.hidden = NO;
		}else [AspectController sharedInstance].button.hidden = YES;
	}else [AspectController sharedInstance].button.hidden = YES;

}

-(void)nowPlayingController:(id)arg1 playbackStateDidChange:(BOOL)arg2{
	%orig(arg1,arg2);

    if (!isEnabled()) {
        return;
    }

	if(arg2){
		if([SharedHelper sharedInstance].isMusicApp){
			[AspectController sharedInstance].button.hidden = NO;
		}else [AspectController sharedInstance].button.hidden = YES;
	}else [AspectController sharedInstance].button.hidden = YES;

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
- (void)refreshDisposition{[self layoutSubviews];}

-(void)layoutSubviews{
	%orig;

    if (!isEnabled()) {
    	UIView* volumeView = MSHookIvar<MPUMediaControlsVolumeView *>(self, "_volumeView");
    	volumeView.alpha = 1.0f;
        return;
    }

    BOOL fakeNotificationPresent = NO;;
    __unused unsigned int style = 1;
  //   if([AspectController sharedInstance].notificationsPresent){
  //   	LOG("NOTIFICATION");
  //   	style = styleForNotification();
  //   	BLOG(style);
		// switch(style) {
		// 	case 0: //Default
		// 		return;
		// 		break;
		// 	case 1: //LockMusic - Default
		// 		break;
		// 	default:
		// 		break;
		// }

  //   }else{
  //   	LOG("NO NOTIFICATION");
	 //    style = styleForNoNotification();
	 //    BLOG(style);

		// switch(style) {
		// 	case 0: //Default
		// 		return;
		// 		break;
		// 	case 1: //LockMusic - Default
		// 		break;
		// 	case 2: //LockMusic - Shrunk
		// 		fakeNotificationPresent = YES;
		// 		break;
		// 	default:
		// 		break;
		// }
  //   }

	refreshNotificationStatus();

	UIView* volumeView = MSHookIvar<MPUMediaControlsVolumeView *>(self, "_volumeView");
	UIView* timeView = MSHookIvar<MPUChronologicalProgressView *>(self, "_timeView");
	UIView* titlesView = MSHookIvar<MPUMediaControlsTitlesView *>(self, "_titlesView");
	UIView* transportControls = MSHookIvar<MPUTransportControlsView *>(self, "_transportControls");

	CGRect newVolumeRect = volumeView.frame;
	CGRect newTimeRect = timeView.frame;
	CGRect newTitlesRect = titlesView.frame;
	CGRect newControlsRect = transportControls.frame;

	AspectController* aspect = [AspectController sharedInstance];
	BOOL rt = NO;
	if(aspect.previousTimeRect.origin.y == timeView.frame.origin.y)rt=YES;
	if(rt)return;

	double volumeModifier = (volumeSliderEnabledForMode1()||volumeSliderEnabledForMode0()) ? volumeView.bounds.size.height+8.0f:.0f;
	double volumeScreenHeightDelta = (volumeSliderEnabledForMode0()) ? -156+volumeModifier:.0f;
	double controlsVolumeModifier = (volumeSliderEnabledForMode0()) ? 18.0f:.0f;

	if([AspectController sharedInstance].notificationsPresent){
fakeNotificationPresent_:
		[UIView setAnimationsEnabled:NO];
		volumeView.alpha = (volumeSliderEnabledForMode1()) ? 1.0f:.0f;
		[UIView setAnimationsEnabled:YES];

		if(IS_IPHONE_5){
			newVolumeRect.origin.y = volumeModifier+144;
			newTimeRect.origin.y = 154;
		}else{
			newVolumeRect.origin.y = volumeModifier+150;
			newTimeRect.origin.y = 160;
		}
		newTitlesRect.origin.y = 30;
		newTitlesRect.origin.x = 120+10-5;
		newTitlesRect.size.width = [UIScreen mainScreen].bounds.size.width-120-40;
		newControlsRect.origin.y = 90;
		newControlsRect.size.width = newTitlesRect.size.width-20;
		newControlsRect.origin.x = [UIScreen mainScreen].bounds.size.width-(newTitlesRect.size.width/2 + newControlsRect.size.width/2 + 30+5);
	}else{
		if(fakeNotificationPresent) goto fakeNotificationPresent_;
		[UIView setAnimationsEnabled:NO];
		volumeView.alpha = (volumeSliderEnabledForMode0()) ? 1.0f:.0f;
		[UIView setAnimationsEnabled:YES];

		newTimeRect.origin.y = [UIScreen mainScreen].bounds.size.height-100-100;
		newTitlesRect.origin.y = [UIScreen mainScreen].bounds.size.height-100-120-50;
		newControlsRect.origin.y = [UIScreen mainScreen].bounds.size.height-(150+controlsVolumeModifier);
		newVolumeRect.origin.y = [UIScreen mainScreen].bounds.size.height+volumeScreenHeightDelta;
	}


	//Setup
	timeView.frame = (aspect.previousTimeRect.size.width) ? aspect.previousTimeRect : timeView.frame;
	titlesView.frame = (aspect.previousTitleRect.size.width) ? aspect.previousTitleRect : titlesView.frame;
	volumeView.frame = (aspect.previousVolumeRect.size.width) ? aspect.previousVolumeRect : volumeView.frame;
	transportControls.frame = (aspect.previousControlsRect.size.width) ? aspect.previousControlsRect : transportControls.frame;
	// --

	aspect.previousTitleRect = newTitlesRect;
	aspect.previousControlsRect = newControlsRect;
	aspect.previousTimeRect = newTimeRect;
	aspect.previousVolumeRect = newVolumeRect;

	[[AspectController sharedInstance].artwork fakeSetFrame:CGRectZero];

	if(newTitlesRect.origin.y == titlesView.frame.origin.y) return;

	
	[UIView setAnimationsEnabled:NO];

	timeView.alpha = .0f;
	transportControls.alpha = .0f;
	titlesView.alpha = .0f;
	volumeView.alpha = .0f;

	transportControls.frame = newControlsRect;
	volumeView.frame = newVolumeRect;
	timeView.frame = newTimeRect;
	titlesView.frame = newTitlesRect;

	[UIView setAnimationsEnabled:YES];
	[UIView setAnimationDuration:.25f];
	timeView.alpha = 1.0f;
	transportControls.alpha = 1.0f;
	titlesView.alpha = 1.0f;
	if(([AspectController sharedInstance].notificationsPresent && volumeSliderEnabledForMode1()) || (![AspectController sharedInstance].notificationsPresent && volumeSliderEnabledForMode0()))
		volumeView.alpha = 1.0f;

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

	UIView* volumeView = MSHookIvar<MPUTransportControlsView *>(self, "_volumeView");
    CGPoint pointInVolume = [volumeView convertPoint:point fromView:self];
    if (CGRectContainsPoint(volumeView.bounds, pointInVolume)) {
        return [volumeView hitTest:pointInVolume withEvent:event];
    }

    return %orig(point,event);
}

%end

%hook SBDashBoardNotificationListViewController
-(void)loadView {
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
-(void)collectionView:(id)arg1 performUpdatesAlongsideLayout:(id)arg2 {
	%orig(arg1,arg2);

    if (!isEnabled()) {
    	return;
    }
	[[NSNotificationCenter defaultCenter]
        postNotificationName:@"refresh.lock"
        object:nil];
}
%end

%hook MPUTransportControlMediaRemoteController
-(void)_updateLikedState
{
    %orig();
    if([self likedState] != [SharedHelper sharedInstance].songState){
    	[SharedHelper sharedInstance].songState = [self likedState];
    	[[SharedHelper sharedInstance] notifyPaneOfSongStateUpdate];
    }
}
%end

%hook SBBacklightController
-(void)_animateBacklightToFactor:(float)factor duration:(double)duration source:(int)source silently:(BOOL)silently completion:(id)completion {
	if(factor > 0){
		%orig;
	}else if(![SharedHelper sharedInstance].panelActive){
		[AspectController sharedInstance].button.hidden = YES;
		%orig;
	}
}
%end

%hook MPUNowPlayingMetadata
- (BOOL)isMusicApp {
	BOOL rt = %orig;
	[SharedHelper sharedInstance].isMusicApp = rt;
	return rt;
}
%end