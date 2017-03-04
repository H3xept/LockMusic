@interface SharedHelper : NSObject
@property (nonatomic) long long songState;
@property (nonatomic,weak) id likeDislikePane;
@property (nonatomic) BOOL panelActive;
@property (nonatomic) BOOL isMusicApp;
+ (instancetype)sharedInstance;
- (void)notifyPaneOfSongStateUpdate;
@end