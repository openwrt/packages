#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libirecovery
PKG_SOURCE_DATE:=2019-12-16
PKG_SOURCE_VERSION:=db36196d8d9db5a1f92e6934cf931cd00a6ead2d
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/libimobiledevice/libirecovery
PKG_MIRROR_HASH:=635f790b97b7e0001050df6a604c2bcd5cc896213f2a2441f58cf0aa4e00f773

PKG_MAINTAINER:=Rosen Penev <rosenp@gmail.com>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libirecovery/Default
  URL:=https://github.com/libimobiledevice/libirecovery
  SUBMENU:=libimobiledevice
endef

define Package/libirecovery/Default/description
  libirecovery is a cross-platform library which implements communication
  to iBoot/iBSS found on Apple's iOS devices via USB.
endef

define Package/libirecovery
  $(call Package/libirecovery/Default)
  TITLE:=A library that talks to Apple iBoot/iBSS
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libreadline +libusb-1.0
endef

define Package/libirecovery/description
  $(call Package/libirecovery/Default/description)
endef

define Package/irecovery
  $(call Package/libirecovery/Default)
  TITLE:=A utility that talks to Apple iBoot/iBSS
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libirecovery
endef

define Package/irecovery/description
  $(call Package/libirecovery/Default/description)
  This package contains the libirecovery utilities.
endef

CONFIGURE_ARGS += --without-udev

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libirecovery.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libirecovery.{a,la,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libirecovery.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libirecovery/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libirecovery.so.* $(1)/usr/lib/
endef

define Package/irecovery/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/irecovery $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libirecovery))
$(eval $(call BuildPackage,irecovery))
