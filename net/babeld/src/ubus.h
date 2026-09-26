/*
    IPC integration of babeld with OpenWrt.

    The ubus interface offers following functions:
    - add_filter '{"ifname":"eth0", "type":0, "metric":5000}'
        type:
            0: FILTER_TYPE_INPUT
            1: FILTER_TYPE_OUTPUT
            2: FILTER_TYPE_REDISTRIBUTE
            3: FILTER_TYPE_INSTALL
    - add_interface '{"ifname":"eth0"}'
    - get_info
    - get_neighbours
    - get_xroutes
    - get_routes

    All output is divided into IPv4 and IPv6.

    Ubus notifications are sent if we receive updates for
    - xroutes
    - routes
    - neighbours

    The format is:
    - {route,xroute,neighbour}.add: Object was added
    - {route,xroute,neighbour}.change: Object was changed
    - {route,xroute,neighbour}.flush: Object was flushed

*/

#include <stdbool.h>
#include <sys/select.h>

struct babel_route;
struct neighbour;
struct xroute;

// Whether to enable ubus bindings (boolean option).
extern int ubus_bindings;

/**
 * Initialize ubus interface.
 *
 * Connect to the ubus daemon and expose the ubus functions.
 *
 * @return if initializing ubus was successful
 */
bool babeld_add_ubus();

/**
 * Add ubus socket to given filedescriptor set.
 *
 * We need to check repeatedly if the ubus socket has something to read.
 * The functions allows to add the ubus socket to the normal while(1)-loop of
 * babeld.
 *
 * @param readfs: the filedescriptor set
 * @param maxfd: the current maximum file descriptor
 * @return the maximum file descriptor
 */
int babeld_ubus_add_read_sock(fd_set *readfds, int maxfd);

/**
 * Check and process ubus socket.
 *
 * If the ubus-socket signals that data is available, the ubus_handle_event is
 * called.
 */
void babeld_ubus_receive(fd_set *readfds);

/***
 * Notify the ubus bus that a new xroute is received.
 *
 * If a new xroute is received or changed, we will notify subscribers.
 *
 * @param xroute: xroute that experienced some change
 * @param kind: kind that describes if we have a flush, add or change
 */
void ubus_notify_xroute(struct xroute *xroute, int kind);

/***
 * Notify the ubus bus that a new route is received.
 *
 * If a new route is received or changed, we will notify subscribers.
 *
 * @param route: route that experienced some change
 * @param kind: kind that describes if we have a flush, add or change
 */
void ubus_notify_route(struct babel_route *route, int kind);

/***
 * Notify the ubus bus that a new neighbour is received.
 *
 * If a new neighbour is received or changed, we will notify subscribers.
 *
 * @param neigh: neighbour that experienced some change
 * @param kind: kind that describes if we have a flush, add or change
 */
void ubus_notify_neighbour(struct neighbour *neigh, int kind);
