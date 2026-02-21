#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=hwdata
PKG_VERSION:=0.387
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/vcrhonek/hwdata/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=8c6be8f0863a8ff5c83b2c46aa525b503b30d42792ed57891c40849de543e1ee

PKG_MAINTAINER:=
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING LICENSE

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/pciids
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=PCI ID list
  URL:=https://github.com/vcrhonek/hwdata
endef

define Package/usbids
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=USB ID list
  URL:=https://github.com/vcrhonek/hwdata
endef

define Package/pnpids
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=PnP ID list
  URL:=https://github.com/vcrhonek/hwdata
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/share/hwdata
	$(CP) $(PKG_INSTALL_DIR)/usr/share/hwdata/* $(1)/usr/share/hwdata
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/*/pkgconfig/hwdata.pc $(1)/usr/lib/pkgconfig
endef

define Package/pciids/install
	$(INSTALL_DIR) $(1)/usr/share/hwdata
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/hwdata/pci.ids $(1)/usr/share/hwdata
endef

define Package/pnpids/install
	$(INSTALL_DIR) $(1)/usr/share/hwdata
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/hwdata/pnp.ids $(1)/usr/share/hwdata
endef

define Package/usbids/install
	$(INSTALL_DIR) $(1)/usr/share/hwdata
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/hwdata/usb.ids $(1)/usr/share/hwdata
endef

$(eval $(call BuildPackage,pciids))
$(eval $(call BuildPackage,pnpids))
$(eval $(call BuildPackage,usbids))
