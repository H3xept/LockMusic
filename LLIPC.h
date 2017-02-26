//
//  LLIPC.h
//  ipctest
//
//  Created by jndok on 22/02/17.
//  Copyright © 2017 jndok. All rights reserved.
//

#ifndef LLIPC_h
#define LLIPC_h

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#include <mach/mach.h>

#define LLIPC_MSG_TYPE_HANDSHAKE    0
#define LLIPC_MSG_TYPE_PING         1
#define LLIPC_MSG_TYPE_LOG          2

typedef struct llipc_recv {
    mach_msg_header_t header;
} llipc_recv_t;

typedef struct hndshk_send {
    mach_msg_header_t header;
    uint32_t code;
} hndshk_send_t;

typedef struct hndshk_recv {
    mach_msg_header_t header;
    uint32_t code;
    mach_msg_trailer_t trailer;
} hndshk_recv_t;

typedef struct ping_send {
    mach_msg_header_t header;
    uint8_t ping : 1;
} ping_send_t;

typedef struct ping_recv {
    mach_msg_header_t header;
    uint8_t ping : 1;
    mach_msg_trailer_t trailer;
} ping_recv_t;

typedef struct log_send {
    mach_msg_header_t header;
    char log[512];
} log_send_t;

typedef struct log_recv {
    mach_msg_header_t header;
    char log[512];
    mach_msg_trailer_t trailer;
} log_recv_t;


kern_return_t llipc_send_handshake(mach_port_t remote, mach_port_t local, uint32_t code);
kern_return_t llipc_receive_handshake(mach_port_t local, mach_port_t *remote, uint32_t *code);

kern_return_t llipc_send_ping(mach_port_t remote);
kern_return_t llipc_recv_ping(mach_port_t local);

kern_return_t llipc_send_log(mach_port_t remote, char *log);
kern_return_t llipc_receive_log(mach_port_t local, char *log);

#endif /* LLIPC_h */
