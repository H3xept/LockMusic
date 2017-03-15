#include "LMPRootListController.h"
#import <MessageUI/MessageUI.h>

@implementation NoNotifications
@end

#define BUNDLEPATH @"/Library/PreferenceBundles/lockmusicprefs.bundle"
#define imageShort(name,format) [[UIImage alloc] initWithContentsOfFile:[[[NSBundle alloc] initWithPath:BUNDLEPATH] pathForResource:name ofType:format]]
static CFStringRef applicationID = (__bridge CFStringRef)@"com.fl00d.lockmusicprefs";

@class PSTableCell;

void changeStyle(void) {
	[[NSNotificationCenter defaultCenter]
        postNotificationName:@"LockMusicInternalChangedStyle"
        object:nil];
}

unsigned int retrieveStyle(NSString* key) {
	unsigned int rt = 0;
    if (CFPreferencesAppSynchronize(applicationID)) {
        CFArrayRef keyList = CFPreferencesCopyKeyList(applicationID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
        if (keyList) {
            rt = [(NSNumber*)CFPreferencesCopyValue((__bridge CFStringRef)key, applicationID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost) integerValue];
            CFRelease(keyList);
        }
    }
    return rt;
}

@interface NoNotificationsCell : PSTableCell {
	UIImageView *_styleImage;
}
- (void)setupWithStyle:(unsigned int)style;
- (void)receivedRefreshNotification;
@end


@implementation NoNotificationsCell
- (id)initWithSpecifier:(PSSpecifier *)specifier{

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL,
	                              	(CFNotificationCallback)changeStyle,
	                               	(__bridge CFStringRef)@"LockMusicPrefsChangedNotification",
	                               	NULL,
	                               	CFNotificationSuspensionBehaviorDeliverImmediately);
	    });

	[[NSNotificationCenter defaultCenter] addObserver:self
	        selector:@selector(receivedRefreshNotification)
	        name:@"LockMusicInternalChangedStyle"
	        object:nil];

    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"footerCell" specifier:specifier];
    if (self) {
    	self->_styleImage = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,95,194)];
    	[self setupWithStyle:retrieveStyle(@"kNoNotificationStyle")];
    	self.backgroundColor = [UIColor whiteColor];
    	[self addSubview:self->_styleImage];
    }
    return self;
}

- (void)receivedRefreshNotification {
	unsigned int style = retrieveStyle(@"kNoNotificationStyle");
    [self setupWithStyle:style];
}

- (void)setupWithStyle:(unsigned int)style {
	switch(style) {
		case 0: //Default
			self->_styleImage.image = imageShort(@"NoNotification_Default",@"png");
			break;
		case 1: //LockMusic - Default
			self->_styleImage.image = imageShort(@"NoNotification_1",@"png");
			break;
		case 2: //LockMusic - Shrunk
			self->_styleImage.image = imageShort(@"NoNotification_2",@"png");
			break;
		case 3: // Custom
			self->_styleImage.image = imageShort(@"Custom",@"png");
			break;
	}
}

- (void)drawRect:(CGRect)frame {
	CGRect nFrame = self->_styleImage.frame;
	nFrame.origin.x = frame.size.width/2 - nFrame.size.width/2;
	self->_styleImage.frame = nFrame;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1{
	return 202;
}

@end


@interface NotificationsCell : PSTableCell {
	UIImageView *_styleImage;
}
- (void)setupWithStyle:(unsigned int)style;
- (void)receivedRefreshNotification;
@end


@implementation NotificationsCell
- (id)initWithSpecifier:(PSSpecifier *)specifier{

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL,
	                              	(CFNotificationCallback)changeStyle,
	                               	(__bridge CFStringRef)@"LockMusicPrefsChangedNotification",
	                               	NULL,
	                               	CFNotificationSuspensionBehaviorDeliverImmediately);
	    });

	[[NSNotificationCenter defaultCenter] addObserver:self
	        selector:@selector(receivedRefreshNotification)
	        name:@"LockMusicInternalChangedStyle"
	        object:nil];

    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"footerCell" specifier:specifier];
    if (self) {
    	self->_styleImage = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,95,194)];
    	[self setupWithStyle:retrieveStyle(@"kNotificationStyle")];
    	self.backgroundColor = [UIColor whiteColor];
    	[self addSubview:self->_styleImage];
    }
    return self;
}

- (void)receivedRefreshNotification {
	unsigned int style = retrieveStyle(@"kNotificationStyle");
    [self setupWithStyle:style];
}

- (void)setupWithStyle:(unsigned int)style {
	switch(style) {
		case 0: //Default
			self->_styleImage.image = imageShort(@"Notification_Default",@"png");
			break;
		case 1: //LockMusic - Default
			self->_styleImage.image = imageShort(@"Notification_1",@"png");
			break;
		case 3: // Custom
			self->_styleImage.image = imageShort(@"Custom",@"png");
			break;
	}
}

- (void)drawRect:(CGRect)frame {
	CGRect nFrame = self->_styleImage.frame;
	nFrame.origin.x = frame.size.width/2 - nFrame.size.width/2;
	self->_styleImage.frame = nFrame;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1{
	return 202;
}

@end

@interface LockMusicHeaderCell : PSTableCell {
	UIImageView *_background;
}
@end

@implementation LockMusicHeaderCell
	- (id)initWithSpecifier:(PSSpecifier *)specifier{
	    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"headerCell" specifier:specifier];
	    if (self) {
			UILabel* headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,20,[UIScreen mainScreen].bounds.size.width,40)];
			UILabel* subLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,headerLabel.frame.size.height+5,[UIScreen mainScreen].bounds.size.width,20)];
			headerLabel.text = @"LockMusic";
			headerLabel.font = [UIFont fontWithName:@"Snell Roundhand" size:50];
			headerLabel.textAlignment = NSTextAlignmentCenter;
			headerLabel.textColor = [UIColor colorWithRed:25/255.0f green:25/255.0f blue:25/255.0f alpha:1.0f];
			subLabel.text = @"Unleash the sleekness";
			subLabel.textAlignment = NSTextAlignmentCenter;
			subLabel.textColor = [UIColor blackColor];
			subLabel.font = [UIFont fontWithName:@"Didot-Italic" size:14];
			subLabel.alpha = 0.70;
			[self addSubview:headerLabel];
			[headerLabel addSubview:subLabel];
	    }
	    return self;
	}

	- (CGFloat)preferredHeightForWidth:(CGFloat)arg1{
	    return 80;
	}

@end

@interface LMPRootListController() <MFMailComposeViewControllerDelegate>{

}
@end
@implementation LMPRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}

- (void)bugToNopteam{
	if([MFMailComposeViewController canSendMail]) {
	    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
	    mailController.mailComposeDelegate = self;
	    [mailController setSubject:@"[BUG]LockMusic"];
	    [mailController setToRecipients:[NSArray arrayWithObject:@"info.nopteam@gmail.com"]];

	    [self presentViewController:mailController animated:YES completion:nil];
	    [mailController release];
	}
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)ideaToNopteam{
	if([MFMailComposeViewController canSendMail]) {
	    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
	    mailController.mailComposeDelegate = self;
	    [mailController setSubject:@"[IDEA]LockMusic"];
	    [mailController setToRecipients:[NSArray arrayWithObject:@"info.nopteam@gmail.com"]];

	    [self presentViewController:mailController animated:YES completion:nil];
	    [mailController release];
	}
}

@end
