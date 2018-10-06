local function scrape()
  metric("node_nf_conntrack_entries", "gauge", nil,
    string.sub(get_contents("/proc/sys/net/netfilter/nf_conntrack_count"), 1, -2))
  metric("node_nf_conntrack_entries_limit", "gauge", nil,
    string.sub(get_contents("/proc/sys/net/netfilter/nf_conntrack_max"), 1, -2))
end

return { scrape = scrape }
