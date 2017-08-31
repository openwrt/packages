#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libcoap
PKG_RELEASE:=4

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/obgm/libcoap
PKG_SOURCE_SUBDIR:=$(PKG_NAME)
PKG_SOURCE_VERSION:=2da31de732c0e51a9bc9e1d4aea21e25da89cf87
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.bz2
PKG_MIRROR_HASH:=b61fe3245a329dfcf198187149d2072509b18ca6e348d0b423c0f44d11e930e4

PKG_MAINTAINER:=Anton Glukhov <anton.a.glukhov@gmail.com>
PKG_LICENSE:=GPL-2.0+ BSD-2-Clause
PKG_LICENSE_FILES:=COPYING LICENSE.GPL LICENSE.BSD

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libcoap
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=CoAP (RFC 7252) library
  URL:=http://libcoap.net/
endef

define Package/libcoap/description
  Constrained Application Protocol (RFC 7252) library
endef

define Package/coap-client
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libcoap
  TITLE:=CoAP (RFC 7252) client tool
endef

define Package/coap-client/description
  Constrained Application Protocol (RFC7252) client tool
endef

define Package/coap-server
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libcoap
  TITLE:=CoAP (RFC 7252) server programs
endef

define Package/coap-server/description
  Constrained Application Protocol (RFC 7252) server and resource directory server
endef

TARGET_CFLAGS += $(FPIC)

CONFIGURE_ARGS += \
	--enable-examples \
	--disable-documentation

ifeq ($(CONFIG_BIG_ENDIAN),y)
TARGET_CFLAGS += -DWORDS_BIGENDIAN
endif

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
endef

define Package/libcoap/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libcoap-1.so* $(1)/usr/lib/
endef

define Package/coap-client/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/coap-client $(1)/usr/bin/
endef

define Package/coap-server/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/coap-server $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/coap-rd $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libcoap))
$(eval $(call BuildPackage,coap-client))
$(eval $(call BuildPackage,coap-server))
