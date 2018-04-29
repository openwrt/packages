#
# Copyright (C) 2010-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=usbip
PKG_RELEASE:=6
PKG_LICENSE:=GPL-2.0

# Since kernel 2.6.39.1 userspace tools are inside the kernel tree
# Package Automatic match version in kernel
# MD5SUM is not useful kernel package already check it
PKG_VERSION:=$(shell  sed -n -e '/^AC_INIT/s/.*\[\([[:digit:]\.]*\)\].*/\1/gp' $(LINUX_DIR)/tools/usb/usbip/configure.ac)
PKG_SOURCE:=
PKG_SOURCE_URL:=
PKG_MD5SUM:=unknown

PKG_MAINTAINER:=Nuno Goncalves <nunojpg@gmail.com>

PATCH_DIR:=./patches-$(PKG_VERSION)

define prepare_source_directory
	rm -rf $(PKG_BUILD_DIR)
	$(CP) $(LINUX_DIR)/tools/usb/usbip $(PKG_BUILD_DIR)
endef
Hooks/Prepare/Pre += prepare_source_directory

PKG_BUILD_DEPENDS:=eudev
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_FLAGS:=nonshared

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/usbip/Common
  TITLE:=USB-over-IP
  URL:=http://usbip.sourceforge.net/
  DEPENDS:=@USB_SUPPORT
endef

define Package/usbip/Default
  $(call Package/usbip/Common)
  SECTION:=net
  CATEGORY:=Network
endef

define Package/usbip
  $(call Package/usbip/Default)
  TITLE+= (common)
  DEPENDS+= +libwrap +kmod-usbip +eudev
endef

define Package/usbip-client
  $(call Package/usbip/Default)
  TITLE+= (client)
  DEPENDS+= usbip +kmod-usbip-client
endef

define Package/usbip-server
  $(call Package/usbip/Default)
  TITLE+= (server)
  DEPENDS+= usbip +kmod-usbip-server
endef

CONFIGURE_PATH:=.
MAKE_PATH:=.
LIBTOOL_PATHS:=.
MAKE_FLAGS+=CFLAGS="-Wno-implicit-function-declaration"

define Build/Configure
	(cd $(PKG_BUILD_DIR); ./autogen.sh );
	$(call Build/Configure/Default)
endef

CFLAGS+="$(TARGET_CFLAGS) -I$(STAGING_DIR)/usr/include"

define Download/usb.ids
  URL:=http://www.linux-usb.org/
  FILE:=usb.ids
  MD5SUM:=
endef

define Package/usbip/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libusbip.so.* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/share/hwdata
	$(CP) $(DL_DIR)/usb.ids $(1)/usr/share/hwdata/
endef

define Package/usbip-client/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/usbip $(1)/usr/sbin/
endef

define Package/usbip-server/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/usbipd $(1)/usr/sbin/
endef

$(eval $(call Download,usb.ids))
$(eval $(call BuildPackage,usbip))
$(eval $(call BuildPackage,usbip-client))
$(eval $(call BuildPackage,usbip-server))
