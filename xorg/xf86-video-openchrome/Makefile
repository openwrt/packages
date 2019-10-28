# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=xf86-video-openchrome
PKG_VERSION:=0.6.0
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://www.x.org/releases/individual/driver/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_HASH:=da2975c6379358de52c1257710c67eb59139a7f0a1cd28d00cc64cc3e1c02f75

PKG_BUILD_DEPENDS:=util-macros
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/xf86-video-openchrome
  SECTION:=xorg
  CATEGORY:=Xorg
  DEPENDS:=+libxi +xorg-server +mesa +libxvmc
  TITLE:=X.Org driver for VIA/S3G cards
  URL:=https://www.x.org
endef

LDFLAGS:="$LDFLAGS -Wl,-z,lazy"

CONFIGURE_ARGS += \
  --prefix=/usr

#define Build/InstallDev
#	$(INSTALL_DIR) \
#	  $(1)/usr/include \
#	  $(1)/usr/lib
#
#	$(CP) \
#	  $(PKG_INSTALL_DIR)/usr/include/* \
#	  $(1)/usr/include/
#
#	$(CP) \
#	  $(PKG_INSTALL_DIR)/usr/lib/{pkgconfig,*.so*} \
#	  $(1)/usr/lib/
#endef

define Package/xf86-video-openchrome/install
	$(INSTALL_DIR) \
	  $(1)/usr/lib/xorg/modules/drivers \
	  $(1)/usr/share/hwdata/videoaliases/

	$(INSTALL_DATA) ./files/openchrome.xinf $(1)/usr/share/hwdata/videoaliases/

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/xorg/modules/drivers/*.so* \
	  $(1)/usr/lib/xorg/modules/drivers
endef

$(eval $(call BuildPackage,xf86-video-openchrome))
