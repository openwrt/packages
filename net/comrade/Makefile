#
# Copyright (C) 2026 Daniel Golle <daniel@makrotopia.org>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=comrade
PKG_VERSION:=0.1.7
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/dangowrt/comrade/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=c9f338bad8e0ed62224666e53388847875165c598bd5b4475ff46a1a6582c4bd

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=AGPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_FLAGS:=gc-sections lto

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

# The GitHub source archive used above carries no submodule content, so
# deps/always-online-stun arrives as an empty directory; the file below is
# the same hourly-validated list that submodule provides. Its pin follows
# comrade's submodule and may run ahead of the one the v$(PKG_VERSION) tag
# records: these community servers churn, and v0.1.7 asks only the first
# entry of its pool, so a stale pin whose head entry died takes public-IPv4
# discovery down with it. Either way "comrade stun-update" refreshes the
# pool at runtime into the user's data directory.
STUN_LIST_VERSION:=516ca84588d5b5fa5a4c492045fdb0e42b7a5018
STUN_LIST_FILE:=always-online-stun-$(STUN_LIST_VERSION)-valid_nat_testing_hosts.txt

define Download/stunlist
  FILE:=$(STUN_LIST_FILE)
  URL:=https://raw.githubusercontent.com/pradt2/always-online-stun/$(STUN_LIST_VERSION)
  URL_FILE:=valid_nat_testing_hosts.txt
  HASH:=9f46a716ff06782ba6febf2250bd87f7d3613cadd2457a807000c081435b4ded
endef
$(eval $(call Download,stunlist))

# comrade adds no crypto library of its own: it reads the DT_NEEDED entries
# out of libssh and follows whatever backend that already uses. OpenWrt's
# libssh is built against mbedTLS, which implements neither BLAKE2b nor
# Ed25519, so this resolves to monocypher (~70 kB) rather than dragging in
# libcrypto. Should libssh ever move to OpenSSL, the backend follows it and
# libmonocypher below has to become libopenssl.
define Package/comrade
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=SSH
  TITLE:=Serverless peer-to-peer terminal sharing
  URL:=https://github.com/dangowrt/comrade
  DEPENDS:=+libssh +libjuice +libdht +libkcp +libmonocypher +libpthread
endef

define Package/comrade/description
  Peer-to-peer terminal sharing with tmate-like semantics and no central
  server: a host shares a tmux session, a client joins it with a base58
  token passed out-of-band. Rendezvous happens on the BitTorrent mainline
  DHT (or link-local multicast on isolated LANs), connectivity is
  established by ICE hole punching, and the session itself is end-to-end
  SSH wrapping stock tmux, with the host key pinned in the token. -L and
  -R tunnel TCP ports through that same session with ssh's own syntax.

  Hosting a session needs tmux installed; joining one never does. tmux is
  therefore not pulled in as a dependency, install it separately on
  boxes that will host.
endef

define Package/comrade-tests
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=SSH
  TITLE:=Serverless peer-to-peer terminal sharing (test suite)
  URL:=https://github.com/dangowrt/comrade
  DEPENDS:=+libssh +libjuice +libdht +libkcp +libmonocypher +libpthread
endef

define Package/comrade-tests/description
  comrade's compiled test suite, kept out of the comrade package so it
  never reaches an end-user install.

  The 20 deterministic unit tests are wired into this package's own CI
  test.sh, which runs run-unit-tests.sh automatically. The end-to-end
  scenarios (comrade-e2e plus its *.sh drivers) need real network or
  multicast conditions, and some a live DHT (COMRADE_E2E_NET=1), that
  CI's QEMU emulation cannot promise, so they are shipped for manual use
  on real hardware instead, not run automatically.
  Usage: /usr/share/comrade/tests/run-unit-tests.sh
         /usr/share/comrade/tests/<scenario>.sh /usr/share/comrade/tests/comrade-e2e
endef

# With no -DCOMRADE_DHT_DIR the build finds and links the shared libdht,
# which is what we want: comrade is an ordinary consumer of the packaged
# library, exactly as transmission is. comrade defines the four symbols
# libdht deliberately leaves undefined (dht_hash, dht_random_bytes,
# dht_blacklisted, dht_sendto) and the dynamic linker resolves them back
# into the executable.
#
# BUILD_TESTING=ON so the unit test binaries and the e2e scenarios' driver
# (comrade-e2e, gated separately on COMRADE_BUILD_TOOLS, already on for any
# non-Windows target) all get built; comrade-tests/install below is what
# keeps every one of them out of the end-user comrade package.
CMAKE_OPTIONS += \
	-DBUILD_TESTING=ON

define Build/Prepare
	$(Build/Prepare/Default)
	$(INSTALL_DIR) $(PKG_BUILD_DIR)/deps/always-online-stun
	$(INSTALL_DATA) $(DL_DIR)/$(STUN_LIST_FILE) \
		$(PKG_BUILD_DIR)/deps/always-online-stun/valid_nat_testing_hosts.txt
endef

define Package/comrade/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/comrade $(1)/usr/bin/
endef

# The unit test binaries and comrade-e2e are plain Build/Compile products,
# never install()'d by CMakeLists (only comrade itself is), so they live
# straight in $(PKG_BUILD_DIR) rather than $(PKG_INSTALL_DIR); the *.sh
# scenario drivers are unpacked source, not build output, same directory
# either way since CMAKE_BINARY_DIR defaults to $(PKG_BUILD_DIR).
COMRADE_UNIT_TESTS:= \
	token_test tokgen_test termfilter_test ctlproto_test netmon_test \
	path_test candpolicy_test candpack_test mailbox_test roauth_test \
	bep44_test bep44_pin_test sig_rebuild_test natstream_test \
	sshloop_test sshfwd_test sshexit_test sshro_test sshkcp_test \
	sshctl_test
COMRADE_E2E_SCENARIOS:= \
	isolated_lan lan_concurrent lan_mixed multiuser path_switch roam \
	roam_client turnstile_stuck

define Package/comrade-tests/install
	$(INSTALL_DIR) $(1)/usr/share/comrade/tests
	for t in $(COMRADE_UNIT_TESTS); do \
		$(INSTALL_BIN) $(PKG_BUILD_DIR)/$$$${t} $(1)/usr/share/comrade/tests/; \
	done
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/comrade-e2e $(1)/usr/share/comrade/tests/
	for s in $(COMRADE_E2E_SCENARIOS); do \
		$(INSTALL_BIN) $(PKG_BUILD_DIR)/tests/$$$${s}.sh $(1)/usr/share/comrade/tests/; \
	done
	$(INSTALL_BIN) ./files/run-unit-tests.sh $(1)/usr/share/comrade/tests/
endef

$(eval $(call BuildPackage,comrade))
$(eval $(call BuildPackage,comrade-tests))
