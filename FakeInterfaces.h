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
@interface SBMainScreenAlertWindowViewController:UIViewController
@end
@interface SBBacklightController : NSObject
+ (instancetype)sharedInstance;
-(void)resetLockScreenIdleTimer;
@end
@interface MPUTransportControlMediaRemoteController:NSObject
- (long long)likedState;
@end
@interface SBMediaController:NSObject
+(id)sharedInstance;
-(BOOL)likeTrack;
-(BOOL)banTrack;
- (id)_nowPlayingInfo;
-(BOOL)changeTrack:(int)arg1;
- (BOOL)isPlaying;
@end
@interface MPUNowPlayingController:NSObject
-(BOOL)isPlaying;
@end