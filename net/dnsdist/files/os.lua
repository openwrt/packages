local M = {}

local ffi = require 'ffi'
local lfs = require 'lfs'
local C = ffi.C

ffi.cdef[[
typedef struct timespec {
    long     tv_sec;        /* seconds */
    long     tv_nsec;       /* nanoseconds */
} timespec_t;

int clock_gettime(int clk_id, timespec_t *tp);
typedef unsigned int socklen_t;
const char *inet_ntop(int af, const void *restrict src,
                      char *restrict dst, socklen_t size);
int inet_pton(int af, const char *restrict src, void *restrict dst);

void _exit(int status);

unsigned int sleep(unsigned int seconds);
]]

local IS_MAC = (ffi.os == "OSX")
local IS_LINUX = (ffi.os == "Linux")

local CLOCK_MONOTONIC
local AF_INET
local AF_INET6
if IS_LINUX then
  CLOCK_MONOTONIC = 1
  AF_INET = 2
  AF_INET6 = 10
elseif IS_MAC then
  CLOCK_MONOTONIC = 6
  AF_INET = 2
  AF_INET6 = 10
else
  errlog('OS not supported: '..ffi.os)
end

local tv = ffi.new("struct timespec[?]", 1)

function M.getTimeUsec()
  C.clock_gettime(CLOCK_MONOTONIC, tv)
  return tv[0].tv_sec * 1000000 + tv[0].tv_nsec / 1000
end

local pton_dst = ffi.new("char[?]", 16)
local inet_buffer = ffi.new("char[?]", 256)

function M.convertIPv4ToBinary(str)
  C.inet_pton(AF_INET, str, pton_dst)
  return ffi.string(pton_dst, 4)
end

function M.convertIPv6ToBinary(str)
  C.inet_pton(AF_INET6, str, pton_dst)
  return ffi.string(pton_dst, 16)
end

function M.binaryIPv4ToString(addr)
  local str = C.inet_ntop(2, addr, inet_buffer, 256)
  return str ~= nil and ffi.string(str) or ''
end

function M.binaryIPv6ToString(addr)
  local str = C.inet_ntop(10, addr, inet_buffer, 256)
  return str ~= nil and ffi.string(str) or ''
end

function M.getCommandReturnCode(command)
  return os.execute(command)
end

function M.getCommandOutput(command)
  local desc = io.popen(command)
  if desc == nil then
    return nil
  end
  desc:flush()
  local output = desc:read('*all')
  desc:close()
  return output
end

function M.getFileContent(file)
  local desc = io.open(file, "rb")
  if desc == nil then
    return nil
  end
  local content = desc:read("*all")
  desc:close()
  return content
end

function M.getPSS()
  local smaps_rollup_file = '/proc/self/smaps_rollup'
  local pss_pattern = 'Pss:'
  local kb_pattern = ' Kb'
  if not M.fileExists(smaps_rollup_file) then
    return 0
  end
  for line in io.lines(smaps_rollup_file) do
    if string.sub(line, 1, #pss_pattern) == pss_pattern then
      local remaining = string.sub(line, #pss_pattern + 1, -(#kb_pattern + 1))
      local value = tonumber(remaining)
      if value then
         return value
      else
        return 0
      end
    end
  end
  return 0
end

function M.getFileModificationTime(path)
  local stats = lfs.attributes(path)
  if stats ~= nil then
     return stats.modification
  end
  return 0
end

function M.fileExists(path)
  local stats = lfs.attributes(path)
  if stats ~= nil then
     return true
  end
  return false
end

function M.exit(code)
  C._exit(code)
end

local os_time = os.time
function M.time()
  return os_time()
end

function M.sleep(seconds)
  return C.sleep(seconds)
end

return M
