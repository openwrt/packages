# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=font-util
PKG_VERSION:=1.3.1
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://www.x.org/releases/individual/font/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_HASH:=aa7ebdb0715106dd255082f2310dbaa2cd7e225957c2a77d719720c7cc92b921

PKG_BUILD_DEPENDS:=util-macros
PKG_BUILD_PARALLEL:=1
HOST_BUILD_DEPENDS:=util-macros/host
HOST_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/font-util
  SECTION:=xorg
  CATEGORY:=Xorg
  TITLE:=X.org font utilities
  URL:=http://xorg.freedesktop.org/
endef

TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

CONFIGURE_ARGS += \
  --prefix=/usr

define Build/InstallDev
	$(INSTALL_DIR) \
	  $(1)/usr/lib \
	  $(1)/usr/share

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/share/{aclocal,fonts} \
	  $(1)/usr/share/

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/pkgconfig \
	  $(1)/usr/lib/

	$(SED) \
		's,/usr,$$$${prefix},g; \
		 s,/usr/share,$$$${exec_prefix}/share,g' \
		 $(1)/usr/lib/pkgconfig/fontutil.pc

endef

define Package/font-util/install
	$(INSTALL_DIR) \
	  $(1)/usr/bin

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/bin/* \
	  $(1)/usr/bin/
endef

$(eval $(call BuildPackage,font-util))
$(eval $(call HostBuild))
