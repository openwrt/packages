{%
let fs = require("fs");

let o_dst_bypass4_ = "
    0.0.0.0/8
    10.0.0.0/8
    100.64.0.0/10
    127.0.0.0/8
    169.254.0.0/16
    172.16.0.0/12
    192.0.0.0/24
    192.0.2.0/24
    192.31.196.0/24
    192.52.193.0/24
    192.88.99.0/24
    192.168.0.0/16
    192.175.48.0/24
    198.18.0.0/15
    198.51.100.0/24
    203.0.113.0/24
    224.0.0.0/4
    240.0.0.0/4
";
let o_dst_bypass6_ = "
    ::1/128
    ::/128
    ::ffff:0:0/96
    64:ff9b:1::/48
    100::/64
    fe80::/10
    2001::/23
    fc00::/7
";
let o_dst_bypass_ = o_dst_bypass4_ + " " + o_dst_bypass6_;

let set_suffix = {
    "src_bypass": {
        str: o_src_bypass,
    },
    "src_forward": {
        str: o_src_forward,
    },
    "src_checkdst": {
        str: o_src_checkdst,
    },
    "dst_bypass": {
        str: o_dst_bypass + " " + o_remote_servers,
        file: o_dst_bypass_file,
    },
    "dst_bypass_": {
        str: o_dst_bypass_,
    },
    "dst_forward": {
        str: o_dst_forward,
        file: o_dst_forward_file,
    },
    "dst_forward_rrst_": {},
};

function set_name(suf, af) {
    if (af == 4) {
        return "ss_rules_"+suf;
    } else {
        return "ss_rules6_"+suf;
    }
}

function set_elements_parse(res, str, af) {
    for (let addr in split(str, /[ \t\n]/)) {
        addr = trim(addr);
        if (!addr) continue;
        if (af == 4 && index(addr, ":") != -1) continue;
        if (af == 6 && index(addr, ":") == -1) continue;
        push(res, addr);
    }
}

function set_elements(suf, af) {
    let obj = set_suffix[suf];
    let res = [];
    let addr;

    let str = obj["str"];
    if (str) {
        set_elements_parse(res, str, af);
    }

    let file = obj["file"];
    if (file) {
        let fd = fs.open(file);
        if (fd) {
            str = fd.read("all");
            set_elements_parse(res, str, af);
        }
    }

    return res;
}
%}

{% for (let suf in set_suffix): for (let af in [4, 6]): %}
set {{ set_name(suf, af) }} {
    type ipv{{af}}_addr;
    flags interval;
    auto-merge;
{%   let elems = set_elements(suf, af); if (length(elems)): %}
    elements = {
{%     for (let i = 0; i < length(elems); i++): %}
        {{ elems[i] }}{% if (i < length(elems) - 1): %},{% endif %}{% print("\n") %}
{%     endfor %}
    }
{%   endif %}
}
{% endfor; endfor %}
