/*
 * tinysshd-listen: minimal IPv4/IPv6 accept-and-fork TCP supervisor.
 * usage: tinysshd-listen [-c maxconns] ip port prog [args...]
 */

#include <arpa/inet.h>
#include <netinet/in.h>
#include <signal.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <unistd.h>

static volatile sig_atomic_t live = 0;

static void reap(int sig) {
    (void)sig;
    while (waitpid(-1, NULL, WNOHANG) > 0) live--;
}

int main(int argc, char **argv) {
    long maxconns = 0;

    if (argc >= 3 && strcmp(argv[1], "-c") == 0) {
        maxconns = atol(argv[2]);
        argv += 2;
        argc -= 2;
    }
    if (argc < 4) _exit(100);

    struct sockaddr_in a4 = {0};
    struct sockaddr_in6 a6 = {0};
    struct sockaddr *addr;
    socklen_t addrlen;
    int family;

    unsigned short port = (unsigned short)atoi(argv[2]);

    if (inet_pton(AF_INET, argv[1], &a4.sin_addr) == 1) {
        family = AF_INET;
        a4.sin_family = AF_INET;
        a4.sin_port = htons(port);
        addr = (struct sockaddr *)&a4;
        addrlen = sizeof(a4);
    } else if (inet_pton(AF_INET6, argv[1], &a6.sin6_addr) == 1) {
        family = AF_INET6;
        a6.sin6_family = AF_INET6;
        a6.sin6_port = htons(port);
        addr = (struct sockaddr *)&a6;
        addrlen = sizeof(a6);
    } else {
        _exit(100);
    }

    int lfd = socket(family, SOCK_STREAM, 0);
    if (lfd < 0) _exit(111);

    int one = 1;
    setsockopt(lfd, SOL_SOCKET, SO_REUSEADDR, &one, sizeof(one));

    if (bind(lfd, addr, addrlen) < 0) _exit(111);
    if (listen(lfd, 20) < 0) _exit(111);

    signal(SIGCHLD, reap);

    for (;;) {
        int cfd = accept(lfd, NULL, NULL);
        if (cfd < 0) continue;

        if (maxconns > 0 && live >= maxconns) {
            close(cfd);
            continue;
        }

        pid_t pid = fork();
        if (pid == 0) {
            close(lfd);
            dup2(cfd, 0);
            dup2(cfd, 1);
            close(cfd);
            execvp(argv[3], &argv[3]);
            _exit(111);
        }
        if (pid > 0) live++;
        close(cfd);
    }
}
