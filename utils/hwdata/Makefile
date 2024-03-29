#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=hwdata
PKG_VERSION:=0.380
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/vcrhonek/hwdata/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=e5ca061d9e0b9b177bed8d16f94b4cd54ce9eebd1ec115f7cf2174d3a6052049

PKG_MAINTAINER:=
PKG_LICENSE:=GPL-2.0-or-later  XFree86-1.0
PKG_LICENSE_FILES:=LICENSE

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

define Package/pciids/install
	$(INSTALL_DIR) $(1)/usr/share/hwdata
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/pci.ids $(1)/usr/share/hwdata
endef

define Package/usbids/install
	$(INSTALL_DIR) $(1)/usr/share/hwdata
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/usb.ids $(1)/usr/share/hwdata
endef

$(eval $(call BuildPackage,pciids))
$(eval $(call BuildPackage,usbids))
