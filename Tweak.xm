#include <rocketbootstrap/rocketbootstrap.h>

#include "./tools/LLIPC.h"
#include "./tools/LLLog.h"

#define LOG(X) LLLogPrint((char *)X);

%hook SBLockHardwareButton
-(void)singlePress:(id)arg1
{
    LLLogPrint((char *)"singlePress");
	%orig(arg1);
}

%end


%ctor{
	assert(lllog_register_service("net.jndok.logserver") == 0);
}