-- Unbound stats exporter

local socket = require("socket")
local unix = require("socket.unix")

local function scrape()
    local metrics = {
        ["total.num.queries"                ] = metric("unbound_num_queries_total",                "counter"),
        ["total.num.queries_ip_ratelimited" ] = metric("unbound_num_queries_ip_ratelimited_total", "counter"),
        ["total.num.queries_cookie_valid"   ] = metric("unbound_num_queries_cookie_valid_total",   "counter"),
        ["total.num.queries_cookie_client"  ] = metric("unbound_num_queries_cookie_client_total",  "counter"),
        ["total.num.queries_cookie_invalid" ] = metric("unbound_num_queries_cookie_invalid_total", "counter"),
        ["total.num.queries_discard_timeout"] = metric("unbound_num_queries_discard_timeout_total","counter"),
        ["total.num.queries_wait_limit"     ] = metric("unbound_num_queries_wait_limit_total",     "counter"),
        ["total.num.cachehits"              ] = metric("unbound_cachehits_total",                  "counter"),
        ["total.num.cachemiss"              ] = metric("unbound_cachemiss_total",                  "counter"),
        ["total.num.prefetch"               ] = metric("unbound_prefetch_total",                   "counter"),
        ["total.num.queries_timed_out"      ] = metric("unbound_num_queries_timed_out_total",      "counter"),
        ["total.query.queue_time_us.max"    ] = metric("unbound_query_queue_time_us_max",          "gauge"),
        ["total.num.expired"                ] = metric("unbound_num_expired_total",                "counter"),
        ["total.num.recursivereplies"       ] = metric("unbound_num_recursivereplies_total",       "counter"),
        ["total.num.dns_error_reports"      ] = metric("unbound_num_dns_error_reports_total",      "counter"),
        ["total.requestlist.avg"            ] = metric("unbound_requestlist_avg",                  "gauge"),
        ["total.requestlist.max"            ] = metric("unbound_requestlist_max",                  "gauge"),
        ["total.requestlist.overwritten"    ] = metric("unbound_requestlist_overwritten_total",    "counter"),
        ["total.requestlist.exceeded"       ] = metric("unbound_requestlist_exceeded_total",       "counter"),
        ["total.requestlist.current.all"    ] = metric("unbound_requestlist_current_all",          "gauge"),
        ["total.requestlist.current.user"   ] = metric("unbound_requestlist_current_user",         "gauge"),
        ["total.recursion.time.avg"         ] = metric("unbound_recursion_time_avg",               "gauge"),
        ["total.recursion.time.median"      ] = metric("unbound_recursion_time_median",            "gauge"),
    }

    local sock = unix()
    local ok, err = sock:connect("/run/unbound.ctl")
    if not ok then
        return nil, "failed to connect to unbound socket: " .. (err or "unknown")
    end

    sock:settimeout(1)
    sock:send("UBCT1 stats_noreset\n")

    local chunks = {}
    while true do
        local chunk, err, partial = sock:receive(4096)
        if partial and partial ~= "" then
            chunks[#chunks + 1] = partial
        end
        if not chunk then break end
        chunks[#chunks + 1] = chunk
    end
    sock:close()

    local out = table.concat(chunks)

    for line in out:gmatch("[^\r\n]+") do
        local key, val = line:match("^([%w%._]+)=(%-?[%d%.]+)$")
        if key and val then
            local n = tonumber(val)
            if metrics[key] then
                metrics[key]({}, n)
            end
        end
    end
end

return { scrape = scrape }
