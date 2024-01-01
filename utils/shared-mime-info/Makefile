#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=shared-mime-info
PKG_VERSION:=2.4
PKG_RELEASE:=2

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>

PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE:=shared-mime-info-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://gitlab.freedesktop.org/xdg/$(PKG_NAME)/-/archive/$(PKG_VERSION)
PKG_HASH:=32dc32ae39ff1c1bf8434dd3b36770b48538a1772bc0298509d034f057005992

PKG_BUILD_DEPENDS:=gettext-full/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/meson.mk

define Package/shared-mime-info
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+glib2 +libxml2 +libstdcpp
  TITLE:=MIME-type information
  URL:=https://freedesktop.org/wiki/Software/shared-mime-info/
endef

define Package/shared-mime-info/description
	The shared-mime-info package contains a database of MIME types and their file extensions.
endef

define Package/shared-mime-info/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/bin/* \
		$(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/share/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/share/* \
		$(1)/usr/share/
endef

define Package/shared-mime-info/postinst
#!/bin/sh

update-mime-database /usr/share/mime/
endef

$(eval $(call BuildPackage,shared-mime-info))
