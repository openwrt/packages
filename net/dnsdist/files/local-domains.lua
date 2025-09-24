local M = {}

M.lanSuffixes = { 'lan' }
M.ttl = 1
M.destinations = nil

local ffi = require 'ffi'
local C = ffi.C

local common = require 'dnsdist/common'

local byName4 = {}
local byName6 = {}
local dhcpScriptPath = '/usr/share/lua/dnsdist/dnsdist-odhcpd.lua'

local qname_ret_ptr = ffi.new("char *[1]")
local qname_ret_ptr_param = ffi.cast("const char **", qname_ret_ptr)
local qname_ret_size = ffi.new("size_t[1]")
local qname_ret_size_param = ffi.cast("size_t*", qname_ret_size)

local ffi_copy = ffi.copy
local ffi_string = ffi.string
local string_sub = string.sub
local string_byte = string.byte
local table_insert = table.insert

local lanSuffixesMatchNode = nil

local function lanaction(dq)
    if lanSuffixesMatchNode == nil then
        return DNSAction.None
    end
    -- warnlog(string.format("checking type and name, dq=%s, dq.qtype=%s", dq, dq.qtype))
    local qtype = C.dnsdist_ffi_dnsquestion_get_qtype(dq)
    local byName

    if qtype == DNSQType.A then
        byName = byName4
    elseif qtype == DNSQType.AAAA then
        byName = byName6
    else
        -- queries for non-address types get an empty NOERROR
        C.dnsdist_ffi_dnsquestion_set_rcode(dq, DNSRCode.NOERROR)
        return DNSAction.Spoof
    end

    C.dnsdist_ffi_dnsquestion_get_qname_raw(dq, qname_ret_ptr_param, qname_ret_size_param)

    local qname = ffi_string(qname_ret_ptr[0], qname_ret_size[0])
    qname = newDNSNameFromRaw(qname)
    local suffix = lanSuffixesMatchNode:getBestMatch(qname)
    if suffix == nil then
        return DNSAction.None
    end
    if qname == suffix then
        -- queries for one of the exact suffixes (i.e `lan.`) get NOERROR
        C.dnsdist_ffi_dnsquestion_set_rcode(dq, DNSRCode.NOERROR)
        return DNSAction.Spoof
    end
    qname = qname:makeRelative(suffix)

    local ip = byName[qname:toStringNoDot()]
    if ip then
        local buf = ffi.new("char[?]", #ip + 1)
        ffi_copy(buf, ip)
        C.dnsdist_ffi_dnsquestion_set_result(dq, buf, #ip)
        C.dnsdist_ffi_dnsquestion_set_max_returned_ttl(dq, M.ttl)
        return DNSAction.Spoof
    else
        C.dnsdist_ffi_dnsquestion_set_rcode(dq, DNSRCode.NXDOMAIN)
        return DNSAction.Nxdomain
    end
end

function threadmessage(cmd, data)
    local name=data.name
    local ip=data.ip
    local proto=data.proto
    local byName
    if proto == 'v4' then
        byName = byName4
    elseif proto == 'v6' then
        byName = byName6
    else
        return
    end
    if name and ip
    then
        if cmd == 'add'
        then
            byName[name] = ip
        elseif cmd == 'del'
        then
            byName[name] = nil
        else
            warnlog(string.format("got unknown command '%s' from odhcpd thread", cmd))
        end
    end
    -- for k,v in pairs(msg) do warnlog(k..'/'..v) end
end

function M.run(_)
  if M.destinations == nil or #M.destinations == 0 or M.lanSuffixes == nil or #M.lanSuffixes == 0 then
    return
  end

  lanSuffixesMatchNode = newSuffixMatchNode()
  lanSuffixesMatchNode:add(M.lanSuffixes)

  local script = io.open(dhcpScriptPath)
  if script == nil then
    return
  end
  newThread(script:read("*a"))
  itfRules = {}
  for _, itf in ipairs(M.destinations) do
     table.insert(itfRules, TagRule(common.interfaceTagName, itf))
  end
  addAction(AndRule{OrRule(itfRules), SuffixMatchNodeRule(lanSuffixesMatchNode)}, LuaFFIAction(lanaction))
end

return M
