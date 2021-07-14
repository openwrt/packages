#!/bin/sh

source /lib/functions.sh
config_load hass

source /usr/lib/hass/functions.sh
push_event $@
