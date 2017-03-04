#import <UIKit/UIKit.h>

@interface YoloViewController : UIViewController{
    BOOL hasBeenSetup;
}

/* 
1:Nothing
2:Like
3:Dislike
*/
typedef enum{
kLikedStateNone,kLikedStateLike,kLikedStateDislike
}kLikedState;

@property (nonatomic,weak) UIView* shadowView;
@property (nonatomic,weak) UIView* activityContainerView;
@property (nonatomic,weak) UIView* cancelViewContainer;
@property (nonatomic,weak) UIVisualEffectView* cancelView;
@property (nonatomic,weak) UIVisualEffectView* likeDislikeView;
@property (nonatomic,weak) UIVisualEffectView* dummyView;
@property (nonatomic,weak) UIView* upperContainer;
@property (nonatomic,weak) UIButton* cancelLabel;
@property (nonatomic,weak) UIButton* nextShuffleLabel;
@property (nonatomic,weak) UIButton* hearth;
@property (nonatomic,weak) UIButton* linedHearth;
@property (nonatomic) unsigned int selectedHearth;
@property (nonatomic) BOOL isMusicApp;
- (void)receivedStateChange:(kLikedState)newState;
@end

