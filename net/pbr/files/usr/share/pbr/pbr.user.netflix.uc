// Downloads Netflix (AS2906) IP ranges and adds them to the PBR user destination sets.
// Based on https://github.com/Xentrk/netflix-vpn-bypass/blob/master/IPSET_Netflix.sh
// Credits to https://forum.openwrt.org/u/dscpl for api.hackertarget.com code.
// Credits to https://github.com/kkeker and https://github.com/tophirsch for api.bgpview.io code.

return function(api) {
	if (!api.compat || api.compat < 29) return;

	let iface = 'wan';
	let asn = '2906';
	let db_source = 'ipinfo.io';
	// let db_source = 'api.hackertarget.com';
	// let db_source = 'api.bgpview.io';
	let re_ipv4 = '[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\/[0-9]+';
	let re_ipv6 = '.*::.*?';

	let _extract_prefixes = function(raw, family) {
		let prefixes = [];
		if (db_source == 'ipinfo.io') {
			let re = regexp('\\/AS[0-9]+\\/(' + ((family == 4) ? re_ipv4 : re_ipv6) + ')["]');
			for (let line in split(raw, '\n')) {
				let m = match(line, re);
				if (m) push(prefixes, m[1]);
			}
		} else if (db_source == 'api.hackertarget.com') {
			let lines = split(raw, '\n');
			for (let i = 1; i < length(lines); i++)
				if (trim(lines[i])) push(prefixes, trim(lines[i]));
		} else if (db_source == 'api.bgpview.io') {
			let data = json(raw);
			if (!data) return prefixes;
			let key = (family == 4) ? 'ipv4_prefixes' : 'ipv6_prefixes';
			for (let entry in data?.data?.[key])
				if (entry.prefix) push(prefixes, entry.prefix);
		}
		return prefixes;
	};

	let set4 = api.nftset(iface, '4');
	let set6 = api.nftset(iface, '6');

	// IPv4
	let url4;
	if (db_source == 'ipinfo.io')
		url4 = 'https://ipinfo.io/AS' + asn;
	else if (db_source == 'api.hackertarget.com')
		url4 = 'https://api.hackertarget.com/aslookup/?q=AS' + asn;
	else if (db_source == 'api.bgpview.io')
		url4 = 'https://api.bgpview.io/asn/' + asn + '/prefixes';

	let raw4 = api.download(url4);
	if (raw4) {
		let prefixes4 = _extract_prefixes(raw4, 4);
		for (let prefix in prefixes4)
			api.nft4('add element ' + api.table + ' ' + set4 + ' { ' + prefix + ' }');
	}

	// IPv6
	let url6;
	if (db_source == 'ipinfo.io')
		url6 = 'https://ipinfo.io/AS' + asn;
	else if (db_source == 'api.bgpview.io')
		url6 = 'https://api.bgpview.io/asn/' + asn + '/prefixes';

	if (url6) {
		let raw6 = (url6 == url4 && raw4) ? raw4 : api.download(url6);
		if (raw6) {
			let prefixes6 = _extract_prefixes(raw6, 6);
			for (let prefix in prefixes6)
				api.nft6('add element ' + api.table + ' ' + set6 + ' { ' + prefix + ' }');
		}
	}
};
