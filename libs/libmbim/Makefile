#
# Copyright (C) 2016 Velocloud Inc.
# Copyright (C) 2016 Aleksander Morgado <aleksander@aleksander.es>
#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libmbim
PKG_SOURCE_VERSION:=1.30.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://gitlab.freedesktop.org/mobile-broadband/libmbim.git
PKG_MIRROR_HASH:=8fc4e2d78d6a1003bf89303d3ce779283b176d74e84a241ba8efb0d468605268

PKG_BUILD_FLAGS:=gc-sections

PKG_MAINTAINER:=Nicholas Smith <nicholas@nbembedded.com>

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/meson.mk

TARGET_CFLAGS += -fno-merge-all-constants -fmerge-constants

MESON_ARGS += \
	-Dintrospection=false \
	-Dman=false \
	-Dbash_completion=false \
	-Db_lto=true

define Package/libmbim
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+glib2
  TITLE:=Helper library and utils to talk to MBIM enabled modems
  URL:=https://www.freedesktop.org/wiki/Software/libmbim
  LICENSE:=LGPL-2.0-or-later
  LICENSE_FILES:=COPYING.LIB
endef

define Package/libmbim/description
  Helper library to talk to MBIM enabled modems.
  Add mbim-utils for extra utilities.
endef

define Package/mbim-utils
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libmbim
  TITLE:=Utilities to talk to MBIM enabled modems
  URL:=https://www.freedesktop.org/wiki/Software/libmbim
  LICENSE:=GPL-2.0-or-later
  LICENSE_FILES:=COPYING
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/libmbim-glib \
		$(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libmbim*.so* \
		$(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/mbim-glib.pc \
		$(1)/usr/lib/pkgconfig
endef

define Package/libmbim/install
	$(INSTALL_DIR) \
		$(1)/usr/lib \
		$(1)/usr/libexec

	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libmbim*.so.* \
		$(1)/usr/lib/

	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/libexec/mbim-proxy $(1)/usr/libexec/
endef

define Package/mbim-utils/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/mbimcli $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/mbim-network $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libmbim))
$(eval $(call BuildPackage,mbim-utils))
