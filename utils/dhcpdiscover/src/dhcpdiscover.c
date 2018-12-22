/******************************************************************************
 *
 * Original name: CHECK_DHCP.C
 * Current name: DHCPDISCOVER.C
 *
 * License: GPL
 * Copyright (c) 2001-2004 Ethan Galstad (nagios@nagios.org)
 * Copyright (c) 2006-2013 OpenWRT.org
 *
 * License Information:
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 *****************************************************************************/

const char* COPYRIGHT = " \
*\n \
* License: GPL\n \
* Copyright (c) 2001-2004 Ethan Galstad (nagios@nagios.org)\n \
* Copyright (c) 2006-2013 OpenWRT.org \n \
* ====================================================== \n \
* Mike Gore 25 Aug 2005 \n \
*    Modified for standalone operation \n \
* ====================================================== \n \
* Pau Escrich Jun 2013 \n \
*    Added -b option and ported to OpenWRT \n \
* ====================================================== \n \
*\n \
** License Information:\n \
*\n \
* This program is free software; you can redistribute it and/or modify\n \
* it under the terms of the GNU General Public License as published by\n \
* the Free Software Foundation; either version 2 of the License, or\n \
* (at your option) any later version.\n \
*\n \
* This program is distributed in the hope that it will be useful,\n \
* but WITHOUT ANY WARRANTY; without even the implied warranty of\n \
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n \
* GNU General Public License for more details.\n \
*\n \
* You should have received a copy of the GNU General Public License\n \
* along with this program; if not, write to the Free Software\n \
* Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.\n \
*\n \
* $Id: dhcpdiscover.c,v 2$\n \
*";

const char* progname = "dhcpdiscover";
const char* revision = "$Revision: 2$";
const char* copyright = "2006-2013";
const char* email = "p4u@dabax.net";

#include <arpa/inet.h>
#include <errno.h>
#include <fcntl.h>
#include <getopt.h>
#include <locale.h>
#include <net/if.h>
#include <netdb.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>

#if defined(__linux__)

#include <features.h>
#include <linux/if_ether.h>

#elif defined(__bsd__)

#include <net/if_dl.h>
#include <netinet/if_ether.h>
#include <sys/sysctl.h>

#elif defined(__sun__) || defined(__solaris__) || defined(__hpux__)

#define INSAP 22
#define OUTSAP 24

#include <ctype.h>
#include <signal.h>
#include <sys/dlpi.h>
#include <sys/poll.h>
#include <sys/stropts.h>

#define bcopy(source, destination, length) memcpy(destination, source, length)

#define AREA_SZ 5000 /* buffer length in bytes */
static u_long ctl_area[AREA_SZ];
static u_long dat_area[AREA_SZ];
static struct strbuf ctl = { AREA_SZ, 0, (char*)ctl_area };
static struct strbuf dat = { AREA_SZ, 0, (char*)dat_area };

#define GOT_CTRL 1
#define GOT_DATA 2
#define GOT_BOTH 3
#define GOT_INTR 4
#define GOT_ERR 128

#define u_int8_t uint8_t
#define u_int16_t uint16_t
#define u_int32_t uint32_t

static int get_msg(int);
static int check_ctrl(int);
static int put_ctrl(int, int, int);
static int put_both(int, int, int, int);
static int dl_open(const char*, int, int*);
static int dl_bind(int, int, u_char*);
long mac_addr_dlpi(const char*, int, u_char*);

#endif

#define HAVE_GETOPT_H

#define usage printf

/**** Common definitions ****/

#define STATE_OK 0
#define STATE_WARNING 1
#define STATE_CRITICAL 2
#define STATE_UNKNOWN -1

#define OK 0
#define ERROR -1

#define FALSE 0
#define TRUE 1

/**** DHCP definitions ****/

#define MAX_DHCP_CHADDR_LENGTH 16
#define MAX_DHCP_SNAME_LENGTH 64
#define MAX_DHCP_FILE_LENGTH 128
#define MAX_DHCP_OPTIONS_LENGTH 312

typedef struct dhcp_packet_struct {
    u_int8_t op;                                  /* packet type */
    u_int8_t htype;                               /* type of hardware address for this machine (Ethernet, etc) */
    u_int8_t hlen;                                /* length of hardware address (of this machine) */
    u_int8_t hops;                                /* hops */
    u_int32_t xid;                                /* random transaction id number - chosen by this machine */
    u_int16_t secs;                               /* seconds used in timing */
    u_int16_t flags;                              /* flags */
    struct in_addr ciaddr;                        /* IP address of this machine (if we already have one) */
    struct in_addr yiaddr;                        /* IP address of this machine (offered by the DHCP server) */
    struct in_addr siaddr;                        /* IP address of DHCP server */
    struct in_addr giaddr;                        /* IP address of DHCP relay */
    unsigned char chaddr[MAX_DHCP_CHADDR_LENGTH]; /* hardware address of this machine */
    char sname[MAX_DHCP_SNAME_LENGTH];            /* name of DHCP server */
    char file[MAX_DHCP_FILE_LENGTH];              /* boot file name (used for diskless booting?) */
    char options[MAX_DHCP_OPTIONS_LENGTH];        /* options */
} dhcp_packet;

typedef struct dhcp_offer_struct {
    struct in_addr server_address;  /* address of DHCP server that sent this offer */
    struct in_addr offered_address; /* the IP address that was offered to us */
    u_int32_t lease_time;           /* lease time in seconds */
    u_int32_t renewal_time;         /* renewal time in seconds */
    u_int32_t rebinding_time;       /* rebinding time in seconds */
    struct dhcp_offer_struct* next;
} dhcp_offer;

