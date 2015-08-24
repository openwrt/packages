#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=iotivity
PKG_VERSION:=0.9.2
PKG_RELEASE=1

PKG_SOURCE:=${PKG_NAME}-${PKG_VERSION}.tar.gz
PKG_SOURCE_URL:=https://downloads.iotivity.org/${PKG_VERSION}/ \
	http://mirrors.kernel.org/${PKG_NAME}/${PKG_VERSION}/
PKG_MD5SUM:=cf32e10a8f355fe1327db98ffc9a6173
PKG_USE_MIPS16:=0

PKG_MAINTAINER:=Hauke Mehrtens <hauke.mehrtens@lantiq.com>

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE.md

PKG_BUILD_DEPENDS:= +boost +libexpat

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/scons.mk


define Package/iotivity
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=@!USE_UCLIBC +libpthread +librt +libuuid
  TITLE:=IoTivity C Library
  URL:=https://www.iotivity.org
endef

define Package/iotivity/description
    IoTivity is a framework for the Internet of Things based on the
    Open Interconnect Consortium Specification.
endef


define Package/iotivity-cpp
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=iotivity +libpthread +libstdcpp
  TITLE:=IoTivity C++ Library
  URL:=https://www.iotivity.org
endef

define Package/iotivity-cpp/description
    IoTivity is a framework for the Internet of Things based on the
    Open Interconnect Consortium Specification.
endef


define Package/iotivity-things-manager-lib
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=iotivity +iotivity-cpp +libstdcpp
  TITLE:=IoTivity things manager lib
  URL:=https://www.iotivity.org
endef

define Package/iotivity-things-manager-lib/description
    IoTivity things-manager lib
endef


define Package/iotivity-plugin-manager-lib
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=iotivity +iotivity-cpp +libexpat +boost +boost-system
  TITLE:=IoTivity plugin manager lib
  URL:=https://www.iotivity.org
endef

define Package/iotivity-plugin-manager-lib/description
    IoTivity plugin manager lib
endef


define Package/iotivity-mqttclient
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=iotivity +iotivity-cpp +iotivity-plugin-manager-lib +boost +boost-system
  TITLE:=IoTivity mqtt Client
  URL:=https://www.iotivity.org
endef

define Package/iotivity-mqttclient/description
    IoTivity mqtt Client
endef


define Package/iotivity-oic-middle
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=iotivity +iotivity-cpp
  TITLE:=IoTivity OIC Middle
  URL:=https://www.iotivity.org
endef

define Package/iotivity-oic-middle/description
    IoTivity OIC Middle
endef


define Package/iotivity-things-manager
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=iotivity +iotivity-cpp +iotivity-things-manager-lib
  TITLE:=IoTivity things manager
  URL:=https://www.iotivity.org
endef

define Package/iotivity-things-manager/description
    IoTivity things manager
endef


define Package/iotivity-example-garage
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=iotivity +iotivity-cpp
  TITLE:=IoTivity Garage example
  URL:=https://www.iotivity.org
endef

define Package/iotivity-example-garage/description
    An IoTivity example application
endef


PKG_TINYCBOR_NAME:=tinycbor
PKG_TINYCBOR_VERSION:=3e83c0dc6e55bc73e9a4a7343ab8e06c43127efa
PKG_TINYCBOR_SOURCE:=$(PKG_TINYCBOR_NAME)-$(PKG_TINYCBOR_VERSION).tar.bz2
PKG_TINYCBOR_PROTO:=git
PKG_TINYCBOR_SOURCE_URL:=https://github.com/01org/tinycbor.git
PKG_TINYCBOR_SUBDIR:=$(PKG_TINYCBOR_NAME)
#PKG_TINYCBOR_MIRROR_MD5SUM:=?

define Download/iotivity-tinycbor
  FILE:=$(PKG_TINYCBOR_SOURCE)
  URL:=$(PKG_TINYCBOR_SOURCE_URL)
  PROTO:=$(PKG_TINYCBOR_PROTO)
  VERSION:=$(PKG_TINYCBOR_VERSION)
  SUBDIR:=$(PKG_TINYCBOR_SUBDIR)
  #MIRROR_MD5SUM:=$(PKG_TINYCBOR_MIRROR_MD5SUM)
endef
$(eval $(call Download,iotivity-tinycbor))


SCONS_OPTIONS += \
	TARGET_OS=linux \
	TARGET_TRANSPORT=ALL \
	TARGET_ARCH=$(ARCH) \
	STAGING_DIR=$(STAGING_DIR) \
	LOGGING=true \
	SECURED=1 \
	mqttclient examples samples libTGMSDK ConServerApp ConClientApp BootstrapServerApp

ifneq ($(findstring c,$(OPENWRT_VERBOSE)),)
  SCONS_OPTIONS += VERBOSE=true
endif

define Build/Prepare
	$(call Build/Prepare/Default)
	$(TAR) -C $(PKG_BUILD_DIR)/extlibs/tinycbor/ -xjf $(DL_DIR)/$(PKG_TINYCBOR_SOURCE)
endef


define Build/Configure
	(cd $(PKG_BUILD_DIR); \
		$(SCONS_VARS) \
		scons \
			$(SCONS_OPTIONS) \
	)
endef


define Package/iotivity/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/release/liboctbstack.so $(1)/usr/lib/
endef

define Package/iotivity-cpp/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/release/liboc.so $(1)/usr/lib/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/release/liboc_logger.so $(1)/usr/lib/
endef

define Package/iotivity-things-manager-lib/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/release/libTGMSDKLibrary.so $(1)/usr/lib/
endef

define Package/iotivity-plugin-manager-lib/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/release/libpmimpl.so $(1)/usr/lib/
endef

define Package/iotivity-mqttclient/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/release/service/protocol-plugin/sample-app/linux/mqtt/mqttclient $(1)/usr/bin/
endef

define Package/iotivity-oic-middle/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/release/examples/OICMiddle/OICMiddle $(1)/usr/bin/
endef

define Package/iotivity-things-manager/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/release/service/things-manager/sampleapp/linux/configuration/bootstrapserver $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/release/service/things-manager/sampleapp/linux/configuration/con-server $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/release/service/things-manager/sampleapp/linux/configuration/con-client $(1)/usr/bin/
endef

define Package/iotivity-example-garage/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/release/resource/examples/garageclient $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/release/resource/examples/garageserver $(1)/usr/bin/
endef


$(eval $(call BuildPackage,iotivity))
$(eval $(call BuildPackage,iotivity-cpp))
$(eval $(call BuildPackage,iotivity-things-manager-lib))
$(eval $(call BuildPackage,iotivity-plugin-manager-lib))
$(eval $(call BuildPackage,iotivity-mqttclient))
$(eval $(call BuildPackage,iotivity-oic-middle))
$(eval $(call BuildPackage,iotivity-things-manager))
$(eval $(call BuildPackage,iotivity-example-garage))
