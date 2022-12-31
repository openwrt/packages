# Copyright (C) 2022 Almaz Gaifullin <gargargar@yandex.com>
#
# This is free software, licensed under the MIT
#

include $(TOPDIR)/rules.mk

PKG_NAME:=udphp-client
PKG_RELEASE:=1

PKG_MAINTAINER:=Almaz Gaifullin <gargargar@yandex.com>
PKG_LICENSE:=MIT

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/gargargar/udphp.git
PKG_SOURCE_DATE:=2022-12-30
PKG_SOURCE_VERSION:=e4ab512ab5ba3955fd5a23a76ffaae00f627ec3c
PKG_MIRROR_HASH:=68ce9885b7fc1e10ff2afbe003dd65489d3e64ca0212914c513469e581127974

include $(INCLUDE_DIR)/package.mk

define Package/udphp-client
  SECTION:=net
  CATEGORY:=Network
  TITLE:=UDP hole punching client
  URL:=https://github.com/gargargar/udphp
  DEPENDS:=+libstdcpp +libuuid
endef

define Package/udphp-client/description
 UDP hole punching tool and client for signaling server udphp-server
endef

MAKE_PATH = client
MAKE_FLAGS += \
	TARGETDIR=$(PKG_BUILD_DIR)

define Package/udphp-client/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/udphp-client $(1)/usr/bin
endef

$(eval $(call BuildPackage,udphp-client))
