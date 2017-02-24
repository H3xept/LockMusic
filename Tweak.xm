#include <rocketbootstrap/rocketbootstrap.h>

#include "./tools/LLIPC.h"
#include "./tools/LLLog.h"

#define LOG(X) LLLogPrint((char *)X);

@interface SBDashBoardMediaArtworkViewController:UIViewController

@end

%hook SBDashBoardMediaArtworkViewController
-(void)viewWillLayoutSubviews{
	%orig;
	__unused id v = self.view.subviews;
	__unused const char* srt = [[NSString stringWithFormat:@"%@",v] UTF8String];
	if(srt)
		LOG(srt);
}
%end

%hook SBMediaController
-(BOOL)pause{
	BOOL rt = %orig;
	LOG("Pause received.");
	return rt;
}
%end

%ctor{
	assert(lllog_register_service("net.jndok.logserver") == 0);
}