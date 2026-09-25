#!/bin/sh

[ "$1" = python3-pytz ] || exit 0

python3 - << 'EOF'
import pytz
import datetime

utc = pytz.utc
assert utc.zone == 'UTC'

eastern = pytz.timezone('US/Eastern')
fmt = '%Y-%m-%d %H:%M:%S %Z%z'
loc_dt = eastern.localize(datetime.datetime(2026, 1, 1, 0, 0, 0))
assert loc_dt.strftime(fmt) is not None

utc_dt = loc_dt.astimezone(pytz.utc)
assert utc_dt.tzinfo is pytz.utc
EOF
