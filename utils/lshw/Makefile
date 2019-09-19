include $(TOPDIR)/rules.mk

PKG_NAME:=lshw
PKG_VERSION:=B.02.18
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.ezix.org/software/files/
PKG_HASH:=ae22ef11c934364be4fd2a0a1a7aadf4495a0251ec6979da280d342a89ca3c2f

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/lshw
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=HardWare LiSter
  URL:=https://ezix.org/project/wiki/HardwareLiSter
  DEPENDS:=+libstdcpp
endef

define Package/lshw/description
  lshw is a small tool to provide detailed information on the hardware configuration of the machine.
  It can report exact memory configuration, firmware version, mainboard configuration, CPU version and speed,
  cache configuration, bus speed, etc.
endef

define Package/lshw/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_BUILD_DIR)/src/lshw $(1)/usr/bin/
endef

$(eval $(call BuildPackage,lshw))
