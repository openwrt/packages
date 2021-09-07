include $(TOPDIR)/rules.mk

PKG_NAME:=spidev-lib
PKG_SOURCE_DATE:=2014-10-31
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/milekium/spidev-lib.git
PKG_SOURCE_VERSION:=10fc6f4f900104ddb5fbea1d442842f448c9fd75
PKG_MIRROR_HASH:=3c510227af11807423f158d17640e7779030631de9d2a032c598a2db0dd4de38

PKG_MAINTAINER:=Nick Hainke <vincent@systemli.org>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/spidev-lib
  SECTION:=libs
  CATEGORY:=Libraries
  PROVIDES:=spidev-lib
  TITLE:=Spidev Userspace Library
  URL:=https://github.com/milekium/spidev-lib.git
  BUILDONLY:=1
endef

define Package/spidev-lib/description
  This package provides a C wrapper to linux user space spidev.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/spidev_lib.h $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libspidev-lib.a $(1)/usr/lib/
endef

$(eval $(call BuildPackage,spidev-lib))
