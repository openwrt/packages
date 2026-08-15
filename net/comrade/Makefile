#
# Copyright (C) 2026 Daniel Golle <daniel@makrotopia.org>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=comrade
PKG_VERSION:=0.1.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/dangowrt/comrade/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=b778bbc4aa61e6e77632f4931557a2831eb80ef981f099d175d48b40324d4619

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=AGPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_FLAGS:=gc-sections lto

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

# The GitHub source archive used above carries no submodule content, so
# deps/always-online-stun arrives as an empty directory; without the file
# below CMake falls back to three hard-coded servers. This is the same list
# that submodule would provide, pinned to the commit the v$(PKG_VERSION) tag
# references. Either way "comrade stun-update" refreshes the pool at
# runtime into the user's data directory.
STUN_LIST_VERSION:=0932114f96cd80886f559994545692870df73804
STUN_LIST_FILE:=always-online-stun-$(STUN_LIST_VERSION)-valid_nat_testing_hosts.txt

define Download/stunlist
  FILE:=$(STUN_LIST_FILE)
  URL:=https://raw.githubusercontent.com/pradt2/always-online-stun/$(STUN_LIST_VERSION)
  URL_FILE:=valid_nat_testing_hosts.txt
  HASH:=0aee95ad2cb98a2def9886045d241a62cca64541f77697a010bf0477e02a7322
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

# With no -DCOMRADE_DHT_DIR the build finds and links the shared libdht,
# which is what we want: comrade is an ordinary consumer of the packaged
# library, exactly as transmission is. comrade defines the four symbols
# libdht deliberately leaves undefined (dht_hash, dht_random_bytes,
# dht_blacklisted, dht_sendto) and the dynamic linker resolves them back
# into the executable.
CMAKE_OPTIONS += \
	-DBUILD_TESTING=OFF

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

$(eval $(call BuildPackage,comrade))
