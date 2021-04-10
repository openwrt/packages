include $(TOPDIR)/rules.mk

PKG_NAME:=modbus-utils

PKG_VERSION:=2013-07-31
PKG_RELEASE=$(PKG_SOURCE_VERSION)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/Krzysztow/modbus-utils.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=c569dc0a11a1bedf3a8080fe4a1696de93e386ab
# PKG_MIRROR_HASH:=3aed4146e06bd9f9bcc271824c6b1d75d1fc2a0bd980f2b729c3b4755c6f70a8
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2

PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

# supposed based on statement that source is based on libmodbus testcases
PKG_LICENSE:=GPL-3.0+ LGPL-2.1+

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/modbus-utils
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Modbus client/server utils
  DEPENDS:=+libmodbus
endef

define Package/modbus-utils/description
endef

define Package/modbus-utils/install
	$(INSTALL_DIR) $(1)/usr/bin
#	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/mbrecorder $(1)/usr/bin/
endef

$(eval $(call BuildPackage,modbus-utils))
