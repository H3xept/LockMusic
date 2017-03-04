#import "YoloViewController.h"
#import <objc/runtime.h>
#import "SharedHelper.h"

#define BUNDLEPATH @"/Library/PreferenceBundles/lockmusicprefs.bundle"
#define ios10Blue [UIColor colorWithRed:0.00 green:0.48 blue:1.00 alpha:1.0]

@interface SBMediaController:NSObject
+(id)sharedInstance;
-(BOOL)likeTrack;
-(BOOL)banTrack;
- (id)_nowPlayingInfo;
-(BOOL)changeTrack:(int)arg1;
- (BOOL)isPlaying;
@end

@interface UIView (RoundedCorners)

- (void)setRoundedCorners:(UIRectCorner)corners radius:(CGSize)size;

@end

@implementation UIView (RoundedCorners)

- (void)setRoundedCorners:(UIRectCorner)corners radius:(CGSize)size {
    [self.layer setCornerRadius:size.height];
    self.layer.masksToBounds = YES;
}

@end

@interface UIButton (ActivateDeactivate)
@property (nonatomic,strong) UIImage* activatedImage;
@property (nonatomic,strong) UIImage* deactivatedImage;
- (void)activate;
- (void)deactivate;
@end

@implementation UIButton (ActivateDeactivate)

- (void)setActivatedImage:(nonnull UIImage *)activatedImage {
    objc_setAssociatedObject(self, @"activatedImage", activatedImage, OBJC_ASSOCIATION_RETAIN);
}

- (void)setDeactivatedImage:(nonnull UIImage *)deactivatedImage {
    objc_setAssociatedObject(self, @"deactivatedImage", deactivatedImage, OBJC_ASSOCIATION_RETAIN);
}

- (UIImage*)activatedImage {
    return objc_getAssociatedObject(self, @"activatedImage");
}


- (UIImage*)deactivatedImage {
    return objc_getAssociatedObject(self, @"deactivatedImage");
}

- (void)activate {
    [self setImage:[self activatedImage] forState:UIControlStateNormal];
}

- (void)deactivate {
    [self setImage:[self deactivatedImage] forState:UIControlStateNormal];
}

@end

@interface SBBacklightController : NSObject
+ (instancetype)sharedInstance;
-(void)resetLockScreenIdleTimer;
@end

@interface YoloViewController ()
@property (nonatomic,weak) NSLayoutConstraint* topConstraint;
@property (nonatomic) kLikedState currentState;
- (void)hearthhasBeenPressed:(UIButton*)hearth;
- (void)hearthhasBeenReleased:(UIButton*)hearth;
- (void)cancelButtonPressed:(UIButton*)cancelButton;
- (void)shuffleButtonPressed:(UIButton*)shuffleButton;
- (void)shuffleButtonPressedGesture:(UITapGestureRecognizer*)gesture;
- (void)hearthStateChanged:(UIButton*)hearth;
- (void)cancelButtonPressedGesture:(UITapGestureRecognizer*)gesture;
- (void)animateExitAndDismiss;
- (void)nextShuffleSong;
@end

@implementation YoloViewController

- (instancetype)init {
    if((self = [super init]))
    {
        self.view.backgroundColor = [UIColor clearColor];
        _selectedHearth = 0;
        _currentState = 0;
        [SharedHelper sharedInstance].likeDislikePane = self;
    }
    return self;
}

- (void)receivedStateChange:(kLikedState)newState{
    return;
    if(newState == _currentState) return;
    else{
        if(newState == kLikedStateNone){
            [_linedHearth deactivate];
            [_hearth deactivate];
        }else if(newState == kLikedStateLike){
            [_hearth activate];
            [_linedHearth deactivate];
        }else{
            [_hearth deactivate];
            [_linedHearth activate];
        }
    }
        _currentState = newState;
}

- (void)loadView
{
    [super loadView];
    UIView* shadowView = [[UIView alloc] initWithFrame:self.view.frame];
    shadowView.backgroundColor = [UIColor blackColor];
    shadowView.alpha = .25f;
    [self.view addSubview:shadowView];
    shadowView.hidden = YES;
    _shadowView = shadowView;
    
    UIView* activityContainerView = [[UIView alloc] init];
    activityContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    activityContainerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:activityContainerView];
    _activityContainerView = activityContainerView;
}

