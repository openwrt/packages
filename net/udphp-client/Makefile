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
PKG_SOURCE_DATE:=2023-01-13
PKG_SOURCE_VERSION:=7c0fc5fcf3b807b053c5906bdd8c2acb244c1cbd
PKG_MIRROR_HASH:=f69c685aa6dba380ab0b2ac64ff100bcdc97eb30477623d80c1b9132e530d9f4

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
