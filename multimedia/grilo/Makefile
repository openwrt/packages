#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=grilo
PKG_VERSION:=0.3.14
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@GNOME/grilo/0.3/
PKG_HASH:=0369d0b00bb0f59ba5f7aea8cfc665f38df14a5b4182d28c7c1e2cd15b518743

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_DEPENDS:=vala/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/meson.mk

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

MESON_ARGS += \
	-Denable-grl-net=true \
	-Denable-grl-pls=false \
	-Denable-gtk-doc=false \
	-Denable-introspection=false \
	-Denable-test-ui=false \
	-Denable-vala=false

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
