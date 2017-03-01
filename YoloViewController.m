#import "YoloViewController.h"
#import <objc/runtime.h>

#define BUNDLEPATH @"/Library/PreferenceBundles/lockmusicprefs.bundle"
#define ios10Blue [UIColor colorWithRed:0.00 green:0.48 blue:1.00 alpha:1.0]

@interface UIVisualEffectView (RoundedCorners)

- (void)setRoundedCorners:(UIRectCorner)corners radius:(CGSize)size;

@end

@implementation UIVisualEffectView (RoundedCorners)

- (void)setRoundedCorners:(UIRectCorner)corners radius:(CGSize)size {
    UIBezierPath* maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:size];
    
    CAShapeLayer* maskLayer = [CAShapeLayer new];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    
    UIView* maskView = [[UIView alloc] initWithFrame:self.bounds];
    maskView.backgroundColor = [UIColor blackColor];
    maskView.layer.mask = maskLayer;
    
    self.maskView = maskView;
}

@end

@interface UIButton (ActivateDeactivate)
@property (nonatomic,strong) UIImage* activatedImage;
@property (nonatomic,strong) UIImage* deactivatedImage;
- (void)activate;
- (void)deactivate;
@end

@implementation UIButton (ActivateDeactivate)

- (void)setActivatedImage:(UIImage *)activatedImage {
    objc_setAssociatedObject(self, @"activatedImage", activatedImage, OBJC_ASSOCIATION_RETAIN);
}

