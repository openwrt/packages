// SPDX-License-Identifier: BSD-2-Clause-Patent
#include "wpa_ctrl_client.h"
#include <easylogging++.h>

#include <cassert>
#include <cstring>
#include <iostream>
#include <sys/socket.h>
#include <sys/un.h>
#include <thread>
#include <unistd.h>

INITIALIZE_EASYLOGGINGPP

static int server(const std::string &path)
{
    int fd = socket(AF_UNIX, SOCK_DGRAM, 0);
    assert(fd >= 0);
    sockaddr_un address{};
    address.sun_family = AF_UNIX;
    assert(path.size() < sizeof(address.sun_path));
    std::strcpy(address.sun_path, path.c_str());
    assert(bind(fd, reinterpret_cast<sockaddr *>(&address), sizeof(address)) == 0);
    timeval timeout{2, 0};
    assert(setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout)) == 0);
    return fd;
}

static void request(bwl::nl80211::wpa_ctrl_socket_cmd &client, int fd, const char *response)
{
    std::thread daemon([&]() {
        char command[32];
        sockaddr_un peer{};
        socklen_t length = sizeof(peer);
        auto size = recvfrom(fd, command, sizeof(command), 0,
                             reinterpret_cast<sockaddr *>(&peer), &length);
        assert(size == 4 && std::memcmp(command, "PING", 4) == 0);
        assert(sendto(fd, response, std::strlen(response), 0,
                      reinterpret_cast<sockaddr *>(&peer), length) ==
               static_cast<ssize_t>(std::strlen(response)));
    });
    char reply[32]{};
    assert(client.request("PING", reply, sizeof(reply)));
    assert(std::strcmp(reply, response) == 0);
    daemon.join();
}

int main()
{
    char directory[] = "/tmp/prplmesh-ctrl-test.XXXXXX";
    assert(mkdtemp(directory));
    std::string path = std::string(directory) + "/hostapd";
    int fd = server(path);
    bwl::nl80211::wpa_ctrl_socket_cmd client(path);
    assert(client.connect());
    request(client, fd, "PONG-1");

    // Replace the daemon socket at the same path without recreating the HAL.
    close(fd);
    unlink(path.c_str());
    fd = server(path);
    request(client, fd, "PONG-2");

    // A missing endpoint fails, then a later request recovers when it returns.
    close(fd);
    unlink(path.c_str());
    char reply[32];
    assert(!client.request("PING", reply, sizeof(reply)));
    fd = server(path);
    request(client, fd, "PONG-3");
    client.disconnect(true);
    close(fd);
    unlink(path.c_str());
    rmdir(directory);
    std::cout << "WPA control socket replacement and recovery tests passed\n";
}
