// SPDX-License-Identifier: GPL-2.0
/*
 * Copyright (C) 2020 Aaron Goodman <aaronjg@alumni.stanford.edu>. All Rights Reserved.
 */

/*
 * sockopt_wrap.c provides a shared library that intercepts syscalls to various
 * networking functions to bind the sockets a source IP address and network device
 * and to set the firewall mark on otugoing packets. Parameters are set using the
 * DEVICE, SRCIP, FWMARK environment variables.
 *
 *  Additionally the FAMILY environment variable can be set to either 'ipv4' or
 *  'ipv6' to cause sockets opened with ipv6 or ipv4 to fail, respectively.
 *
 *  Each environment variable is optional, and if not set, the library will not
 *  enforce the particular parameter.
 */

#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <arpa/inet.h>
#include <net/ethernet.h>
#include <linux/if_packet.h>
#include <net/if.h>

static int (*next_socket)(int domain, int type, int protocol);
static int (*next_setsockopt)(int sockfd, int level, int optname,
                              const void *optval, socklen_t optlen);
static int (*next_bind)(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
static int (*next_close)(int fd);
static ssize_t (*next_send)(int sockfd, const void *buf, size_t len, int flags);
static ssize_t (*next_sendto)(int sockfd, const void *buf, size_t len, int flags,
                              const struct sockaddr *dest_addr, socklen_t addrlen);
static ssize_t (*next_sendmsg)(int sockfd, const struct msghdr *msg, int flags);
static int (*next_connect)(int sockfd, const struct sockaddr *addr,
                           socklen_t addrlen);
static int device=0;
static struct sockaddr_in source4 = {0};
#ifdef CONFIG_IPV6
static struct sockaddr_in6 source6 = {0};
#endif
static struct sockaddr * source = 0;
static int sockaddr_size = 0;
static int is_bound [1024] = {0};

#define next_func(x)\
void set_next_##x(){\
	if (next_##x) return;\
	next_##x = dlsym(RTLD_NEXT, #x);\
	dlerror_handle();\
	return;\
}

void dlerror_handle()
{
	char *msg;
	if ((msg = dlerror()) != NULL) {
		fprintf(stderr, "socket: dlopen failed : %s\n", msg);
		fflush(stderr);
		exit(EXIT_FAILURE);
	}
}

next_func(bind);
next_func(close);
next_func(setsockopt);
next_func(socket);
next_func(send);
next_func(sendto);
next_func(sendmsg);
next_func(connect);

void dobind(int sockfd)
{
	if (source && sockfd < 1024 && !is_bound[sockfd]) {
		set_next_bind();
		if (next_bind(sockfd, source, sockaddr_size)) {
			perror("failed to bind to ip address");
			next_close(sockfd);
			exit(EXIT_FAILURE);
		}
		is_bound[sockfd] = 1;
	}
}

int connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen)
{
	set_next_connect();
	dobind(sockfd);
	return next_connect(sockfd, addr, addrlen);
}

ssize_t send(int sockfd, const void *buf, size_t len, int flags)
{
	set_next_send();
	dobind(sockfd);
	return next_send(sockfd, buf, len, flags);
}

ssize_t sendto(int sockfd, const void *buf, size_t len, int flags,
               const struct sockaddr *dest_addr, socklen_t addrlen)
{
	set_next_sendto();
	dobind(sockfd);
	return next_sendto(sockfd, buf, len, flags, dest_addr, addrlen);
}

ssize_t sendmsg(int sockfd, const struct msghdr *msg, int flags)
{
	set_next_sendmsg();
	dobind(sockfd);
	return next_sendmsg(sockfd, msg, flags);
}

int bind (int sockfd, const struct sockaddr *addr, socklen_t addrlen)
{
	set_next_bind();
	if (device && addr->sa_family == AF_PACKET) {
		((struct sockaddr_ll*)addr)->sll_ifindex=device;
	}
	else if (source && addr->sa_family == AF_INET) {
		((struct sockaddr_in*)addr)->sin_addr = source4.sin_addr;
	}
#ifdef CONFIG_IPV6
	else if (source && addr->sa_family == AF_INET6) {
		((struct sockaddr_in6*)addr)->sin6_addr = source6.sin6_addr;
	}
#endif
	if (sockfd < 1024)
		is_bound[sockfd] = 1;
	return next_bind(sockfd, addr, addrlen);
}

