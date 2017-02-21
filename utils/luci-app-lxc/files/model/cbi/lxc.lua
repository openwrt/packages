--[[

LuCI LXC module

Copyright (C) 2014, Cisco Systems, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

Author: Petar Koretic <petar.koretic@sartura.hr>

]]--

local fs = require "nixio.fs"

m = Map("lxc", translate("LXC Containers"))

if fs.access("/etc/config/lxc") then
	m:section(SimpleSection).template = "lxc/list"

	s = m:section(TypedSection, "lxc", translate("Options"))
	s.anonymous = true
	s.addremove = false

	s:option(Value, "url", translate("Containers Server"))

	if fs.access("/usr/bin/gpgv") or fs.access("/usr/bin/gpg") then
		local validate = s:option(Flag, "check_signature", translate("Verify image signatures"))
		s.default = false

		keyring_file = s:option(FileUpload, "keyring", translate("Keyring"),
			translate("GnuPG keyring for verifying signatures"))

		o = s:option(Button, "remove_conf", translate("Remove configuration for keyring"),
			translate("This permanently deletes the keyring and configuration to use same."))
		o.inputstyle = "remove"

		function o.write(self, section)
			if keyring_file:cfgvalue(section) and fs.access(keyring_file:cfgvalue(section)) then
				 fs.unlink(keyring_file:cfgvalue(section))
			end
			self.map:del(section, "keyring")
			luci.http.redirect(luci.dispatcher.build_url("admin", "services", "lxc"))
		end

		if not fs.access("/usr/bin/gpg") then
			validate:depends("keyring")
		end
	end

	m:section(SimpleSection).template = "lxc/create"

end

return m
