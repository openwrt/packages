#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=grilo
PKG_VERSION:=0.3.6
PKG_RELEASE:=4

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>

PKG_LICENSE:=LGPLv2.1
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@GNOME/grilo/0.3/
PKG_HASH:=1e65ca82dd58020451417fde79310d4b940adc3f63ab59997419c52ed3bc9c91

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PKG_BUILD_DEPENDS:=vala/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/grilo
  SECTION:=multimedia
  CATEGORY:=Multimedia
  TITLE:=grilo
  URL:=https://wiki.gnome.org/Projects/Grilo
  DEPENDS:=+glib2 +libsoup +libxml2
endef

define Package/grilo/decription
  Grilo is a framework that provides access to different sources of
  multimedia content, using a pluggable system.
endef

CONFIGURE_ARGS += \
	--disable-compile-warnings \
	--disable-debug \
	--disable-gtk-doc-html \
	--disable-introspection \
	--disable-test-ui \
	--disable-vala

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/grilo-0.3/ \
		$(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/*.so* \
		$(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig/
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/*.pc \
		$(1)/usr/lib/pkgconfig/
	$(INSTALL_DIR) $(STAGING_DIR_HOSTPKG)/share/vala-`$(STAGING_DIR_HOSTPKG)/bin/valac --api-version`/vapi/
	# Note: this are compiled elsewhere because grilo refuses to
	# generate VAPI files unless gobject-introspection exists;
	# OpenWrt does not yet have a gobject-introspection package.
	$(INSTALL_DATA) \
		./files/*.vapi \
		$(STAGING_DIR_HOSTPKG)/share/vala-`$(STAGING_DIR_HOSTPKG)/bin/valac --api-version`/vapi
endef

define Package/grilo/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/*.so* \
		$(1)/usr/lib/
endef

$(eval $(call BuildPackage,grilo))
