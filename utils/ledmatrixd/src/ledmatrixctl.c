// SPDX-License-Identifier: GPL-2.0-or-later
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <sys/un.h>
#include <unistd.h>

#define SERVER_PATH "/var/run/ledmatrixd.sock"

int main(int argc, char **argv)
{
	struct sockaddr_un local = { .sun_family = AF_UNIX };
	struct sockaddr_un server = { .sun_family = AF_UNIX };
	char command[512], reply[256];
	struct timeval timeout = { .tv_sec = 3 };
	ssize_t n;
	int fd;

	if (argc == 2 && (!strcmp(argv[1], "--version") || !strcmp(argv[1], "-V"))) {
		printf("ledmatrixctl %s\n", VERSION);
		return 0;
	}
	if (argc < 2 || (argc == 2 && !strcmp(argv[1], "--help"))) {
		fprintf(argc < 2 ? stderr : stdout,
			"Usage: ledmatrixctl preview MODE | brightness VALUE | frame HEX | restore\n");
		return argc < 2;
	}
	command[0] = 0;
	for (int i = 1; i < argc; i++) {
		size_t used = strlen(command);
		snprintf(command + used, sizeof(command) - used, "%s%s", i == 1 ? "" : " ", argv[i]);
	}

	fd = socket(AF_UNIX, SOCK_DGRAM | SOCK_CLOEXEC, 0);
	if (fd < 0) {
		perror("ledmatrixctl: socket");
		return 1;
	}
	if (setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout)) < 0) {
		perror("ledmatrixctl: setsockopt");
		close(fd);
		return 1;
	}

	snprintf(local.sun_path, sizeof(local.sun_path), "/tmp/ledmatrixctl.%ld", (long)getpid());
	snprintf(server.sun_path, sizeof(server.sun_path), "%s", SERVER_PATH);
	unlink(local.sun_path);
	if (bind(fd, (struct sockaddr *)&local, sizeof(local)) < 0 ||
	    sendto(fd, command, strlen(command), 0, (struct sockaddr *)&server, sizeof(server)) < 0) {
		fprintf(stderr, "ledmatrixctl: %s\n", strerror(errno));
		close(fd);
		unlink(local.sun_path);
		return 1;
	}

	n = recv(fd, reply, sizeof(reply) - 1, 0);
	if (n >= 0) {
		reply[n] = 0;
		fputs(reply, stdout);
	}
	else {
		fprintf(stderr, "ledmatrixctl: %s\n", strerror(errno));
	}
	close(fd);
	unlink(local.sun_path);
	return n < 0;
}
