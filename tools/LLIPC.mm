//
//  LLIPC.c
//  ipctest
//
//  Created by jndok on 22/02/17.
//  Copyright © 2017 jndok. All rights reserved.
//

#include "LLIPC.h"

kern_return_t llipc_send_handshake(mach_port_t remote, mach_port_t local, uint32_t code)
{
    assert(remote);
    assert(local);

    kern_return_t kr = 0;

    hndshk_send_t hndshk_msg;
    bzero(&hndshk_msg, sizeof(hndshk_msg));

    hndshk_msg.header.msgh_bits = MACH_MSGH_BITS(MACH_MSG_TYPE_COPY_SEND, MACH_MSG_TYPE_MAKE_SEND);
    hndshk_msg.header.msgh_remote_port = remote;
    hndshk_msg.header.msgh_local_port = local;
    hndshk_msg.header.msgh_size = sizeof(hndshk_send_t);

    hndshk_msg.header.msgh_id = LLIPC_MSG_TYPE_HANDSHAKE;

    hndshk_msg.code = code;

    kr = mach_msg(&(hndshk_msg.header),
                  MACH_SEND_MSG,
                  sizeof(hndshk_send_t),
                  0,
                  0,
                  0,
                  0);

    return kr;
}

kern_return_t llipc_receive_handshake(mach_port_t local, mach_port_t *remote, uint32_t *code)
{
    assert(remote);
    assert(local);
    assert(code);

    kern_return_t kr = 0;

    hndshk_recv_t hndshk_recv;
    bzero(&hndshk_recv, sizeof(hndshk_recv));

    hndshk_recv.header.msgh_size = sizeof(hndshk_recv_t);

    kr = mach_msg(&(hndshk_recv.header),
                  MACH_RCV_MSG,
                  0,
                  sizeof(hndshk_recv_t),
                  local,
                  0,
                  0);

    assert(hndshk_recv.header.msgh_id == LLIPC_MSG_TYPE_HANDSHAKE);

    *remote = hndshk_recv.header.msgh_remote_port;
    *code = hndshk_recv.code;

    return kr;
}

kern_return_t llipc_send_ping(mach_port_t remote)
{
    assert(remote);

    kern_return_t kr = 0;

    ping_send_t ping_msg;
    bzero(&ping_msg, sizeof(ping_msg));

    ping_msg.header.msgh_bits = MACH_MSGH_BITS(MACH_MSG_TYPE_COPY_SEND, 0);
    ping_msg.header.msgh_remote_port = remote;
    ping_msg.header.msgh_local_port = MACH_PORT_NULL;
    ping_msg.header.msgh_size = sizeof(ping_send_t);

    ping_msg.header.msgh_id = LLIPC_MSG_TYPE_PING;

    kr = mach_msg(&(ping_msg.header),
                  MACH_SEND_MSG,
                  sizeof(ping_send_t),
                  0,
                  0,
                  0,
                  0);

    return kr;
}

kern_return_t llipc_recv_ping(mach_port_t local)
{
    assert(local);

    kern_return_t kr = 0;

    ping_recv_t ping_recv;
    bzero(&ping_recv, sizeof(ping_recv));

    ping_recv.header.msgh_size = sizeof(ping_recv_t);

    kr = mach_msg(&(ping_recv.header),
                  MACH_RCV_MSG | MACH_RCV_TIMEOUT,
                  0,
                  sizeof(ping_recv_t),
                  local,
                  15000,
                  0);

    if (kr == MACH_RCV_TIMED_OUT)
        return kr;

    assert(ping_recv.header.msgh_id == LLIPC_MSG_TYPE_PING);

    return kr;
}

kern_return_t llipc_send_log(mach_port_t remote, char *log)
{
    assert(remote);
    assert(log);

    kern_return_t kr = 0;

    log_send_t log_msg;
    bzero(&log_msg, sizeof(log_msg));

    log_msg.header.msgh_bits = MACH_MSGH_BITS(MACH_MSG_TYPE_COPY_SEND, 0);
    log_msg.header.msgh_remote_port = remote;
    log_msg.header.msgh_local_port = MACH_PORT_NULL;
    log_msg.header.msgh_size = sizeof(log_send_t);

    log_msg.header.msgh_id = LLIPC_MSG_TYPE_LOG;

    strncpy((char *)&log_msg.log, (char *)log, sizeof(log_msg.log));

    kr = mach_msg(&(log_msg.header),
                  MACH_SEND_MSG,
                  sizeof(log_send_t),
                  0,
                  0,
                  0,
                  0);

    return kr;
}

kern_return_t llipc_receive_log(mach_port_t local, char *log)
{
    assert(local);
    assert(log);

    kern_return_t kr = 0;

    log_recv_t log_recv;
    bzero(&log_recv, sizeof(log_recv));

    log_recv.header.msgh_size = sizeof(hndshk_recv_t);

    kr = mach_msg(&(log_recv.header),
                  MACH_RCV_MSG,
                  0,
                  sizeof(log_recv_t),
                  local,
                  0,
                  0);

    assert(log_recv.header.msgh_id == LLIPC_MSG_TYPE_LOG);

    strncpy((char *)log, (char *)&log_recv.log, sizeof(log_recv.log));

    return kr;
}
