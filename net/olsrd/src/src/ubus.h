/*
    IPC integration of olsrd with OpenWrt.

    The ubus interface offers following functions:
    - add_inteface '{"ifname":"wg_51820", "lqm": "0.5"}'
    - del_inteface '{"ifname":"wg_51820"}'
*/

#include <stdbool.h>
#include <sys/select.h>

/**
 * Initialize ubus interface.
 *
 * Connect to the ubus daemon and expose the ubus functions.
 *
 * @return if initializing ubus was successful
 */
bool olsrd_add_ubus();

/**
 * Add ubus socket to given filedescriptor set.
 *
 * We need to check repeatedly if the ubus socket has something to read.
 * The functions allows to add the ubus socket to the normal while(1)-loop of
 * olsrd.
 *
 * @param readfs: the filedescriptor set
 * @param maxfd: the current maximum file descriptor
 * @return the maximum file descriptor
 */
int olsrd_ubus_add_read_sock(fd_set *readfds, int maxfd);

/**
 * Check and process ubus socket.
 *
 * If the ubus-socket signals that data is available, the ubus_handle_event is
 * called.
 */
void olsrd_ubus_receive(fd_set *readfds);
