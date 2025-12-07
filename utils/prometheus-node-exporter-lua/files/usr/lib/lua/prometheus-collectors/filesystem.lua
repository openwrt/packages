#!/usr/bin/lua

-- depends on luci-lib-nixio
local nix = require "nixio"

local function scrape()
  -- node exporter description - Filesystem size in bytes
  local metric_size_bytes = metric("node_filesystem_size_bytes", "gauge")
  -- node exporter description - Filesystem free space in bytes
  local metric_free_bytes = metric("node_filesystem_free_bytes", "gauge")
  -- node exporter description - Filesystem space available to non-root users in bytes
  local metric_avail_bytes = metric("node_filesystem_avail_bytes", "gauge")
  -- node exporter description - Filesystem total file nodes
  local metric_files = metric("node_filesystem_files", "gauge")
  -- node exporter description - Filesystem total free file nodes
  local metric_files_free = metric("node_filesystem_files_free", "gauge")
  -- node exporter description - Filesystem read-only status
  local metric_readonly = metric("node_filesystem_readonly", "gauge")

  for e in io.lines("/proc/self/mounts") do
    local fields = space_split(e)

    local device = fields[1]
    local mount_point = fields[2]
    local fs_type = fields[3]

    -- Filter list from node exporter:
    -- https://github.com/prometheus/node_exporter/blob/b9d0932179a0c5b3a8863f3d6cdafe8584cedc8e/collector/filesystem_linux.go#L36-L37
    if mount_point:find("/dev/?", 1) ~= 1
        and mount_point:find("/proc/?", 1) ~= 1
        and mount_point:find("/run/credentials/?", 1) ~= 1
        and mount_point:find("/sys/?", 1) ~= 1
        and mount_point:find("/var/lib/docker/?", 1) ~= 1
        and mount_point:find("/var/lib/containers/storage/?", 1) ~= 1
        and fs_type ~= "autofs"
        and fs_type ~= "binfmt_misc"
        and fs_type ~= "bpf"
        and fs_type ~= "cgroup"
        and fs_type ~= "cgroup2"
        and fs_type ~= "configfs"
        and fs_type ~= "debugfs"
        and fs_type ~= "devpts"
        and fs_type ~= "devtmpfs"
        and fs_type ~= "fusectl"
        and fs_type ~= "hugetlbfs"
        and fs_type ~= "iso9660"
        and fs_type ~= "mqueue"
        and fs_type ~= "nsfs"
        and fs_type ~= "overlay"
        and fs_type ~= "proc"
        and fs_type ~= "procfs"
        and fs_type ~= "pstore"
        and fs_type ~= "rpc_pipefs"
        and fs_type ~= "securityfs"
        and fs_type ~= "selinuxfs"
        and fs_type ~= "squashfs"
        and fs_type ~= "sysfs"
        and fs_type ~= "tracefs" then
      -- note that this excludes / as it's an overlay filesystem

      local stat = nix.fs.statvfs(mount_point)

      -- https://github.com/torvalds/linux/blob/e5fa841af679cb830da6c609c740a37bdc0b8b35/include/linux/statfs.h#L31
      local ST_RDONLY = 0x001

      local labels = {
        device = device,
        fstype = fs_type,
        mountpoint = mount_point,
      }

      local ro = 0
      if (nix.bit.band(stat.flag, ST_RDONLY)) == 1 then
        ro = 1
      end

      metric_size_bytes(labels, stat.blocks * stat.bsize)
      metric_free_bytes(labels, stat.bfree * stat.bsize)
      metric_avail_bytes(labels, stat.bavail * stat.bsize)
      metric_files(labels, stat.files)
      metric_files_free(labels, stat.ffree)
      metric_readonly(labels, ro)
    end
  end
end

return { scrape = scrape }
