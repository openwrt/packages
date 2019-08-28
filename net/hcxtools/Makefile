#
# Copyright (C) 2019 Andreas Nilsen <adde88@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=hcxtools
PKG_VERSION:=5.2.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/zerbea/hcxtools/tar.gz/$(PKG_VERSION)?
PKG_HASH:=1e8120c5451a38645ade0be4255d3c7f4a837b7611b44d4a5a066e563ad8a112

PKG_MAINTAINER:=Andreas Nilsen <adde88@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=license.txt

include $(INCLUDE_DIR)/package.mk

define Package/hcxtools
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libpthread +libpcap +zlib +libcurl +libopenssl
  TITLE:=hcxtools
  URL:=https://github.com/ZerBea/hcxtools
  SUBMENU:=Wireless
endef

define Package/hcxtools/description
  Set of tools convert packets from captures (h = hash, c = capture, convert and calculate candidates, x = different hashtypes)
  for the use with latest hashcat or John the Ripper.
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/ \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)"
endef

define Package/hcxtools/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wlanwkp2hcx	$(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wlanpmk2hcx	$(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wlanhcxmnc	$(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wlanhcx2essid	$(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wlanjohn2hcx	$(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/hcxpcaptool	$(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wlanhcx2john	$(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/hcxpsktool	$(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wlancow2hcxpmk	$(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wlanhcxinfo	$(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/hcxhash2cap	$(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/hcxhashcattool	$(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wlanhashhcx	$(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wlancap2wpasec	$(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wlanhc2hcx	$(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/hcxwltool	$(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/whoismac	$(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wlancap2wpasec	$(1)/usr/sbin/
endef

$(eval $(call BuildPackage,hcxtools))
