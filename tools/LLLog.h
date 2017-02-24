//
//  LLLog.h
//  ipctest
//
//  Created by jndok on 22/02/17.
//  Copyright © 2017 jndok. All rights reserved.
//

#ifndef LLLog_h
#define LLLog_h

#define LLLOG_HANDSHAKE_CODE    0xbabe

#if 0
#define BOOTSTRAP_UNLOCKED
#endif

#ifdef BOOTSTRAP_UNLOCKED
#include <servers/bootstrap.h>
#else
#include <rocketbootstrap/rocketbootstrap.h> // iOS
#endif

#include "LLIPC.h"

#include <pthread/pthread.h>

kern_return_t lllog_register_server(mach_port_t *server, const char *name);
kern_return_t lllog_register_service(const char *name);

void LLLogPrint(char *msg);

#endif /* LLLog_h */
