#
# Copyright (C) 2026 Daniel Golle <daniel@makrotopia.org>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=comrade
PKG_VERSION:=0.1.16
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/dangowrt/comrade/releases/download/v$(PKG_VERSION)
PKG_HASH:=1054b4b3df410401caa0b35d64b35c0f95c5dce91f617f25fbccb03bdd60553a

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=AGPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_FLAGS:=gc-sections lto

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

# The release tarball above is minted with `git archive` in upstream's own
# release CI, not GitHub's codeload archive-on-demand, but that carries no
# submodule content either; deps/always-online-stun arrives as an empty
# directory, and the file below is the same hourly-validated list that
# submodule provides, pinned to the exact commit v$(PKG_VERSION)'s own
# deps/always-online-stun points at. comrade tries every server in the
# pool in rotation, but a pool with many dead entries still degrades
# public-IPv4 discovery.
STUN_LIST_VERSION:=4dc3b52cffa8ca9532a56274d8ac789f5e2be175
STUN_LIST_FILE:=always-online-stun-$(STUN_LIST_VERSION)-valid_nat_testing_hosts.txt

define Download/stunlist
  FILE:=$(STUN_LIST_FILE)
  URL:=https://raw.githubusercontent.com/pradt2/always-online-stun/$(STUN_LIST_VERSION)
  URL_FILE:=valid_nat_testing_hosts.txt
  HASH:=40fd158296353730a6e79ac6219ea2efb8c166c7188e9cfbbaf3997e814ef376
endef
$(eval $(call Download,stunlist))

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

  The deterministic unit tests are wired into this package's own CI
  test.sh, which runs run-unit-tests.sh automatically -- except for a
  couple that need real network/timing conditions QEMU can't promise;
  run-unit-tests.sh skips those by default, run COMRADE_SKIP=
  run-unit-tests.sh to include them too, e.g. on real hardware. The
  end-to-end scenarios (comrade-e2e plus its *.sh drivers) need real
  network or multicast conditions, and some a live DHT
  (COMRADE_E2E_NET=1), that CI's QEMU emulation cannot promise, so they
  are shipped for manual use on real hardware instead, not run
  automatically.
  Usage: /usr/share/comrade/tests/run-unit-tests.sh
         /usr/share/comrade/tests/<scenario>.sh /usr/share/comrade/tests/comrade-e2e
endef

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

define Package/comrade-tests/install
	$(INSTALL_DIR) $(1)/usr/share/comrade/tests
	for t in $(PKG_BUILD_DIR)/*_test; do \
		$(INSTALL_BIN) "$$$${t}" $(1)/usr/share/comrade/tests/ || exit 1; \
	done
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/comrade-e2e $(1)/usr/share/comrade/tests/
	for s in $(PKG_BUILD_DIR)/tests/*.sh; do \
		$(INSTALL_BIN) "$$$${s}" $(1)/usr/share/comrade/tests/ || exit 1; \
	done
	$(INSTALL_BIN) ./files/run-unit-tests.sh $(1)/usr/share/comrade/tests/
endef

$(eval $(call BuildPackage,comrade))
$(eval $(call BuildPackage,comrade-tests))
