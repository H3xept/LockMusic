#import <UIKit/UIKit.h>

@interface YoloViewController : UIViewController{
    BOOL hasBeenSetup;
}

@property (nonatomic,strong) UIView* shadowView;
@property (nonatomic,strong) UIView* activityContainerView;
@property (nonatomic,strong) UIVisualEffectView* cancelView;
@property (nonatomic,strong) UIVisualEffectView* likeDislikeView;
@property (nonatomic,strong) UIVisualEffectView* dummyView;
@property (nonatomic,strong) UIButton* cancelLabel;
@property (nonatomic,strong) UIButton* hearth;
@property (nonatomic,strong) UIButton* linedHearth;
@property (nonatomic) unsigned int selectedHearth;
@end