- (void)viewDidLoad {

    [super viewDidLoad];
    
    if(!_upperContainer){
        UIView* upperContainer = [[UIView alloc] init];
        upperContainer.translatesAutoresizingMaskIntoConstraints = NO;
        [_activityContainerView addSubview:upperContainer];
        _upperContainer = upperContainer;
    }
    
    if(!_cancelView){
        
        UIView* cancelViewContainer = [[UIView alloc] init];
        cancelViewContainer.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIVisualEffectView* cancelView = [[UIVisualEffectView alloc] init];
        cancelView.translatesAutoresizingMaskIntoConstraints = NO;
        UIVisualEffect *blurEffect;
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        cancelView.effect = blurEffect;
        [_activityContainerView addSubview:cancelViewContainer];
        [cancelViewContainer addSubview:cancelView];
        _cancelViewContainer = cancelViewContainer;

        UIButton* cancelLabel = [UIButton buttonWithType:UIButtonTypeSystem];
        cancelLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [cancelLabel setTitle:@"Cancel" forState:UIControlStateNormal];
        cancelLabel.titleLabel.font = [UIFont systemFontOfSize:20.0f weight:.3f];
        cancelLabel.titleLabel.textColor = ios10Blue;
        [cancelLabel addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [cancelView addSubview:cancelLabel];
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelButtonPressedGesture:)];
        [cancelView addGestureRecognizer:tap];

        _cancelView = cancelView;
        _cancelLabel = cancelLabel;
    }
    
    if(!_likeDislikeView){
        
        UIVisualEffectView* likeDislikeView = [[UIVisualEffectView alloc] init];
        likeDislikeView.translatesAutoresizingMaskIntoConstraints = NO;

        UIVisualEffect *blurEffect;
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        likeDislikeView.effect = blurEffect;
        [_upperContainer addSubview:likeDislikeView];
        
        
        UIButton* hearth = [UIButton buttonWithType:UIButtonTypeCustom];
        hearth.adjustsImageWhenHighlighted = NO;
        hearth.activatedImage = [[UIImage alloc] initWithContentsOfFile:[[[NSBundle alloc] initWithPath:BUNDLEPATH] pathForResource:@"Hearth_Filled" ofType:@"png"]];
        hearth.deactivatedImage = [[UIImage alloc] initWithContentsOfFile:[[[NSBundle alloc] initWithPath:BUNDLEPATH] pathForResource:@"Hearth_Empty" ofType:@"png"]];
        [hearth activate];

        hearth.opaque = YES;
        hearth.translatesAutoresizingMaskIntoConstraints = NO;
        [hearth addTarget:self action:@selector(hearthhasBeenReleased:) forControlEvents:UIControlEventTouchUpInside];
        [hearth addTarget:self action:@selector(hearthhasBeenPressed:) forControlEvents:UIControlEventTouchDown];
        
        UIButton* linedHearth = [UIButton buttonWithType:UIButtonTypeCustom];
        linedHearth.adjustsImageWhenHighlighted = NO;
        linedHearth.activatedImage = [[UIImage alloc] initWithContentsOfFile:[[[NSBundle alloc] initWithPath:BUNDLEPATH] pathForResource:@"Hearth_Lined_Filled" ofType:@"png"]];
        linedHearth.deactivatedImage = [[UIImage alloc] initWithContentsOfFile:[[[NSBundle alloc] initWithPath:BUNDLEPATH] pathForResource:@"Hearth_Lined_Empty" ofType:@"png"]];
        [linedHearth activate];

        linedHearth.translatesAutoresizingMaskIntoConstraints = NO;
        [linedHearth addTarget:self action:@selector(hearthhasBeenReleased:) forControlEvents:UIControlEventTouchUpInside];
        [linedHearth addTarget:self action:@selector(hearthhasBeenPressed:) forControlEvents:UIControlEventTouchDown];
        
        [likeDislikeView.contentView addSubview:hearth];
        [likeDislikeView.contentView addSubview:linedHearth];
        
        _likeDislikeView = likeDislikeView;
        _hearth = hearth;
        _linedHearth = linedHearth;
        
    }

    if(!_dummyView){
        
        UIVisualEffectView* dummyView = [[UIVisualEffectView alloc] init];
        dummyView.translatesAutoresizingMaskIntoConstraints = NO;
        UIVisualEffect *blurEffect;
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        dummyView.effect = blurEffect;
        [_upperContainer addSubview:dummyView];
        
        UIButton* nextShuffleLabel = [UIButton buttonWithType:UIButtonTypeSystem];
        nextShuffleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [nextShuffleLabel setTitle:@"Next shuffle song" forState:UIControlStateNormal];
        nextShuffleLabel.titleLabel.font = [UIFont systemFontOfSize:20.0f weight:.0f];
        nextShuffleLabel.titleLabel.textColor = ios10Blue;
        [nextShuffleLabel addTarget:self action:@selector(shuffleButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [dummyView addSubview:nextShuffleLabel];

        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shuffleButtonPressedGesture:)];
        [dummyView addGestureRecognizer:tap];

        _nextShuffleLabel = nextShuffleLabel;
        _dummyView = dummyView;
        
    }
    
    if(!self->hasBeenSetup){
        
        NSArray* h = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_cancelViewContainer]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_cancelViewContainer)];
        NSArray* v = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_cancelViewContainer(==54)]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_cancelViewContainer)];

        NSArray* cancelViewH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_cancelView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_cancelView)];
        NSArray* cancelViewV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_cancelView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_cancelView)];
        
        NSArray* hC = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-4-[_activityContainerView]-4-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_activityContainerView)];
        
    
        NSLayoutConstraint* vC = [NSLayoutConstraint constraintWithItem:_activityContainerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:.0f];
        
        NSLayoutConstraint* hL = [NSLayoutConstraint constraintWithItem:_cancelLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_cancelView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:.0f];
        
        NSLayoutConstraint* vL = [NSLayoutConstraint constraintWithItem:_cancelLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_cancelView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:.0f];
        
        NSLayoutConstraint* shuffleLabelH = [NSLayoutConstraint constraintWithItem:_nextShuffleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_dummyView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:.0f];
        
        NSLayoutConstraint* shuffleLabelV = [NSLayoutConstraint constraintWithItem:_nextShuffleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_dummyView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:.0f];
        
        // ---
        NSArray* upperContainerH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_upperContainer]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_upperContainer)];
        
        NSArray* upperContainerV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_upperContainer]-[_cancelViewContainer]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_upperContainer,_cancelViewContainer)];
        
        NSArray* likeDislikeViewH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_likeDislikeView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_likeDislikeView)];

        NSArray* likeDislikeViewV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_likeDislikeView(==54)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_likeDislikeView)];
        
        NSLayoutConstraint* hearthVerticalAlign = [NSLayoutConstraint constraintWithItem:_hearth attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_likeDislikeView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:.0f];
        
        NSLayoutConstraint* hearthHorizontalAlign = [NSLayoutConstraint constraintWithItem:_hearth attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_likeDislikeView attribute:NSLayoutAttributeCenterX multiplier:.5f constant:.0f];

        NSLayoutConstraint* hearthHSize = [NSLayoutConstraint constraintWithItem:_hearth attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:100.0f];

        NSLayoutConstraint* hearthVSize = [NSLayoutConstraint constraintWithItem:_hearth attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:100.0f];
        
        NSLayoutConstraint* linedHearthVerticalAlign = [NSLayoutConstraint constraintWithItem:_linedHearth attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_likeDislikeView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:.0f];
        
        NSLayoutConstraint* linedHearthHorizontalAlign = [NSLayoutConstraint constraintWithItem:_linedHearth attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_likeDislikeView attribute:NSLayoutAttributeCenterX multiplier:1.5f constant:.0f];

        NSLayoutConstraint* linedHearthHSize = [NSLayoutConstraint constraintWithItem:_linedHearth attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:100.0f];
        
        NSLayoutConstraint* linedHearthVSize = [NSLayoutConstraint constraintWithItem:_linedHearth attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:100.0f];
        
        NSArray* dummyViewH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_dummyView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_dummyView)];
        
        NSArray* dummyViewV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_dummyView(==54)][_likeDislikeView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_likeDislikeView,_dummyView)];
        
        [self.view addConstraints:hC];
        [self.view addConstraint:vC];
        [_activityContainerView addConstraints:h];
        [_activityContainerView addConstraints:v];
        [_cancelViewContainer addConstraints:cancelViewH];
        [_cancelViewContainer addConstraints:cancelViewV];
        [_cancelView addConstraint:hL];
        [_cancelView addConstraint:vL];
        [_activityContainerView addConstraints:upperContainerH];
        [_activityContainerView addConstraints:upperContainerV];
        [_upperContainer addConstraints:likeDislikeViewH];
        [_upperContainer addConstraints:likeDislikeViewV];
        [_likeDislikeView addConstraint:hearthVerticalAlign];
        [_likeDislikeView addConstraint:hearthHorizontalAlign];
        [_likeDislikeView addConstraint:linedHearthVerticalAlign];
        [_likeDislikeView addConstraint:linedHearthHorizontalAlign];
        [_upperContainer addConstraints:dummyViewH];
        [_upperContainer addConstraints:dummyViewV];
        [_hearth addConstraint:hearthHSize];
        [_hearth addConstraint:hearthVSize];
        [_linedHearth addConstraint:linedHearthHSize];
        [_linedHearth addConstraint:linedHearthVSize];
        [_dummyView addConstraint:shuffleLabelV];
        [_dummyView addConstraint:shuffleLabelH];
        _topConstraint = vC;
        
        self->hasBeenSetup = YES;
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view layoutIfNeeded];
    
    [_cancelViewContainer setRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight|UIRectCornerBottomLeft|UIRectCornerBottomRight radius:CGSizeMake(12.0f,12.0f)];
    [_upperContainer setRoundedCorners:UIRectCornerTopLeft radius:CGSizeMake(12.0f, 12.0f)];
    
    UIView* hearthDivider = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX(_likeDislikeView.frame), 0, .5, _likeDislikeView.frame.size.height)];
    hearthDivider.backgroundColor = [UIColor blackColor];
    hearthDivider.alpha = .6f;
    [_likeDislikeView addSubview:hearthDivider];
    
    UIView* viewDivider = [[UIView alloc] initWithFrame:CGRectMake(0, _dummyView.frame.size.height-0.5f, _dummyView.frame.size.width, .5f)];
    viewDivider.alpha = .6f;
    viewDivider.backgroundColor = [UIColor blackColor];
    [_dummyView addSubview:viewDivider];

    // kLikedState songState = [SharedHelper sharedInstance].songState;
    // if(songState == kLikedStateNone){
    //     _selectedHearth = 0;
    //     [_linedHearth deactivate];
    //     [_hearth deactivate];
    // }else if(songState == kLikedStateLike){
    //     _selectedHearth = 1;
    //     [_hearth activate];
    //     [_linedHearth deactivate];
    // }else{
    //     _selectedHearth = 2;
    //     [_hearth deactivate];
    //     [_linedHearth activate];
    // }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _topConstraint.constant = -_activityContainerView.frame.size.height;
    [UIView animateWithDuration:.3f delay:.0f usingSpringWithDamping:.80 initialSpringVelocity:.0f options:0 animations:^{
        _shadowView.hidden = NO;
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)cancelButtonPressedGesture:(UITapGestureRecognizer*)gesture {
    [self animateExitAndDismiss];
}

- (void)cancelButtonPressed:(UIButton*)cancelButton {
    [self animateExitAndDismiss];
}

- (void)shuffleButtonPressed:(UIButton*)button{
    [self nextShuffleSong];
    [self animateExitAndDismiss];
}

- (void)shuffleButtonPressedGesture:(UITapGestureRecognizer*)gesture{
    [self nextShuffleSong];
    [self animateExitAndDismiss];
}

- (void)hearthhasBeenPressed:(UIButton*)hearth{
    [UIView animateWithDuration:.2f animations:^{
        hearth.transform = CGAffineTransformMakeScale(.95, .95);
    }];
}

- (void)hearthStateChanged:(UIButton*)hearth {
    if([hearth isEqual:_hearth]){
        if(_selectedHearth == 1) {
            _selectedHearth = 0;
            return;
        }
        _selectedHearth = 1;
    }else{
        if(_selectedHearth == 2){
            _selectedHearth = 0;
            return;
        }
        _selectedHearth = 2;
    }
}

- (void)hearthhasBeenReleased:(UIButton*)hearth{
    
    [UIView animateKeyframesWithDuration:.4f delay:.0f options:UIViewKeyframeAnimationOptionAllowUserInteraction|UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
        [UIView addKeyframeWithRelativeStartTime:.0f relativeDuration:.5f animations:^{
            hearth.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
            if([hearth isEqual:_hearth]) [[objc_getClass("SBMediaController") sharedInstance] likeTrack];
            else [[objc_getClass("SBMediaController") sharedInstance] banTrack];
        }];
        [UIView addKeyframeWithRelativeStartTime:.5f relativeDuration:.5f animations:^{
            hearth.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        }];
    } completion:^(BOOL finished){
        [self animateExitAndDismiss];
    }];
}

