#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <stddef.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/un.h>

const char *usage =
    "Write to and read from a Unix domain socket.\n"
    "Add commands to send as arguments or pass by pipe.\n"
    "\n"
    "Usage: sockread <path> [<commands>]\n";

int main(int argc, char *argv[])
{
    char buffer[1024];
    ssize_t r;

    if (argc < 2) {
        fprintf(stderr, "%s", usage);
        return EXIT_FAILURE;
    }

    struct sockaddr_un address = {0};
    address.sun_family = AF_UNIX;
    strcpy((char*) &address.sun_path, argv[1]);

    int sock = socket(AF_UNIX, SOCK_STREAM, 0);
    if (sock < 0) {
        fprintf(stderr, "socket() %s\n", strerror(errno));
        return EXIT_FAILURE;
    }

    if (connect(sock, (struct sockaddr*)&address, sizeof(address)) < 0) {
        fprintf(stderr, "connect() %s\n", strerror(errno));
        return EXIT_FAILURE;
    }

    /* Check if stdin refers to a terminal */
    if (!isatty(fileno(stdin))) {
        /* Read from stdin and write to socket */
        while (0 < (r = fread(buffer, 1, sizeof(buffer), stdin))) {
            send(sock, buffer, r, 0);
        }
    } else {
        for (size_t i = 2; i < argc; i++) {
            if (i > 2) {
                send(sock, " ", 1, 0);
            }
            send(sock, argv[i], strlen(argv[i]), 0);
        }
    }

    /* Read from socket and write to stdout */
    while (1) {
        r = recv(sock, buffer, sizeof(buffer), 0);
        if (r < 0) {
            fprintf(stderr, "recv() %s\n", strerror(errno));
            return EXIT_FAILURE;
        }

        if (r == 0)
            break;

        fwrite(buffer, r, 1, stdout);
    }

    return EXIT_SUCCESS;
}
