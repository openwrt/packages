local function scrape()
  -- documetation about nf_conntrack:
  -- https://www.frozentux.net/iptables-tutorial/chunkyhtml/x1309.html
  nat_metric =  metric("node_nat_traffic", "counter" )
  for e in io.lines("/proc/net/nf_conntrack") do
    local fields = space_split(e)
    local src, sport, dest, dport, bytes;
    local direction = "transmit";
    for _, field in ipairs(fields) do
      if src == nil and string.match(field, '^src') then
        src = string.match(field,"src=([^ ]+)");
      elseif string.match(field, '^sport') then
        sport = string.match(field,"sport=([^ ]+)");
      elseif dest == nil and string.match(field, '^dst') then
        dest = string.match(field,"dst=([^ ]+)");
      elseif string.match(field, '^dport') then
        dport = string.match(field,"dport=([^ ]+)");
      elseif string.match(field, '^bytes') then
        local labels = { src = src, dest = dest, direction=direction, sport=sport, dport=dport }
        nat_metric(labels, string.match(field, "bytes=([^ ]+)"));
        direction = "receive"
      end
    end
  end
end

return { scrape = scrape }
