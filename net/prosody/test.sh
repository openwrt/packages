#!/bin/sh
#
# Functional smoke tests for the prosody package.
#
# Everything below drives the prosody Lua stack in-process. The XMPP daemon
# itself is never started: it would block forever under QEMU emulation, and
# prosodyctl already exercises the same interpreter, util library closure,
# plugin loader and config parser.

set -e

PROSODY_LIB="/usr/lib/prosody"
PROSODY_DATA="/etc/prosody/data"
TEST_USER="citest"
TEST_PASS="s3cr3t-ci-passphrase"

case "$1" in
prosody)
	# Verify the installed version file matches the apk version arg the
	# runner passes, so a stale .apk from an earlier batch fails fast.
	grep -qF "$2" "$PROSODY_LIB/prosody.version"

	# loader.lua installs the "prosody.*" -> "*" module searcher that every
	# require() in 13.x goes through. It is the first thing prosodyctl looks
	# for, and the package is dead on arrival if it was not installed.
	test -f "$PROSODY_LIB/loader.lua"

	# `prosodyctl about` prints the version, dependency and module lists,
	# exercising the Lua bootstrap end-to-end. Assert it picked up Lua 5.4:
	# the wrapper falls back to /usr/bin/lua (5.1) if --runwith is lost, and
	# prosody 13 refuses to run on anything older than 5.2.
	prosodyctl about > /tmp/prosody-about.txt
	grep -q "Lua 5.4" /tmp/prosody-about.txt

	# `prosodyctl check config` parses /etc/prosody/prosody.cfg.lua against
	# the full config schema; upstream documents this as the way to validate
	# a deployment before starting it.
	prosodyctl check config

	# Register and remove a local account on the sample VirtualHost. This is
	# the only path that drives util.datamanager storage together with the
	# internal_hashed SCRAM derivation, and it must never leave the cleartext
	# password on disk.
	prosodyctl register "$TEST_USER" localhost "$TEST_PASS"
	test -f "$PROSODY_DATA/localhost/accounts/$TEST_USER.dat"
	if grep -qF "$TEST_PASS" "$PROSODY_DATA/localhost/accounts/$TEST_USER.dat"; then
		echo "test.sh: cleartext password stored, internal_hashed is not hashing" >&2
		exit 1
	fi
	prosodyctl unregister "$TEST_USER" localhost
	test ! -f "$PROSODY_DATA/localhost/accounts/$TEST_USER.dat"

	# Exercise the compiled util/*.so extensions and the external Lua rocks
	# the package depends on. These are the arch-specific artifacts, so a
	# bad cross-build or a missing library shows up here and nowhere else.
	lua5.4 - "$PROSODY_LIB" <<-'EOF'
	local lib = ...

	package.path = lib .. "/?.lua;" .. package.path
	package.cpath = lib .. "/?.so;" .. package.cpath
	dofile(lib .. "/loader.lua")

	-- Every C extension must load. They are listed explicitly rather than
	-- globbed so that a silently dropped .so fails instead of shrinking
	-- the test.
	for _, m in ipairs({
		"compat", "crypto", "encodings", "hashes", "net", "poll",
		"pposix", "ringbuffer", "signal", "strbitop", "struct",
		"table", "time",
	}) do
		local so = lib .. "/util/" .. m .. ".so"
		assert(io.open(so, "r"), "missing " .. so):close()
		assert(package.loadlib(so, "luaopen_prosody_util_" .. m),
			"cannot load " .. so)()
	end

	-- util.hashes is linked against libopenssl; check a published SHA-256
	-- vector and an HMAC rather than just that the module loads.
	local hashes = require "prosody.util.hashes"
	assert(hashes.sha256("abc", true) ==
		"ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")
	assert(#hashes.hmac_sha256("key", "message") == 32)
	assert(#hashes.pbkdf2_hmac_sha256("password", "salt", 100) == 32)

	-- util.crypto is the other libopenssl consumer; a generated Ed25519 key
	-- must round-trip through sign/verify and reject a tampered message.
	local crypto = require "prosody.util.crypto"
	local key = crypto.generate_ed25519_keypair()
	local sig = crypto.ed25519_sign(key, "hello")
	assert(crypto.ed25519_verify(key, "hello", sig))
	assert(not crypto.ed25519_verify(key, "hell0", sig))

	-- util.encodings is linked against libidn; IDNA and the stringprep
	-- profiles are what JID handling is built on.
	local encodings = require "prosody.util.encodings"
	assert(encodings.idna.to_ascii("bücher.example") == "xn--bcher-kva.example")
	assert(encodings.stringprep.nodeprep("UsEr") == "user")
	assert(encodings.stringprep.nameprep("Example.COM") == "example.com")
	assert(encodings.base64.decode(encodings.base64.encode("prosody")) == "prosody")

	-- util.jid layers on both of the above; a mixed-case JID must normalise
	-- and split into its three parts.
	local jid = require "prosody.util.jid"
	assert(jid.prep("UsEr@Example.COM/Resource") == "user@example.com/Resource")
	local node, host, resource = jid.split("user@example.com/phone")
	assert(node == "user" and host == "example.com" and resource == "phone")
	assert(jid.bare("user@example.com/phone") == "user@example.com")

	-- util.xml parses via luaexpat, so this covers the luaexpat5.4 runtime
	-- dependency as well as stanza construction and serialisation.
	local xml = require "prosody.util.xml"
	local stanza = xml.parse(
		"<message to='user@example.com'><body>hi</body></message>")
	assert(stanza.attr.to == "user@example.com")
	assert(stanza:get_child_text("body") == "hi")

	local st = require "prosody.util.stanza"
	local iq = st.iq({ type = "get", id = "1" }):tag("ping", {
		xmlns = "urn:xmpp:ping",
	})
	assert(tostring(iq):find("urn:xmpp:ping", 1, true))

	-- The remaining runtime dependencies are plain Lua rocks that prosody
	-- require()s at startup; make sure each one is actually installed.
	assert(require "lfs".attributes(lib, "mode") == "directory")
	assert(require "socket".gettime() > 0)
	local ssl = require "ssl"
	assert(ssl.context or require "ssl.context")

	print("prosody lua stack OK")
	EOF
	;;

*)
	echo "test.sh: unknown subpackage '$1' — refusing to silently pass" >&2
	echo "test.sh: update net/prosody/test.sh to cover this subpackage" >&2
	exit 1
	;;
esac
