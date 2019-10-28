# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=shared-mime-info
PKG_VERSION:=1.10
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://freedesktop.org/~hadess/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_HASH:=c625a83b4838befc8cafcd54e3619946515d9e44d63d61c4adf7f5513ddfbebf

#HOST_BUILD_DEPENDS:=
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/shared-mime-info
  SECTION:=xorg
  CATEGORY:=Xorg
  DEPENDS:=+glib2 +libxml2
  TITLE:=Freedesktop.org Shared MIME Info
  URL:=http://freedesktop.org/Software/shared-mime-info
endef

#if not, it will fail with 
# update_mime_database-update-mime-database.o: file not recognized: File truncated
MAKE_FLAGS+=-j1

TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

CONFIGURE_VARS += \
  ac_cv_func_fdatasync=no

CONFIGURE_ARGS += \
  --prefix=/usr \
  --enable-default-make-check \
  --disable-update-mimedb

define Build/InstallDev
	$(INSTALL_DIR) \
	  $(1)/usr/lib \
	  $(1)/usr/share

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/share/mime \
	  $(1)/usr/share/

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/share/pkgconfig \
	  $(1)/usr/lib/
endef

define Package/shared-mime-info/install
	$(INSTALL_DIR) \
	  $(1)/usr/sbin \
	  $(1)/usr/share

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/bin/* \
	  $(1)/usr/sbin/

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/share/mime \
	  $(1)/usr/share/
endef

$(eval $(call BuildPackage,shared-mime-info))
