package all

import (
	//Blank imports for plugins to register themselves
	_ "github.com/influxdata/telegraf/plugins/outputs/exec"
	_ "github.com/influxdata/telegraf/plugins/outputs/file"
	_ "github.com/influxdata/telegraf/plugins/outputs/graphite"
	_ "github.com/influxdata/telegraf/plugins/outputs/http"
	_ "github.com/influxdata/telegraf/plugins/outputs/influxdb"
	_ "github.com/influxdata/telegraf/plugins/outputs/influxdb_v2"
	_ "github.com/influxdata/telegraf/plugins/outputs/prometheus_client"
	_ "github.com/influxdata/telegraf/plugins/outputs/syslog"
)