typedef struct requested_server_struct {
    struct in_addr server_address;
    struct requested_server_struct* next;
} requested_server;

#define BOOTREQUEST 1
#define BOOTREPLY 2

#define DHCPDISCOVER 1
#define DHCPOFFER 2
#define DHCPREQUEST 3
#define DHCPDECLINE 4
#define DHCPACK 5
#define DHCPNACK 6
#define DHCPRELEASE 7

#define DHCP_OPTION_MESSAGE_TYPE 53
#define DHCP_OPTION_HOST_NAME 12
#define DHCP_OPTION_BROADCAST_ADDRESS 28
#define DHCP_OPTION_REQUESTED_ADDRESS 50
#define DHCP_OPTION_LEASE_TIME 51
#define DHCP_OPTION_RENEWAL_TIME 58
#define DHCP_OPTION_REBINDING_TIME 59

#define DHCP_INFINITE_TIME 0xFFFFFFFF

#define DHCP_BROADCAST_FLAG 32768

#define DHCP_SERVER_PORT 67
#define DHCP_CLIENT_PORT 68

#define ETHERNET_HARDWARE_ADDRESS 1        /* used in htype field of dhcp packet */
#define ETHERNET_HARDWARE_ADDRESS_LENGTH 6 /* length of Ethernet hardware addresses */

unsigned char client_hardware_address[MAX_DHCP_CHADDR_LENGTH] = "";
unsigned int my_client_mac[MAX_DHCP_CHADDR_LENGTH];
int mymac = 0;

struct in_addr banned_ip;
int banned = 0;
char baddr[16];

char network_interface_name[16] = "eth0";

u_int32_t packet_xid = 0;

u_int32_t dhcp_lease_time = 0;
u_int32_t dhcp_renewal_time = 0;
u_int32_t dhcp_rebinding_time = 0;

int dhcpoffer_timeout = 2;

dhcp_offer* dhcp_offer_list = NULL;
requested_server* requested_server_list = NULL;

int valid_responses = 0; /* number of valid DHCPOFFERs we received */
int requested_servers = 0;
int requested_responses = 0;

int request_specific_address = FALSE;
int received_requested_address = FALSE;
int verbose = 0;
int prometheus = 0;
struct in_addr requested_address;

void print_revision(const char* progname, const char* revision) { printf("Program: %s %s\n", progname, revision); }

int process_arguments(int, char**);
int call_getopt(int, char**);
int validate_arguments(void);
void print_usage(void);
void print_help(void);

int get_hardware_address(int, char*);

int send_dhcp_discover(int);
int get_dhcp_offer(int);

int get_results(void);

int add_dhcp_offer(struct in_addr, dhcp_packet*);
int free_dhcp_offer_list(void);
int free_requested_server_list(void);

int create_dhcp_socket(void);
int close_dhcp_socket(int);
int send_dhcp_packet(void*, int, int, struct sockaddr_in*);
int receive_dhcp_packet(void*, int, int, int, struct sockaddr_in*);

int main(int argc, char** argv)
{
    int dhcp_socket;
    int result;

    setlocale(LC_ALL, "");
    // bindtextdomain (PACKAGE, LOCALEDIR);
    // textdomain (PACKAGE);

    if (process_arguments(argc, argv) != OK) {
        printf("Could not parse arguments");
    }

    // Set banned addr in string format in global var baddr
    if (banned) {
        inet_ntop(AF_INET, &(banned_ip), baddr, INET_ADDRSTRLEN);
        if (verbose)
            printf("Banned addr:%s\n", baddr);
    }

    /* create socket for DHCP communications */
    dhcp_socket = create_dhcp_socket();

    /* get hardware address of client machine */
    get_hardware_address(dhcp_socket, network_interface_name);

    /* send DHCPDISCOVER packet */
    send_dhcp_discover(dhcp_socket);

    /* wait for a DHCPOFFER packet */
    get_dhcp_offer(dhcp_socket);

    /* close socket we created */
    close_dhcp_socket(dhcp_socket);

    /* determine state/plugin output to return */
    if (!prometheus) {
        result = get_results();
    }

    /* free allocated memory */
    free_dhcp_offer_list();
    free_requested_server_list();

    return result;
}