- (void)setDeactivatedImage:(UIImage *)deactivatedImage {
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

@interface YoloViewController ()
@property (nonatomic,strong) NSLayoutConstraint* topConstraint;
- (void)hearthhasBeenPressed:(UIButton*)hearth;
- (void)hearthhasBeenReleased:(UIButton*)hearth;
- (void)cancelButtonPressed:(UIButton*)cancelButton;
@end

@implementation YoloViewController

- (instancetype)init {
    if((self = [super init]))
    {
        self.view.backgroundColor = [UIColor clearColor];
        _selectedHearth = 0;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    UIView* shadowView = [[UIView alloc] initWithFrame:self.view.frame];
    shadowView.backgroundColor = [UIColor blackColor];
    shadowView.alpha = .25f;
    [self.view addSubview:shadowView];
    _shadowView = shadowView;
    
    UIView* activityContainerView = [[UIView alloc] init];
    activityContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    activityContainerView.userInteractionEnabled = YES;
    activityContainerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:activityContainerView];
    _activityContainerView = activityContainerView;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if(!_cancelView){
        
        UIVisualEffectView* cancelView = [[UIVisualEffectView alloc] init];
        cancelView.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIVisualEffect *blurEffect;
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        cancelView.effect = blurEffect;
        [_activityContainerView addSubview:cancelView];
        

        UIButton* cancelLabel = [UIButton buttonWithType:UIButtonTypeSystem];
        cancelLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [cancelLabel setTitle:@"Cancel" forState:UIControlStateNormal];
        cancelLabel.titleLabel.font = [UIFont systemFontOfSize:20.0f weight:.3f];
        cancelLabel.titleLabel.textColor = ios10Blue;
        [cancelLabel addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [cancelView addSubview:cancelLabel];
        
        _cancelView = cancelView;
        _cancelLabel = cancelLabel;
    }
    
    if(!_likeDislikeView){
        
        UIVisualEffectView* likeDislikeView = [[UIVisualEffectView alloc] init];
        likeDislikeView.translatesAutoresizingMaskIntoConstraints = NO;
        likeDislikeView.userInteractionEnabled = YES;
        UIVisualEffect *blurEffect;
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        likeDislikeView.effect = blurEffect;
        [_activityContainerView addSubview:likeDislikeView];
        
        
        UIButton* hearth = [UIButton buttonWithType:UIButtonTypeCustom];
        hearth.adjustsImageWhenHighlighted = NO;
        hearth.activatedImage = [[UIImage alloc] initWithContentsOfFile:[[[NSBundle alloc] initWithPath:BUNDLEPATH] pathForResource:@"Hearth" ofType:@"png"]];
        hearth.deactivatedImage = [[UIImage alloc] initWithContentsOfFile:[[[NSBundle alloc] initWithPath:BUNDLEPATH] pathForResource:@"Hearth" ofType:@"png"]];
        [hearth deactivate];
        hearth.titleLabel.text = @"AY";
        hearth.opaque = YES;
        hearth.translatesAutoresizingMaskIntoConstraints = NO;
        [hearth addTarget:self action:@selector(hearthhasBeenReleased:) forControlEvents:UIControlEventTouchUpInside];
        [hearth addTarget:self action:@selector(hearthhasBeenPressed:) forControlEvents:UIControlEventTouchDown];
        
        UIButton* linedHearth = [UIButton buttonWithType:UIButtonTypeCustom];
        linedHearth.adjustsImageWhenHighlighted = NO;
        linedHearth.activatedImage = [[UIImage alloc] initWithContentsOfFile:[[[NSBundle alloc] initWithPath:BUNDLEPATH] pathForResource:@"Hearth_Line" ofType:@"png"]];
        linedHearth.deactivatedImage = [[UIImage alloc] initWithContentsOfFile:[[[NSBundle alloc] initWithPath:BUNDLEPATH] pathForResource:@"Hearth_Line" ofType:@"png"]];
        [linedHearth deactivate];
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
        [_activityContainerView addSubview:dummyView];
        
        _dummyView = dummyView;
        
    }
    
    if(!self->hasBeenSetup){
        
        NSArray* h = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_cancelView]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_cancelView)];
        NSArray* v = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_cancelView(==54)]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_cancelView)];
        
        NSArray* hC = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-4-[_activityContainerView]-4-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_activityContainerView)];
        
        NSLayoutConstraint* vC = [NSLayoutConstraint constraintWithItem:_activityContainerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:.0f];
        
        NSLayoutConstraint* hL = [NSLayoutConstraint constraintWithItem:_cancelLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_cancelView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:.0f];
        
        NSLayoutConstraint* vL = [NSLayoutConstraint constraintWithItem:_cancelLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_cancelView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:.0f];
        
        NSArray* likeDislikeViewH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_likeDislikeView]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_likeDislikeView)];

        NSArray* likeDislikeViewV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_likeDislikeView(==54)]-[_cancelView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_likeDislikeView,_cancelView)];
        
        NSLayoutConstraint* hearthVerticalAlign = [NSLayoutConstraint constraintWithItem:_hearth attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_likeDislikeView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:.0f];
        
        NSLayoutConstraint* hearthHorizontalAlign = [NSLayoutConstraint constraintWithItem:_hearth attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_likeDislikeView attribute:NSLayoutAttributeCenterX multiplier:.5f constant:.0f];

        NSLayoutConstraint* hearthHSize = [NSLayoutConstraint constraintWithItem:_hearth attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:100.0f];

        NSLayoutConstraint* hearthVSize = [NSLayoutConstraint constraintWithItem:_hearth attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:100.0f];
        
        NSLayoutConstraint* linedHearthVerticalAlign = [NSLayoutConstraint constraintWithItem:_linedHearth attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_likeDislikeView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:.0f];
        
        NSLayoutConstraint* linedHearthHorizontalAlign = [NSLayoutConstraint constraintWithItem:_linedHearth attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_likeDislikeView attribute:NSLayoutAttributeCenterX multiplier:1.5f constant:.0f];

        NSLayoutConstraint* linedHearthHSize = [NSLayoutConstraint constraintWithItem:_linedHearth attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:100.0f];
        
        NSLayoutConstraint* linedHearthVSize = [NSLayoutConstraint constraintWithItem:_linedHearth attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:100.0f];
        
        NSArray* dummyViewH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_dummyView]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_dummyView)];
        
        NSArray* dummyViewV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_dummyView(==54)][_likeDislikeView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_likeDislikeView,_dummyView)];
        
        [self.view addConstraints:hC];
        [self.view addConstraint:vC];
        [_cancelView addConstraint:hL];
        [_cancelView addConstraint:vL];
        [_activityContainerView addConstraints:h];
        [_activityContainerView addConstraints:v];
        [_activityContainerView addConstraints:likeDislikeViewH];
        [_activityContainerView addConstraints:likeDislikeViewV];
        [_likeDislikeView addConstraint:hearthVerticalAlign];
        [_likeDislikeView addConstraint:hearthHorizontalAlign];
        [_likeDislikeView addConstraint:linedHearthVerticalAlign];
        [_likeDislikeView addConstraint:linedHearthHorizontalAlign];
        [_activityContainerView addConstraints:dummyViewH];
        [_activityContainerView addConstraints:dummyViewV];
        [_hearth addConstraint:hearthHSize];
        [_hearth addConstraint:hearthVSize];
        [_linedHearth addConstraint:linedHearthHSize];
        [_linedHearth addConstraint:linedHearthVSize];
        
        _topConstraint = vC;
        
        self->hasBeenSetup = YES;
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view layoutIfNeeded];
    
    [_cancelView setRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight|UIRectCornerBottomLeft|UIRectCornerBottomRight radius:CGSizeMake(12,12)];
    [_likeDislikeView setRoundedCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight radius:CGSizeMake(12,12)];
    [_dummyView setRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight radius:CGSizeMake(12,12)];
    
    UIView* hearthDivider = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX(_likeDislikeView.layer.mask.frame), 0, .5, _likeDislikeView.layer.mask.frame.size.height)];
    hearthDivider.backgroundColor = [UIColor blackColor];
    hearthDivider.alpha = .6f;
    [_likeDislikeView addSubview:hearthDivider];
    
    UIView* viewDivider = [[UIView alloc] initWithFrame:CGRectMake(0, _dummyView.frame.size.height-0.5f, _dummyView.frame.size.width, .5f)];
    viewDivider.alpha = .6f;
    viewDivider.backgroundColor = [UIColor blackColor];
    [_dummyView addSubview:viewDivider];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _topConstraint.constant = -_activityContainerView.frame.size.height;
    [UIView animateWithDuration:.3f delay:.0f usingSpringWithDamping:.80 initialSpringVelocity:.0f options:0 animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)cancelButtonPressed:(UIButton*)cancelButton {
    _topConstraint.constant = .0f;
    [UIView animateWithDuration:.3f delay:.0f usingSpringWithDamping:.80 initialSpringVelocity:.0f options:0 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished){
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
}

- (void)hearthhasBeenPressed:(UIButton*)hearth{
    [UIView animateWithDuration:.2f animations:^{
        hearth.transform = CGAffineTransformMakeScale(.95, .95);
    }];
}

- (void)hearthhasBeenReleased:(UIButton*)hearth{

    [UIView animateKeyframesWithDuration:.4f delay:.0f options:UIViewKeyframeAnimationOptionAllowUserInteraction|UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
        [UIView addKeyframeWithRelativeStartTime:.0f relativeDuration:.5f animations:^{
            hearth.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
        }];
        [UIView addKeyframeWithRelativeStartTime:.5f relativeDuration:.5f animations:^{
            hearth.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        }];
    } completion:nil];
}

- (void)switchHearths:(UIButton*)pressedHearth {
    UIButton* otherHearth = ([pressedHearth isEqual:_hearth]) ? _linedHearth : _hearth;
    if(!_selectedHearth) {
        [pressedHearth activate];
    }else{
        [pressedHearth activate];
        [otherHearth deactivate];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
