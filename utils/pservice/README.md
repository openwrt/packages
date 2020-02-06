# uci

`disabled`, bool, default `0`

`name`, string, name of the service instance

`command`, file, the service instance executable

`args`, list of args

`stderr`, bool, default `0`, log stderr output of the service instance

`stdout`, bool, default `0`, log stdout output of the service instance

`env`, list of environment variable settings of the form `var=val`

`file`, list of file names.  Service instances will be restarted if content of
these files have changed on service reload event.

`respawn_threshold`, uinteger, default `3600`, time in seconds the instances
have to be in running state to be considered a valid run

`respawn_timeout`, uinteger, default `5`, time in seconds the instance should
be delayed to start again after the last crash

`respawn_maxfail`, uinteger, default `5`, maximum times the instances can
crash/fail in a row and procd will not try to bring it up again after this
limit has been reached

# notes and faq

Initial environment variables presented to service instances may be different
from what was observed on the interactive terminal.  E.g. `HOME=/` may affect
reading `~/.ssh/known_hosts` of dropbear ssh instance.

	PATH=/usr/sbin:/usr/bin:/sbin:/bin PWD=/ HOME=/

If `list args xxx` seems to be too long causing pain, consider using `/bin/sh`
as the `command`.  It is also worth noting that uci supports multi-line option
value.

Child processes will keep running when their parent process was killed.  This
is especially the case and should be taken into account with option `command`
being `/bin/sh` and it is recommended to use `exec` as the last shell command.
