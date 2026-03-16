#
# Copyright (C) 2014-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=rtklib
PKG_VERSION:=2.4.3.34
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/tomojitakasu/RTKLIB
PKG_SOURCE_VERSION:=180043ee24b6d2b168f98b64be15f69d50046b1a
PKG_MIRROR_HASH:=54f0d9a50f2b8b9caf9e3d391f1ad211ca8fcb54743bd8f43fc7301396143a11

PKG_MAINTAINER:=Nuno Goncalves <nunojpg@gmail.com>
PKG_LICENSE:=BSD-2-Clause

PKG_BUILD_PARALLEL:=0

include $(INCLUDE_DIR)/package.mk

define Package/rtklib/default
  SUBMENU:=RTKLIB Suite for GNSS Positioning
  SECTION:=utils
  CATEGORY:=Utilities
  URL:=http://www.rtklib.com/
  DEPENDS:=+libpthread +librt
endef

define Package/convbin
$(call Package/rtklib/default)
  TITLE:=RINEX Converter
endef

define Package/pos2kml
$(call Package/rtklib/default)
  TITLE:=Solution to KML converter
endef

define Package/rnx2rtkp
$(call Package/rtklib/default)
  TITLE:=Post-Processing Analysis
endef

define Package/rtkrcv
$(call Package/rtklib/default)
  TITLE:=Real-Time Positioning
endef

define Package/str2str
$(call Package/rtklib/default)
  TITLE:=Communication Server
endef

define Build/Compile
	rm -rf $(PKG_INSTALL_DIR)
	mkdir -p $(PKG_INSTALL_DIR)
	$(MAKE) -C $(PKG_BUILD_DIR)/app/consapp/convbin/gcc CC="$(TARGET_CC) $(TARGET_CFLAGS)"
	$(MAKE) -C $(PKG_BUILD_DIR)/app/consapp/pos2kml/gcc CC="$(TARGET_CC) $(TARGET_CFLAGS)"
	$(MAKE) -C $(PKG_BUILD_DIR)/app/consapp/rnx2rtkp/gcc CC="$(TARGET_CC) $(TARGET_CFLAGS)"
	$(MAKE) -C $(PKG_BUILD_DIR)/app/consapp/rtkrcv/gcc CC="$(TARGET_CC) $(TARGET_CFLAGS)"
	$(MAKE) -C $(PKG_BUILD_DIR)/app/consapp/str2str/gcc CC="$(TARGET_CC) $(TARGET_CFLAGS)"
endef

define Package/convbin/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/app/consapp/convbin/gcc/convbin $(1)/usr/bin/
endef

define Package/pos2kml/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/app/consapp/pos2kml/gcc/pos2kml $(1)/usr/bin/
endef

define Package/rnx2rtkp/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/app/consapp/rnx2rtkp/gcc/rnx2rtkp $(1)/usr/bin/
endef

define Package/rtkrcv/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/app/consapp/rtkrcv/gcc/rtkrcv $(1)/usr/bin/
endef

define Package/str2str/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/app/consapp/str2str/gcc/str2str $(1)/usr/bin/
endef

$(eval $(call BuildPackage,convbin))
$(eval $(call BuildPackage,pos2kml))
$(eval $(call BuildPackage,rnx2rtkp))
$(eval $(call BuildPackage,rtkrcv))
$(eval $(call BuildPackage,str2str))