/* determines hardware address on client machine */
int get_hardware_address(int sock, char* interface_name)
{

    int i;

#if defined(__linux__)
    struct ifreq ifr;

    strncpy((char*)&ifr.ifr_name, interface_name, sizeof(ifr.ifr_name));

    // Added code to try to set local MAC address just to be through
    // If this fails the test will still work since
    // we do encode the MAC as part of the DHCP frame - tests show it works
    if (mymac) {
        int i;
        for (i = 0; i < MAX_DHCP_CHADDR_LENGTH; ++i)
            client_hardware_address[i] = my_client_mac[i];
        memcpy(&ifr.ifr_hwaddr.sa_data, &client_hardware_address[0], 6);
        if (ioctl(sock, SIOCSIFHWADDR, &ifr) < 0) {
            printf("Error: Could not set hardware address of interface '%s'\n", interface_name);
            // perror("Error");
            // exit(STATE_UNKNOWN);
        }

    } else {
        /* try and grab hardware address of requested interface */
        if (ioctl(sock, SIOCGIFHWADDR, &ifr) < 0) {
            printf("Error: Could not get hardware address of interface '%s'\n", interface_name);
            exit(STATE_UNKNOWN);
        }
        memcpy(&client_hardware_address[0], &ifr.ifr_hwaddr.sa_data, 6);
    }

#elif defined(__bsd__)
    /* King 2004	see ACKNOWLEDGEMENTS */

    int mib[6], len;
    char* buf;
    unsigned char* ptr;
    struct if_msghdr* ifm;
    struct sockaddr_dl* sdl;

    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;

    if ((mib[5] = if_nametoindex(interface_name)) == 0) {
                printf("Error: if_nametoindex error - %s.\n", strerror(errno);
                exit(STATE_UNKNOWN);
    }

    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
                printf("Error: Couldn't get hardware address from %s. sysctl 1 error - %s.\n", interface_name, strerror(errno);
                exit(STATE_UNKNOWN);
    }

    if ((buf = malloc(len)) == NULL) {
                printf("Error: Couldn't get hardware address from interface %s. malloc error - %s.\n", interface_name, strerror(errno);
                exit(4);
    }

    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
                printf("Error: Couldn't get hardware address from %s. sysctl 2 error - %s.\n", interface_name, strerror(errno);
                exit(STATE_UNKNOWN);
    }

    ifm = (struct if_msghdr*)buf;
    sdl = (struct sockaddr_dl*)(ifm + 1);
    ptr = (unsigned char*)LLADDR(sdl);
    memcpy(&client_hardware_address[0], ptr, 6);
    /* King 2004 */

#elif defined(__sun__) || defined(__solaris__)

    /* Kompf 2000-2003	see ACKNOWLEDGEMENTS */
    long stat;
    char dev[20] = "/dev/";
    char* p;
    int unit;

    for (p = interface_name; *p && isalpha(*p); p++)
        /* no-op */;
    if (p != '\0') {
        unit = atoi(p);
        *p = '\0';
        strncat(dev, interface_name, 6);
    } else {
        printf("Error: can't find unit number in interface_name (%s) - expecting TypeNumber eg lnc0.\n", interface_name);
        exit(STATE_UNKNOWN);
    }
    stat = mac_addr_dlpi(dev, unit, client_hardware_address);
    if (stat != 0) {
        printf("Error: can't read MAC address from DLPI streams interface for device %s unit %d.\n", dev, unit);
        exit(STATE_UNKNOWN);
    }

#elif defined(__hpux__)

    long stat;
    char dev[20] = "/dev/dlpi";
    int unit = 0;

    stat = mac_addr_dlpi(dev, unit, client_hardware_address);
    if (stat != 0) {
        printf("Error: can't read MAC address from DLPI streams interface for device %s unit %d.\n", dev, unit);
        exit(STATE_UNKNOWN);
    }
    /* Kompf 2000-2003 */

#else
    printf("Error: can't get MAC address for this architecture.\n");
    exit(STATE_UNKNOWN);
#endif

    if (verbose) {
        printf("Hardware address: ");
        for (i = 0; i < 6; ++i)
            printf("%2.2x", client_hardware_address[i]);
        printf("\n");
    }

    return OK;
}

/* sends a DHCPDISCOVER broadcast message in an attempt to find DHCP servers */
int send_dhcp_discover(int sock)
{
    dhcp_packet discover_packet;
    struct sockaddr_in sockaddr_broadcast;

    /* clear the packet data structure */
    bzero(&discover_packet, sizeof(discover_packet));

    /* boot request flag (backward compatible with BOOTP servers) */
    discover_packet.op = BOOTREQUEST;

    /* hardware address type */
    discover_packet.htype = ETHERNET_HARDWARE_ADDRESS;

    /* length of our hardware address */
    discover_packet.hlen = ETHERNET_HARDWARE_ADDRESS_LENGTH;

    discover_packet.hops = 0;

    /* transaction id is supposed to be random */
    srand(time(NULL));
    packet_xid = random();
    discover_packet.xid = htonl(packet_xid);

    /**** WHAT THE HECK IS UP WITH THIS?!?  IF I DON'T MAKE THIS CALL, ONLY ONE SERVER RESPONSE IS PROCESSED!!!! ****/
    /* downright bizzarre... */
    ntohl(discover_packet.xid);

    /*discover_packet.secs=htons(65535);*/
    discover_packet.secs = 0xFF;

    /* tell server it should broadcast its response */
    discover_packet.flags = htons(DHCP_BROADCAST_FLAG);

    /* our hardware address */
    memcpy(discover_packet.chaddr, client_hardware_address, ETHERNET_HARDWARE_ADDRESS_LENGTH);

    /* first four bytes of options field is magic cookie (as per RFC 2132) */
    discover_packet.options[0] = '\x63';
    discover_packet.options[1] = '\x82';
    discover_packet.options[2] = '\x53';
    discover_packet.options[3] = '\x63';

    /* DHCP message type is embedded in options field */
    discover_packet.options[4] = DHCP_OPTION_MESSAGE_TYPE; /* DHCP message type option identifier */
    discover_packet.options[5] = '\x01';                   /* DHCP message option length in bytes */
    discover_packet.options[6] = DHCPDISCOVER;

    /* the IP address we're requesting */
    if (request_specific_address == TRUE) {
        discover_packet.options[7] = DHCP_OPTION_REQUESTED_ADDRESS;
        discover_packet.options[8] = '\x04';
        memcpy(&discover_packet.options[9], &requested_address, sizeof(requested_address));
    }

    /* send the DHCPDISCOVER packet to broadcast address */
    sockaddr_broadcast.sin_family = AF_INET;
    sockaddr_broadcast.sin_port = htons(DHCP_SERVER_PORT);
    sockaddr_broadcast.sin_addr.s_addr = INADDR_BROADCAST;
    bzero(&sockaddr_broadcast.sin_zero, sizeof(sockaddr_broadcast.sin_zero));

    if (verbose) {
        printf("DHCPDISCOVER to %s port %d\n", inet_ntoa(sockaddr_broadcast.sin_addr), ntohs(sockaddr_broadcast.sin_port));
        printf("DHCPDISCOVER XID: %lu (0x%X)\n", (unsigned long)ntohl(discover_packet.xid), ntohl(discover_packet.xid));
        printf("DHCDISCOVER ciaddr:  %s\n", inet_ntoa(discover_packet.ciaddr));
        printf("DHCDISCOVER yiaddr:  %s\n", inet_ntoa(discover_packet.yiaddr));
        printf("DHCDISCOVER siaddr:  %s\n", inet_ntoa(discover_packet.siaddr));
        printf("DHCDISCOVER giaddr:  %s\n", inet_ntoa(discover_packet.giaddr));
    }

    /* send the DHCPDISCOVER packet out */
    send_dhcp_packet(&discover_packet, sizeof(discover_packet), sock, &sockaddr_broadcast);

    if (verbose)
        printf("\n\n");

    return OK;
}

/* waits for a DHCPOFFER message from one or more DHCP servers */
int get_dhcp_offer(int sock)
{
    dhcp_packet offer_packet;
    struct sockaddr_in source;
    int result = OK;
    int timeout = 1;
    int responses = 0;
    int x;
    time_t start_time;
    time_t current_time;

    time(&start_time);

    /* receive as many responses as we can */
    for (responses = 0, valid_responses = 0;;) {

        time(&current_time);
        if ((current_time - start_time) >= dhcpoffer_timeout)
            break;

        if (verbose)
            printf("\n\n");

        bzero(&source, sizeof(source));
        bzero(&offer_packet, sizeof(offer_packet));

        result = OK;
        result = receive_dhcp_packet(&offer_packet, sizeof(offer_packet), sock, dhcpoffer_timeout, &source);

        // checks if the source address is the banned one
        char saddr[16];
        inet_ntop(AF_INET, &(source.sin_addr), saddr, INET_ADDRSTRLEN);

        if (banned && strcmp(saddr, baddr) == 0) {
            printf("DHCP offer comming from the banned addr %s, ignoring it\n", baddr);
            result = 1;
        }

        if (result != OK) {
            if (verbose)
                printf("Result=ERROR\n");

            continue;
        } else {
            if (verbose)
                printf("Result=OK\n");

            responses++;
        }

        if (verbose) {
            printf("DHCPOFFER from IP address %s\n", inet_ntoa(source.sin_addr));
            printf("DHCPOFFER XID: %lu (0x%X)\n", (unsigned long)ntohl(offer_packet.xid), ntohl(offer_packet.xid));
        }

        /* check packet xid to see if its the same as the one we used in the discover packet */
        if (ntohl(offer_packet.xid) != packet_xid) {
            if (verbose)
                printf("DHCPOFFER XID (%lu) did not match DHCPDISCOVER XID (%lu) - ignoring packet\n", (unsigned long)ntohl(offer_packet.xid), (unsigned long)packet_xid);

            continue;
        }

        /* check hardware address */
        result = OK;
        if (verbose)
            printf("DHCPOFFER chaddr: ");

        for (x = 0; x < ETHERNET_HARDWARE_ADDRESS_LENGTH; x++) {
            if (verbose)
                printf("%02X", (unsigned char)offer_packet.chaddr[x]);

            if (offer_packet.chaddr[x] != client_hardware_address[x])
                result = ERROR;
        }
        if (verbose)
            printf("\n");

        if (result == ERROR) {
            if (verbose)
                printf("DHCPOFFER hardware address did not match our own - ignoring packet\n");

            continue;
        }

        if (verbose) {
            printf("DHCPOFFER ciaddr: %s\n", inet_ntoa(offer_packet.ciaddr));
            printf("DHCPOFFER yiaddr: %s\n", inet_ntoa(offer_packet.yiaddr));
            printf("DHCPOFFER siaddr: %s\n", inet_ntoa(offer_packet.siaddr));
            printf("DHCPOFFER giaddr: %s\n", inet_ntoa(offer_packet.giaddr));
        }

        add_dhcp_offer(source.sin_addr, &offer_packet);

        valid_responses++;
    }

    if (verbose) {
        printf("Total responses seen on the wire: %d\n", responses);
        printf("Valid responses for this machine: %d\n", valid_responses);
    }

    return OK;
}

/* sends a DHCP packet */
int send_dhcp_packet(void* buffer, int buffer_size, int sock, struct sockaddr_in* dest)
{
    struct sockaddr_in myname;
    int result;

    result = sendto(sock, (char*)buffer, buffer_size, 0, (struct sockaddr*)dest, sizeof(*dest));

    if (verbose)
        printf("send_dhcp_packet result: %d\n", result);

    if (result < 0)
        return ERROR;

    return OK;
}

/* receives a DHCP packet */
int receive_dhcp_packet(void* buffer, int buffer_size, int sock, int timeout, struct sockaddr_in* address)
{
    struct timeval tv;
    fd_set readfds;
    int recv_result;
    unsigned long srcmac;
    socklen_t address_size;
    struct sockaddr_in source_address;

    /* wait for data to arrive (up time timeout) */
    tv.tv_sec = timeout;
    tv.tv_usec = 0;
    FD_ZERO(&readfds);
    FD_SET(sock, &readfds);
    select(sock + 1, &readfds, NULL, NULL, &tv);

    /* make sure some data has arrived */
    if (!FD_ISSET(sock, &readfds)) {
        if (verbose)
            printf("No (more) data received\n");
        return ERROR;
    }

    else {

        /* why do we need to peek first?  i don't know, its a hack.  without it, the source address of the first packet received was
           not being interpreted correctly.  sigh... */
        bzero(&source_address, sizeof(source_address));
        address_size = sizeof(source_address);
        recv_result = recvfrom(sock, (char*)buffer, buffer_size, MSG_PEEK, (struct sockaddr*)&source_address, &address_size);

        if (verbose)
            printf("recv_result_1: %d\n", recv_result);
        recv_result = recvfrom(sock, (char*)buffer, buffer_size, 0, (struct sockaddr*)&source_address, &address_size);
        if (verbose)
            printf("recv_result_2: %d\n", recv_result);

        if (recv_result == -1) {
            if (verbose) {
                printf("recvfrom() failed, ");
                printf("errno: (%d) -> %s\n", errno, strerror(errno));
            }
            return ERROR;
        } else {
            if (verbose) {
                printf("receive_dhcp_packet() result: %d\n", recv_result);
                printf("receive_dhcp_packet() source: %s\n", inet_ntoa(source_address.sin_addr));
            }

            memcpy(address, &source_address, sizeof(source_address));
            return OK;
        }
    }

    return OK;
}

/* creates a socket for DHCP communication */
int create_dhcp_socket(void)
{
    struct sockaddr_in myname;
    struct ifreq interface;
    int sock;
    int flag = 1;

    /* Set up the address we're going to bind to. */
    bzero(&myname, sizeof(myname));
    myname.sin_family = AF_INET;
    myname.sin_port = htons(DHCP_CLIENT_PORT);
    myname.sin_addr.s_addr = INADDR_ANY; /* listen on any address */
    bzero(&myname.sin_zero, sizeof(myname.sin_zero));

    /* create a socket for DHCP communications */
    sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (sock < 0) {
        printf("Error: Could not create socket!\n");
        exit(STATE_UNKNOWN);
    }

    if (verbose)
        printf("DHCP socket: %d\n", sock);

    /* set the reuse address flag so we don't get errors when restarting */
    flag = 1;
    if (setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, (char*)&flag, sizeof(flag)) < 0) {
        printf("Error: Could not set reuse address option on DHCP socket!\n");
        exit(STATE_UNKNOWN);
    }

    /* set the broadcast option - we need this to listen to DHCP broadcast messages */
    if (setsockopt(sock, SOL_SOCKET, SO_BROADCAST, (char*)&flag, sizeof flag) < 0) {
        printf("Error: Could not set broadcast option on DHCP socket!\n");
        exit(STATE_UNKNOWN);
    }

    /* bind socket to interface */
#if defined(__linux__)
    strncpy(interface.ifr_ifrn.ifrn_name, network_interface_name, IFNAMSIZ);
    if (setsockopt(sock, SOL_SOCKET, SO_BINDTODEVICE, (char*)&interface, sizeof(interface)) < 0) {
        printf("Error: Could not bind socket to interface %s.  Check your privileges...\n", network_interface_name);
        exit(STATE_UNKNOWN);
    }

#else
    strncpy(interface.ifr_name, network_interface_name, IFNAMSIZ);
#endif

    /* bind the socket */
    if (bind(sock, (struct sockaddr*)&myname, sizeof(myname)) < 0) {
        printf("Error: Could not bind to DHCP socket (port %d)!  Check your privileges...\n", DHCP_CLIENT_PORT);
        exit(STATE_UNKNOWN);
    }

    return sock;
}

/* closes DHCP socket */
int close_dhcp_socket(int sock)
{

    close(sock);

    return OK;
}

/* adds a requested server address to list in memory */
int add_requested_server(struct in_addr server_address)
{
    requested_server* new_server;

    new_server = (requested_server*)malloc(sizeof(requested_server));
    if (new_server == NULL)
        return ERROR;

    new_server->server_address = server_address;

    new_server->next = requested_server_list;
    requested_server_list = new_server;

    requested_servers++;

    if (verbose)
        printf("Requested server address: %s\n", inet_ntoa(new_server->server_address));

    return OK;
}

/* adds a DHCP OFFER to list in memory */
int add_dhcp_offer(struct in_addr source, dhcp_packet* offer_packet)
{
    dhcp_offer* new_offer;
    int x;
    int y;
    unsigned option_type;
    unsigned option_length;

    if (offer_packet == NULL)
        return ERROR;

    /* process all DHCP options present in the packet */
    for (x = 4; x < MAX_DHCP_OPTIONS_LENGTH;) {

        /* end of options (0 is really just a pad, but bail out anyway) */
        if ((int)offer_packet->options[x] == -1 || (int)offer_packet->options[x] == 0)
            break;

        /* get option type */
        option_type = offer_packet->options[x++];

        /* get option length */
        option_length = offer_packet->options[x++];

        if (verbose)
            printf("Option: %d (0x%02X)\n", option_type, option_length);

        /* get option data */
        if (option_type == DHCP_OPTION_LEASE_TIME) {
            memcpy(&dhcp_lease_time, &offer_packet->options[x], sizeof(dhcp_lease_time));
            dhcp_lease_time = ntohl(dhcp_lease_time);
        }
        if (option_type == DHCP_OPTION_RENEWAL_TIME) {
            memcpy(&dhcp_renewal_time, &offer_packet->options[x], sizeof(dhcp_renewal_time));
            dhcp_renewal_time = ntohl(dhcp_renewal_time);
        }
        if (option_type == DHCP_OPTION_REBINDING_TIME) {
            memcpy(&dhcp_rebinding_time, &offer_packet->options[x], sizeof(dhcp_rebinding_time));
            dhcp_rebinding_time = ntohl(dhcp_rebinding_time);
        }

        /* skip option data we're ignoring */
        else
            for (y = 0; y < option_length; y++, x++)
                ;
    }

    if (verbose) {
        if (dhcp_lease_time == DHCP_INFINITE_TIME)
            printf("Lease Time: Infinite\n");
        else
            printf("Lease Time: %lu seconds\n", (unsigned long)dhcp_lease_time);
        if (dhcp_renewal_time == DHCP_INFINITE_TIME)
            printf("Renewal Time: Infinite\n");
        else
            printf("Renewal Time: %lu seconds\n", (unsigned long)dhcp_renewal_time);
        if (dhcp_rebinding_time == DHCP_INFINITE_TIME)
            printf("Rebinding Time: Infinite\n");
        printf("Rebinding Time: %lu seconds\n", (unsigned long)dhcp_rebinding_time);
    }

    new_offer = (dhcp_offer*)malloc(sizeof(dhcp_offer));

    if (new_offer == NULL)
        return ERROR;

    new_offer->server_address = source;
    new_offer->offered_address = offer_packet->yiaddr;
    new_offer->lease_time = dhcp_lease_time;
    new_offer->renewal_time = dhcp_renewal_time;
    new_offer->rebinding_time = dhcp_rebinding_time;

    if (verbose) {
        printf("Added offer from server @ %s", inet_ntoa(new_offer->server_address));
        printf(" of IP address %s\n", inet_ntoa(new_offer->offered_address));
    }

    if (prometheus) {
        printf("dhcpdiscover { server=\"%s\", address=\"%s\", dev=\"%s\" } 1\n", inet_ntoa(new_offer->server_address), inet_ntoa(new_offer->offered_address), network_interface_name);
    }

    /* add new offer to head of list */
    new_offer->next = dhcp_offer_list;
    dhcp_offer_list = new_offer;

    return OK;
}

/* frees memory allocated to DHCP OFFER list */
int free_dhcp_offer_list(void)
{
    dhcp_offer* this_offer;
    dhcp_offer* next_offer;

    for (this_offer = dhcp_offer_list; this_offer != NULL; this_offer = next_offer) {
        next_offer = this_offer->next;
        free(this_offer);
    }

    return OK;
}

/* frees memory allocated to requested server list */
int free_requested_server_list(void)
{
    requested_server* this_server;
    requested_server* next_server;

    for (this_server = requested_server_list; this_server != NULL; this_server = next_server) {
        next_server = this_server->next;
        free(this_server);
    }

    return OK;
}

/* gets state and plugin output to return */
int get_results(void)
{
    dhcp_offer* temp_offer;
    requested_server* temp_server;
    int result;
    u_int32_t max_lease_time = 0;

    received_requested_address = FALSE;

    /* checks responses from requested servers */
    requested_responses = 0;
    if (requested_servers > 0) {

        for (temp_server = requested_server_list; temp_server != NULL; temp_server = temp_server->next) {

            for (temp_offer = dhcp_offer_list; temp_offer != NULL; temp_offer = temp_offer->next) {

                /* get max lease time we were offered */
                if (temp_offer->lease_time > max_lease_time || temp_offer->lease_time == DHCP_INFINITE_TIME)
                    max_lease_time = temp_offer->lease_time;

                /* see if we got the address we requested */
                if (!memcmp(&requested_address, &temp_offer->offered_address, sizeof(requested_address)))
                    received_requested_address = TRUE;

                /* see if the servers we wanted a response from talked to us or not */
                if (!memcmp(&temp_offer->server_address, &temp_server->server_address, sizeof(temp_server->server_address))) {
                    if (verbose) {
                        printf("DHCP Server Match: Offerer=%s", inet_ntoa(temp_offer->server_address));
                        printf(" Requested=%s\n", inet_ntoa(temp_server->server_address));
                    }
                    requested_responses++;
                }
            }
        }

    }

    /* else check and see if we got our requested address from any server */
    else {

        for (temp_offer = dhcp_offer_list; temp_offer != NULL; temp_offer = temp_offer->next) {

            /* get max lease time we were offered */
            if (temp_offer->lease_time > max_lease_time || temp_offer->lease_time == DHCP_INFINITE_TIME)
                max_lease_time = temp_offer->lease_time;

            /* see if we got the address we requested */
            if (!memcmp(&requested_address, &temp_offer->offered_address, sizeof(requested_address)))
                received_requested_address = TRUE;
        }
    }

    result = STATE_OK;
    if (valid_responses == 0)
        result = STATE_CRITICAL;
    else if (requested_servers > 0 && requested_responses == 0)
        result = STATE_CRITICAL;
    else if (requested_responses < requested_servers)
        result = STATE_WARNING;
    else if (request_specific_address == TRUE && received_requested_address == FALSE)
        result = STATE_WARNING;

    printf("DHCP %s: ", (result == STATE_OK) ? "ok" : "problem");

    /* we didn't receive any DHCPOFFERs */
    if (dhcp_offer_list == NULL) {
        printf("No DHCPOFFERs were received.\n");
        return result;
    }

    printf("Received %d DHCPOFFER(s)", valid_responses);

    if (requested_servers > 0)
        printf(", %s%d of %d requested servers responded", ((requested_responses < requested_servers) && requested_responses > 0) ? "only " : "", requested_responses, requested_servers);

    if (request_specific_address == TRUE)
        printf(", requested address (%s) was %soffered", inet_ntoa(requested_address), (received_requested_address == TRUE) ? "" : "not ");

    printf(", max lease time = ");
    if (max_lease_time == DHCP_INFINITE_TIME)
        printf("Infinity");
    else
        printf("%lu sec", (unsigned long)max_lease_time);

    printf(".\n");

    return result;
}

/* process command-line arguments */
int process_arguments(int argc, char** argv)
{
    int c;

    if (argc < 1)
        return ERROR;

    c = 0;
    while ((c += (call_getopt(argc - c, &argv[c]))) < argc) {

        /*
        if(is_option(argv[c]))
                continue;
        */
    }

    return validate_arguments();
}

int call_getopt(int argc, char** argv)
{
    int c = 0;
    int i = 0;
    struct in_addr ipaddress;

#ifdef HAVE_GETOPT_H
    int option_index = 0;
    int ret;
    static struct option long_options[] = { { "serverip", required_argument, 0, 's' }, { "requestedip", required_argument, 0, 'r' }, { "timeout", required_argument, 0, 't' }, { "interface", required_argument, 0, 'i' }, { "mac", required_argument, 0, 'm' }, { "bannedip", required_argument, 0, 'b' }, { "verbose", no_argument, 0, 'v' }, { "prometheus", no_argument, 0, 'p' }, { "version", no_argument, 0, 'V' }, { "help", no_argument, 0, 'h' }, { 0, 0, 0, 0 } };
#endif

    while (1) {
#ifdef HAVE_GETOPT_H
        c = getopt_long(argc, argv, "+hVvpt:s:r:t:i:m:b:", long_options, &option_index);
#else
        c = getopt(argc, argv, "+?hVvpt:s:r:t:i:m:b:");
#endif

        i++;

        if (c == -1 || c == EOF || c == 1)
            break;

        switch (c) {
        case 'w':
        case 'r':
        case 't':
        case 'i':
            i++;
            break;
        default:
            break;
        }

        switch (c) {

        case 'm': /* Our MAC address */
        {
            ret = sscanf(optarg, "%x:%x:%x:%x:%x:%x", my_client_mac + 0, my_client_mac + 1, my_client_mac + 2, my_client_mac + 3, my_client_mac + 4, my_client_mac + 5);
            if (ret != 6) {
                usage("Invalid MAC address\n");
                break;
            }
            for (i = 0; i < 6; ++i)
                client_hardware_address[i] = my_client_mac[i];
        }
            mymac = 1;
            break;
        case 'b': /* Banned IP */
            if (inet_aton(optarg, &ipaddress)) {
                banned_ip = ipaddress;
                banned = 1;
            } else
                printf("Banned IP not specified, ignoring -b");
            break;

        case 's': /* DHCP server address */
            if (inet_aton(optarg, &ipaddress))
                add_requested_server(ipaddress);
            /*
            else
                    usage("Invalid server IP address\n");
            */
            break;

        case 'r': /* address we are requested from DHCP servers */
            if (inet_aton(optarg, &ipaddress)) {
                requested_address = ipaddress;
                request_specific_address = TRUE;
            }
            /*
            else
                    usage("Invalid requested IP address\n");
            */
            break;

        case 't': /* timeout */

            /*
            if(is_intnonneg(optarg))
            */
            if (atoi(optarg) > 0)
                dhcpoffer_timeout = atoi(optarg);
            /*
            else
                    usage("Time interval must be a nonnegative integer\n");
            */
            break;

        case 'i': /* interface name */

            strncpy(network_interface_name, optarg, sizeof(network_interface_name) - 1);
            network_interface_name[sizeof(network_interface_name) - 1] = '\x0';

            break;

        case 'V': /* version */
            print_revision(progname, revision);
            exit(STATE_OK);

        case 'h': /* help */
            print_help();
            exit(STATE_OK);

        case 'v': /* verbose */
            verbose = 1;
            break;

        case 'p': /* prometheus */
            prometheus = 1;
            break;

        default: /* help */
            printf("Unknown argument", optarg);
            break;
        }
    }

    return i;
}

int validate_arguments(void) { return OK; }

#if defined(__sun__) || defined(__solaris__) || defined(__hpux__)

/* Kompf 2000-2003	see ACKNOWLEDGEMENTS */

/* get a message from a stream; return type of message */
static int get_msg(int fd)
{
    int flags = 0;
    int res, ret;
    ctl_area[0] = 0;
    dat_area[0] = 0;
    ret = 0;
    res = getmsg(fd, &ctl, &dat, &flags);

    if (res < 0) {
        if (errno == EINTR) {
            return (GOT_INTR);
        } else {
            printf("%s\n", "get_msg FAILED.");
            return (GOT_ERR);
        }
    }
    if (ctl.len > 0) {
        ret |= GOT_CTRL;
    }
    if (dat.len > 0) {
        ret |= GOT_DATA;
    }
    return (ret);
}

/* verify that dl_primitive in ctl_area = prim */
static int check_ctrl(int prim)
{
    dl_error_ack_t* err_ack = (dl_error_ack_t*)ctl_area;
    if (err_ack->dl_primitive != prim) {
        printf("Error: DLPI stream API failed to get MAC in check_ctrl: %s.\n", strerror(errno);
        exit(STATE_UNKNOWN);
    }
    return 0;
}

/* put a control message on a stream */
static int put_ctrl(int fd, int len, int pri)
{
    ctl.len = len;
    if (putmsg(fd, &ctl, 0, pri) < 0) {
        printf("Error: DLPI stream API failed to get MAC in put_ctrl/putmsg(): %s.\n", strerror(errno);
        exit(STATE_UNKNOWN);
    }
    return 0;
}

/* put a control + data message on a stream */
static int put_both(int fd, int clen, int dlen, int pri)
{
    ctl.len = clen;
    dat.len = dlen;
    if (putmsg(fd, &ctl, &dat, pri) < 0) {
        printf("Error: DLPI stream API failed to get MAC in put_both/putmsg().\n", strerror(errno);
        exit(STATE_UNKNOWN);
    }
    return 0;
}

/* open file descriptor and attach */
static int dl_open(const char* dev, int unit, int* fd)
{
    dl_attach_req_t* attach_req = (dl_attach_req_t*)ctl_area;
    if ((*fd = open(dev, O_RDWR)) == -1) {
        printf("Error: DLPI stream API failed to get MAC in dl_attach_req/open(%s..): %s.\n", dev, strerror(errno);
        exit(STATE_UNKNOWN);
    }
    attach_req->dl_primitive = DL_ATTACH_REQ;
    attach_req->dl_ppa = unit;
    put_ctrl(*fd, sizeof(dl_attach_req_t), 0);
    get_msg(*fd);
    return check_ctrl(DL_OK_ACK);
}

/* send DL_BIND_REQ */
static int dl_bind(int fd, int sap, u_char* addr)
{
    dl_bind_req_t* bind_req = (dl_bind_req_t*)ctl_area;
    dl_bind_ack_t* bind_ack = (dl_bind_ack_t*)ctl_area;
    bind_req->dl_primitive = DL_BIND_REQ;
    bind_req->dl_sap = sap;
    bind_req->dl_max_conind = 1;
    bind_req->dl_service_mode = DL_CLDLS;
    bind_req->dl_conn_mgmt = 0;
    bind_req->dl_xidtest_flg = 0;
    put_ctrl(fd, sizeof(dl_bind_req_t), 0);
    get_msg(fd);
    if (GOT_ERR == check_ctrl(DL_BIND_ACK)) {
        printf("Error: DLPI stream API failed to get MAC in dl_bind/check_ctrl(): %s.\n", strerror(errno);
        exit(STATE_UNKNOWN);
    }
    bcopy((u_char*)bind_ack + bind_ack->dl_addr_offset, addr, bind_ack->dl_addr_length);
    return 0;
}

/***********************************************************************
 * interface:
 * function mac_addr_dlpi - get the mac address of the interface with
 *                          type dev (eg lnc, hme) and unit (0, 1 ..)
 *
 * parameter: addr: an array of six bytes, has to be allocated by the caller
 *
 * return: 0 if OK, -1 if the address could not be determined
 *
 *
 ***********************************************************************/

long mac_addr_dlpi(const char* dev, int unit, u_char* addr)
{

    int fd;
    u_char mac_addr[25];

    if (GOT_ERR != dl_open(dev, unit, &fd)) {
        if (GOT_ERR != dl_bind(fd, INSAP, mac_addr)) {
            bcopy(mac_addr, addr, 6);
            return 0;
        }
    }
    close(fd);
    return -1;
}

/* Kompf 2000-2003 */

#endif

/* print usage help */
void print_help(void)
{

    print_revision(progname, revision);

    printf(COPYRIGHT, copyright, email);

    printf("\n\nThis program checks the existence and more details of a DHCP server\n\n");

    print_usage();

    printf("\
 -s, --serverip=IPADDRESS\n\
   IP address of DHCP server that we must hear from\n\
 -r, --requestedip=IPADDRESS\n\
   IP address that should be offered by at least one DHCP server\n\
 -m, --mac=MACADDRESS\n\
   Client MAC address to use for sending packets\n\
 -b, --bannedip=IPADDRESS\n\
   Server IP address to ignore\n\
 -t, --timeout=INTEGER\n\
   Seconds to wait for DHCPOFFER before timeout occurs\n\
 -i, --interface=STRING\n\
   Interface to to use for listening (i.e. eth0)\n\
 -v, --verbose\n\
   Print extra information (command-line use only)\n\
 -p, --prometheus\n\
   Print extra information in prometheus format\n\
 -h, --help\n\
   Print detailed help screen\n\
 -V, --version\n\
   Print version information\n\n\
Example: sudo ./dhcpdiscover -i eth0 -b 192.168.1.1\n\
");
}

void print_usage(void)
{
    printf("\
Usage: %s [-s serverip] [-r requestedip] [-m clientmac ] [-b bannedip] [-t timeout] [-i interface]\n\
                  [-v] [-p]",
        progname);
}
