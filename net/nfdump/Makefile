#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=nfdump
PKG_VERSION:=1.6.22
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/phaag/nfdump/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=437536acb02258f8e2cd1e63c801428c65e1c33100e349acbf718c5b04734bd0

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/nfdump
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:= +libbz2 +USE_MUSL:musl-fts
  TITLE:= nfdump
  URL:=https://github.com/phaag/nfdump/
endef

define Package/nfdump/description
  NetFlow collecting and processing tools
endef

define Package/nfdump/conffiles
/etc/config/nfcapd
endef

TARGET_CFLAGS += -flto
TARGET_LDFLAGS += -Wl,--as-needed $(if $(CONFIG_USE_MUSL),-lfts)

define Package/nfdump/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libnfdump-$(PKG_VERSION).so $(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/nfcapd.config $(1)/etc/config/nfcapd

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/nfcapd.init $(1)/etc/init.d/nfcapd
endef

$(eval $(call BuildPackage,nfdump))