int close (int sockfd)
{
	set_next_close();
	if (sockfd < 1024)
		is_bound[sockfd]=0;
	return next_close(sockfd);
}

int setsockopt(int sockfd, int level, int optname, const void *optval, socklen_t optlen)
{
	set_next_setsockopt();
	if (level == SOL_SOCKET && (optname == SO_MARK || optname == SO_BINDTODEVICE))
		return 0;
	return next_setsockopt(sockfd, level, optname, optval, optlen);
}

int socket(int domain, int type, int protocol)
{
	int handle;

	const char *socket_str = getenv("DEVICE");
	const char *srcip_str = getenv("SRCIP");
	const char *fwmark_str = getenv("FWMARK");
	const char *family_str = getenv("FAMILY");
	const int iface_len = socket_str ? strnlen(socket_str, IFNAMSIZ) : 0;
	int has_family = family_str && *family_str != 0;
	int has_srcip = srcip_str && *srcip_str != 0;
	const int fwmark = fwmark_str ? (int)strtol(fwmark_str, NULL, 0) : 0;

	set_next_close();
	set_next_socket();
	set_next_send();
	set_next_setsockopt();
	set_next_sendmsg();
	set_next_sendto();
	set_next_connect();
	if(has_family) {
#ifdef CONFIG_IPV6
		if(domain == AF_INET && strncmp(family_str,"ipv6",4) == 0)
			return -1;
#endif
		if(domain == AF_INET6 && strncmp(family_str,"ipv4",4) == 0)
			return -1;
	}

	if (domain != AF_INET
#ifdef CONFIG_IPV6
	    && domain != AF_INET6
#endif
		) {
		return next_socket(domain, type, protocol);
	}


	if (iface_len > 0) {
		if (iface_len == IFNAMSIZ) {
			fprintf(stderr,"socket: Too long iface name\n");
			fflush(stderr);
			exit(EXIT_FAILURE);
		}
	}

	if (has_srcip) {
		int s;
		void * addr_buf;
		if (domain == AF_INET) {
			addr_buf = &source4.sin_addr;
			sockaddr_size=sizeof source4;
			memset(&source4, 0, sockaddr_size);
			source4.sin_family = domain;
			source = (struct sockaddr*)&source4;
		}
#ifdef CONFIG_IPV6
		else {
			addr_buf = &source6.sin6_addr;
			sockaddr_size=sizeof source6;
			memset(&source6, 0, sockaddr_size);
			source6.sin6_family=domain;
			source = (struct sockaddr*)&source6;
		}
#endif
		s = inet_pton(domain, srcip_str, addr_buf);
		if (s == 0) {
			fprintf(stderr, "socket: ip address invalid format for family %s\n",
			        domain == AF_INET ? "AF_INET" : domain == AF_INET6 ?
			        "AF_INET6" : "unknown");
			return -1;
		}
		if (s < 0) {
			perror("inet_pton");
			exit(EXIT_FAILURE);
		}
	}

	handle = next_socket(domain, type, protocol);
	if (handle == -1 ) {
		return handle;
	}

	if (iface_len > 0) {
		device=if_nametoindex(socket_str);
		if (next_setsockopt(handle, SOL_SOCKET, SO_BINDTODEVICE,
		                    socket_str, iface_len + 1)) {
			perror("socket: setting interface name failed with error");
			next_close(handle);
			exit(EXIT_FAILURE);
		}
	}

	if (fwmark > 0) {
		if (next_setsockopt(handle, SOL_SOCKET, SO_MARK,
		                    &fwmark, sizeof fwmark)) {
			perror("failed setting mark for socket");
			next_close(handle);
			exit(EXIT_FAILURE);
		}
	}
	return handle;
}
