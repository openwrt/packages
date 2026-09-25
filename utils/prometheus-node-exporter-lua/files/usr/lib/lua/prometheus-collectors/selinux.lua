local function scrape()
  local enforcing_mode = get_contents("/sys/fs/selinux/enforce")

  if enforcing_mode ~= nil then
    metric("node_selinux_enabled", "gauge", nil, 0)
  else
    metric("node_selinux_enabled", "gauge", nil, 1)
    metric("node_selinux_current_mode", "gauge", nil, enforcing_mode)
  end
end

return { scrape = scrape }
