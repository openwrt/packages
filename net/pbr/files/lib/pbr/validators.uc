'use strict';
// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright 2020-2026 MOSSDeF, Stan Grishin (stangri@melmac.ca).
//
// Pure validation functions. Optionally receives stat() for is_phys_dev.

function create_validators(stat_fn) {

function str_contains(haystack, needle) { return haystack != null && needle != null && index('' + haystack, '' + needle) >= 0; }
function str_contains_word(haystack, needle) { return !!(haystack && needle) && index(split(trim('' + haystack), /\s+/), '' + needle) >= 0; }
function str_first_word(s) { let m = s ? match(trim('' + s), /^(\S+)/) : null; return m ? m[1] : ''; }

function is_ipv4(s) {
	if (!s) return false;
	return !!match('' + s, /^((25[0-5]|2[0-4][0-9]|1?[0-9]{1,2})\.){3}(25[0-5]|2[0-4][0-9]|1?[0-9]{1,2})(\/([0-2]?[0-9]|3[0-2]))?$/);
}

function is_mac_address(s) {
	if (!s) return false;
	return !!match('' + s, /^([0-9A-Fa-f]{2}:){5}([0-9A-Fa-f]{2})$/);
}

function is_ipv6(s) {
	if (!s) return false;
	s = '' + s;
	if (is_mac_address(s)) return false;
	return index(s, ':') >= 0;
}

function is_domain(s) {
	if (!s) return false;
	s = '' + s;
	if (is_ipv4(s)) return false;
	if (match(s, /^([0-9A-Fa-f]{2}-){5}([0-9A-Fa-f]{2})$/)) return false;
	return !!match(s, /^[a-zA-Z0-9]$/) || !!match(s, /^[a-zA-Z0-9][a-zA-Z0-9_-]{0,61}[a-zA-Z0-9]$/) ||
		!!match(s, /^([a-zA-Z0-9]([a-zA-Z0-9_-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$/);
}

function is_phys_dev(s) {
	if (!s) return false;
	s = '' + s;
	if (substr(s, 0, 1) != '@') return false;
	if (!stat_fn) return false;
	let dev = substr(s, 1);
	return stat_fn('/sys/class/net/' + dev)?.type == 'link'; // ucode-lsp disable
}

function is_url_file(s) { return !!s && substr('' + s, 0, 7) == 'file://'; }
function is_url_https(s) { return !!s && substr('' + s, 0, 8) == 'https://'; }
function is_url(s) { if (!s) return false; s = '' + s; return is_url_file(s) || substr(s, 0, 6) == 'ftp://' || substr(s, 0, 7) == 'http://' || is_url_https(s); }

function is_family_mismatch(a, b) {
	a = replace('' + (a || ''), '!', '');
	b = replace('' + (b || ''), '!', '');
	return (is_ipv4(a) && is_ipv6(b)) || (is_ipv6(a) && is_ipv4(b));
}

function filter_options(opt, values) {
	if (!values) return '';
	let is_negative = str_contains(opt, '_negative');
	let base_opt = is_negative ? replace(opt, '_negative', '') : opt;
	let parts = split(trim('' + values), /\s+/);
	let ret = [];
	for (let v in parts) {
		let negated = (substr('' + v, 0, 1) == '!');
		if (is_negative && !negated) continue;
		if (!is_negative && negated) continue;
		let check_val = negated ? substr('' + v, 1) : '' + v;
		let ok = false;
		switch (base_opt) {
		case 'phys_dev': ok = is_phys_dev(check_val); break;
		case 'mac_address': ok = is_mac_address(check_val); break;
		case 'domain': ok = is_domain(check_val); break;
		case 'ipv4': ok = is_ipv4(check_val); break;
		case 'ipv6': ok = is_ipv6(check_val); break;
		}
		if (ok) push(ret, v);
	}
	return join(' ', ret);
}

// An nft comment is a double-quoted string with a hard 128-BYTE limit, and the
// quote has no escape inside it: the first `"` ends the string and whatever
// follows becomes syntax nft cannot parse. Both failures are caught by the
// single `nft -c -f` in nft_file.apply(), which validates the WHOLE generated
// file, so one policy whose name carries a quote -- or simply runs long -- takes
// down every rule pbr writes, not just its own.
//
// Verified against nftables 1.0.9: `'`, `;`, `\`, `{}`, `$` and even a literal
// newline all parse; 128 bytes passes and 129 does not (the limit counts bytes,
// so 65 two-byte characters already fail); a multi-byte sequence left incomplete
// by the cut is accepted.
function nft_comment(s) {
	if (s == null) return '';
	// The quote becomes an apostrophe rather than being dropped, so a name like
	// `My "work" laptop` still reads the way its author wrote it. CR/LF/TAB
	// become spaces because this same string is also written as a trailing
	// `# comment` on a line of dnsmasq's nftset config, where an embedded
	// newline would inject a config line of its own.
	let clean = replace('' + s, /"/g, "'");
	clean = replace(clean, /[\r\n\t]/g, ' ');
	// A BYTE truncation, deliberately: ucode's length()/substr() count bytes and
	// so does nft's limit, so the two agree. Do not "improve" this into a
	// character-aware cut -- 64 two-byte characters would pass such a check at
	// 128 characters while still handing nft 256 bytes, which is the very
	// failure this guards against. A sequence left incomplete by the cut is
	// accepted by nft (verified), so there is nothing to repair afterwards.
	return (length(clean) > 128) ? substr(clean, 0, 128) : clean;
}

function inline_set(value) {
	if (!value) return '';
	let parts = split(trim('' + value), /\s+/);
	let result = [];
	for (let i in parts) {
		let cleaned = replace(i, /^[@!]/, '');
		push(result, cleaned);
	}
	return join(', ', result);
}

return {
	str_contains,
	str_contains_word,
	str_first_word,
	is_ipv4,
	is_ipv6,
	is_mac_address,
	is_domain,
	is_phys_dev,
	is_url_file,
	is_url_https,
	is_url,
	is_family_mismatch,
	filter_options,
	inline_set,
	nft_comment,
};

}

export default create_validators;
