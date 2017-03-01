#import <UIKit/UIKit.h>

@interface YoloViewController : UIViewController{
    BOOL hasBeenSetup;
}

@property (nonatomic,weak) UIView* shadowView;
@property (nonatomic,weak) UIView* activityContainerView;
@property (nonatomic,weak) UIView* cancelViewContainer;
@property (nonatomic,weak) UIVisualEffectView* cancelView;
@property (nonatomic,weak) UIVisualEffectView* likeDislikeView;
@property (nonatomic,weak) UIVisualEffectView* dummyView;
@property (nonatomic,weak) UIView* upperContainer;
@property (nonatomic,weak) UIButton* cancelLabel;
@property (nonatomic,weak) UIButton* hearth;
@property (nonatomic,weak) UIButton* linedHearth;
@property (nonatomic) unsigned int selectedHearth;
@end

