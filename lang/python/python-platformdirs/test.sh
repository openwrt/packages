#!/bin/sh

[ "$1" = python3-platformdirs ] || exit 0

python3 - << 'EOF'

from platformdirs import *
appname = "SuperApp"
appauthor = "Acme"

assert user_data_dir(appname, appauthor) == '/root/.local/share/SuperApp'
assert user_cache_dir(appname, appauthor) == '/root/.cache/SuperApp'
assert user_log_dir(appname, appauthor) == '/root/.local/state/SuperApp/log'
assert user_config_dir(appname) == '/root/.config/SuperApp'
assert user_documents_dir() == '/root/Documents'
assert user_downloads_dir() == '/root/Downloads'
assert user_pictures_dir() == '/root/Pictures'
assert user_videos_dir() == '/root/Videos'
assert user_music_dir() == '/root/Music'
assert user_desktop_dir() == '/root/Desktop'
assert user_runtime_dir(appname, appauthor) == '/run/user/0/SuperApp'

assert site_data_dir(appname, appauthor) == '/usr/local/share/SuperApp'
assert site_data_dir(appname, appauthor, multipath=True) == '/usr/local/share/SuperApp:/usr/share/SuperApp'

assert site_config_dir(appname) == '/etc/xdg/SuperApp'

import os
os.environ["XDG_CONFIG_DIRS"] = "/etc:/usr/local/etc"

assert site_config_dir(appname, multipath=True) == '/etc/SuperApp:/usr/local/etc/SuperApp'

EOF