- (void)switchHearths:(UIButton*)pressedHearth {
    UIButton* otherHearth = ([pressedHearth isEqual:_hearth]) ? _linedHearth : _hearth;
    if(!_selectedHearth) {
        [pressedHearth activate];
    }else{
        if(([pressedHearth isEqual:_hearth] && _selectedHearth == 1) || ([pressedHearth isEqual:_linedHearth] && _selectedHearth == 2)) {
            [pressedHearth deactivate];
            [self hearthStateChanged:pressedHearth];
            return;
        }
        [pressedHearth activate];
        [otherHearth deactivate];
    }[self hearthStateChanged:pressedHearth];
}

- (void)dealloc{
    [[objc_getClass("SBBacklightController") sharedInstance] resetLockScreenIdleTimer];
    [SharedHelper sharedInstance].likeDislikePane = nil;
}

- (void)nextShuffleSong{
    [[objc_getClass("SBMediaController") sharedInstance] changeTrack:6];
}

- (void)animateExitAndDismiss {
    _topConstraint.constant = .0f;
    [UIView animateWithDuration:.3f delay:.0f usingSpringWithDamping:.80 initialSpringVelocity:.0f options:0 animations:^{
        [self.view layoutIfNeeded];
        _shadowView.hidden = YES;
    } completion:^(BOOL finished){
        [self dismissViewControllerAnimated:NO completion:nil];
        [SharedHelper sharedInstance].panelActive = NO;
        [[objc_getClass("SBBacklightController") sharedInstance] resetLockScreenIdleTimer];
    }];
}

@end
