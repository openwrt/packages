#!/bin/sh
set -u

event="$1"

# Call hotplug first, giving scripts a chance to modify certificates before
# reloadaing the services
ACTION=$event hotplug-call acme

case $event in
renewed)
    ubus call service event '{"type":"acme.renew","data":{}}'
    ;;
issued)
    ubus call service event '{"type":"acme.issue","data":{}}'
    ;;
esac
