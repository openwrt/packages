local json = require "cjson"

local function scrape()
  local sh = io.popen("tc -s -j qdisc")
  local qdisc = json.decode(sh:read("*a"))
  sh:close()

  for k, q in pairs(qdisc) do
    if q["kind"] == "cake" then
      dir = q["options"]["ingress"] and "ingress" or "egress"
      local labels = {
        direction = dir,
        dev = q["options"]["dev"],
        type = q["options"]["diffserv"],
      }
      metric("sqm_qdisc_bytes", "gauge", labels, q["bytes"])
      metric("sqm_qdisc_bandwidth", "gauge", labels, q["options"]["bandwidth"])
      metric("sqm_qdisc_drops", "gauge", labels, q["drops"])
      metric("sqm_qdisc_backlog", "gauge", labels, q["backlog"])

      local metric_bytes = metric("sqm_qdisc_tin_bytes","gauge")
      local metric_thresh = metric("sqm_qdisc_tin_thresh","gauge")
      local metric_drops = metric("sqm_qdisc_tin_drops","gauge")
      local metric_ecn_mark = metric("sqm_qdisc_tin_ecn_mark","gauge")
      local metric_backlog = metric("sqm_qdisc_tin_backlog","gauge")
      local metric_unresponsive_flows = metric("sqm_qdisc_tin_unresponsive_flows","gauge")
      local metric_bulk_flows = metric("sqm_qdisc_tin_bulk_flows","gauge")
      local metric_sparse_flows = metric("sqm_qdisc_tin_sparse_flows","gauge")
      local metric_peak_latency = metric("sqm_qdisc_tin_peak_latency","gauge")
      local metric_avg_latency = metric("sqm_qdisc_tin_avg_latency","gauge")
      local metric_base_latency = metric("sqm_qdisc_tin_base_latency","gauge")
      local metric_target_latency = metric("sqm_qdisc_tin_target_latency","gauge")

      local tin_types = q["options"]["diffserv"] == "diffserv4" and {"bulk", "best_effort", "video", "voice"} or {"bulk", "best_effort", "voice"}
      for c, tin in pairs(q["tins"]) do
        labels["tin"] = tin_types[c]
        metric_bytes(labels, tin.sent_bytes)
        metric_ecn_mark(labels, tin.ecn_mark)
        metric_thresh(labels, tin.threshold_rate)
        metric_drops(labels, tin.drops)
        metric_backlog(labels, tin.backlog_bytes)
        metric_unresponsive_flows(labels, tin.unresponsive_flows)
        metric_bulk_flows(labels, tin.bulk_flows)
        metric_sparse_flows(labels, tin.sparse_flows)
        metric_target_latency(labels, tin.target_us)
        metric_base_latency(labels, tin.base_delay_us)
        metric_peak_latency(labels, tin.peak_delay_us)
        metric_avg_latency(labels, tin.avg_delay_us)
      end
    end
  end
end

return { scrape = scrape }

