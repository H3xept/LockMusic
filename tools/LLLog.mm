//
//  LLLog.c
//  ipctest
//
//  Created by jndok on 22/02/17.
//  Copyright © 2017 jndok. All rights reserved.
//

#include "LLLog.h"

mach_port_t server = 0;
mach_port_t client = 0;

kern_return_t lllog_register_server(const char *name)
{
    kern_return_t kr = 0;

    mach_port_t bootstrap = MACH_PORT_NULL;
    task_get_bootstrap_port(mach_task_self(), &bootstrap);

    mach_port_allocate(mach_task_self(), MACH_PORT_RIGHT_RECEIVE, &server);

#ifdef BOOTSTRAP_UNLOCKED
    if ((kr = bootstrap_check_in(bootstrap, name, &server)) != KERN_SUCCESS)
        return 0;
#else
    rocketbootstrap_unlock((char *)name);
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if ((kr = bootstrap_register(bootstrap, (char *)name, server) != KERN_SUCCESS))
        return 0;
#endif

    return kr;
}

void *do_register_service(void *name)
{
    lllog_register_server((char *)name);

    while (1) {
        uint32_t code = 0;
        llipc_receive_handshake(server, &client, &code);
        assert(code == LLLOG_HANDSHAKE_CODE);
        llipc_send_log(client, (char *)"gang!");
    }

    return NULL;
}

kern_return_t lllog_register_service(const char *name)
{
    pthread_t t;
    return pthread_create(&t, NULL, do_register_service, (void *)name);
}

void LLLogPrint(char *msg)
{
    if (MACH_PORT_VALID(client)) {
        llipc_send_log(client, msg);
    }
}
