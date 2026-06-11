#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=nfdump
PKG_VERSION:=1.7.8
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/phaag/nfdump
PKG_MIRROR_HASH:=ea94dcd3f64c778d641fae814d1cb3d3cce58b00a20c58d9405a4a5447e138f8

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:nfdump_project:nfdump

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=lto

include $(INCLUDE_DIR)/package.mk

define Package/nfdump
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:= +flex +libbsd +libbz2 +USE_MUSL:musl-fts +libatomic +libzstd +liblz4
  TITLE:= nfdump
  URL:=https://github.com/phaag/nfdump/
endef

define Package/nfdump/description
  NetFlow collecting and processing tools
endef

define Package/nfdump/conffiles
/etc/config/nfcapd
endef

TARGET_LDFLAGS += -Wl,--as-needed $(if $(CONFIG_USE_MUSL),-lfts)

define Package/nfdump/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libnfdump-$(PKG_VERSION).so $(1)/usr/lib/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libnffile-$(PKG_VERSION).so $(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/nfcapd.config $(1)/etc/config/nfcapd

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/nfcapd.init $(1)/etc/init.d/nfcapd
endef

$(eval $(call BuildPackage,nfdump))
