#include "LMPRootListController.h"
#import <MessageUI/MessageUI.h>

@implementation NoNotifications
@end


@class PSTableCell;

@interface NoNotificationsCell : PSTableCell {}
@end
@implementation NoNotificationsCell
- (id)initWithSpecifier:(PSSpecifier *)specifier{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"footerCell" specifier:specifier];
    if (self) {
    	self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}
- (CGFloat)preferredHeightForWidth:(CGFloat)arg1{
	return 80;
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
