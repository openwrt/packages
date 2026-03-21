local function scrape()
    local metrics = {
        ["total.num.queries"                ] = metric("unbound_num_queries_total",                "counter"),
        ["total.num.queries.ip.ratelimited" ] = metric("unbound_num_queries_ip_ratelimited_total", "counter"),
        ["total.num.queries.cookie.valid"   ] = metric("unbound_num_queries_cookie_valid_total",   "counter"),
        ["total.num.queries.cookie.client"  ] = metric("unbound_num_queries_cookie_client_total",  "counter"),
        ["total.num.queries.cookie.invalid" ] = metric("unbound_num_queries_cookie_invalid_total", "counter"),
        ["total.num.queries.discard.timeout"] = metric("unbound_num_queries_discard_timeout_total","counter"),
        ["total.num.queries.wait.limit"     ] = metric("unbound_num_queries_wait_limit_total",     "counter"),
        ["total.num.cachehits"              ] = metric("unbound_cachehits_total",                  "counter"),
        ["total.num.cachemiss"              ] = metric("unbound_cachemiss_total",                  "counter"),
        ["total.num.prefetch"               ] = metric("unbound_prefetch_total",                   "counter"),
        ["total.num.queries.timed.out"      ] = metric("unbound_num_queries_timed_out_total",      "counter"),
        ["total.query.queue.time.us.max"    ] = metric("unbound_query_queue_time_us_max_total",    "counter"),
        ["total.num.expired"                ] = metric("unbound_num_expired_total",                "counter"),
        ["total.num.recursivereplies"       ] = metric("unbound_num_recursivereplies_total",       "counter"),
        ["total.num.dns.error.reports"      ] = metric("unbound_num_dns_error_reports_total",      "counter"),
        ["total.requestlist.avg"            ] = metric("unbound_requestlist_avg_total",            "counter"),
        ["total.requestlist.max"            ] = metric("unbound_requestlist_max_total",            "counter"),
        ["total.requestlist.overwritten"    ] = metric("unbound_requestlist_overwritten_total",    "counter"),
        ["total.requestlist.exceeded"       ] = metric("unbound_requestlist_exceeded_total",       "counter"),
        ["total.requestlist.current.all"    ] = metric("unbound_requestlist_current_all_total",    "counter"),
        ["total.requestlist.current.user"   ] = metric("unbound_requestlist_current_user_total",   "counter"),
        ["total.recursion.time.avg"         ] = metric("unbound_recursion_time_avg_total",         "counter"),
        ["total.recursion.time.median"      ] = metric("unbound_recursion_time_median_total",      "counter"),
    }

    local handle = io.popen("/usr/sbin/unbound-control stats_noreset | sed 's/_/./g'")
    if not handle then
        return nil, "failed to run unbound-control"
    end
    local out = handle:read("*a")
    handle:close()

    for line in out:gmatch("[^\r\n]+") do
        local key, val = line:match("^([%w%.]+)=(%-?[%d%.]+)$")
        if key and val then
            local n = tonumber(val)
            if metrics[key] then
                metrics[key]({}, n)
            end
        end
    end
end

return { scrape = scrape }
