#include <rocketbootstrap/rocketbootstrap.h>

#include "./tools/LLIPC.h"
#include "./tools/LLLog.h"

#define LOG(X) LLLogPrint((char *)X);

%ctor{
	assert(lllog_register_service("net.jndok.logserver") == 0);
}

%hook SBDashBoardMediaArtworkViewController

-(void)viewWillLayoutSubviews
{
	%orig;
	LOG("test");
}

%end
