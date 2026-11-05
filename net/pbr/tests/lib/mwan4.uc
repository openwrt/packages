// Mock mwan4 ucode module for pbr tests.
//
// platform.uc requires this when is_mwan4_installed() returns true.
// Tests gate that via fs mocks (access on /etc/init.d/mwan4 + stat
// on /etc/config/mwan4); without those, this mock is loaded into the
// require search path but never invoked.

return {
	load: function() {},
	get_interfaces: function() { return []; },
	get_iface_mark: function(iface) { return null; },
	get_iface_chain: function(iface) { return null; },
	get_strategies: function() { return ['balanced', 'failover']; },
	get_strategy_chain: function(strategy) {
		return 'mwan4_strategy_' + strategy;
	},
};
