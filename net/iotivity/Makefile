#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=iotivity
PKG_VERSION:=0.9.1
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://gerrit.iotivity.org/gerrit/iotivity
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=0.9.1
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MIRROR_MD5SUM:=
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
  DEPENDS:=@!USE_UCLIBC +libpthread +librt +libstdcpp +libuuid
  TITLE:=IoTivity Library
  URL:=https://www.iotivity.org
endef

define Package/iotivity/description
    IoTivity is a framework for the Internet of Things based on the
    Open Interconnect Consortium Specification.
endef


define Package/iotivity-things-manager-lib
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=iotivity
  TITLE:=IoTivity things manager lib
  URL:=https://www.iotivity.org
endef

define Package/iotivity-things-manager-lib/description
    IoTivity things-manager lib
endef


define Package/iotivity-plugin-manager-lib
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=iotivity +libexpat
  TITLE:=IoTivity plugin manager lib
  URL:=https://www.iotivity.org
endef

define Package/iotivity-plugin-manager-lib/description
    IoTivity plugin manager lib
endef


define Package/iotivity-mqttclient
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=iotivity +iotivity-plugin-manager-lib +boost +boost-system
  TITLE:=IoTivity mqtt Client
  URL:=https://www.iotivity.org
endef

define Package/iotivity-mqttclient/description
    IoTivity mqtt Client
endef


define Package/iotivity-oic-middle
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=iotivity
  TITLE:=IoTivity OIC Middle
  URL:=https://www.iotivity.org
endef

define Package/iotivity-oic-middle/description
    IoTivity OIC Middle
endef


define Package/iotivity-things-manager
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=iotivity +iotivity-things-manager-lib
  TITLE:=IoTivity things manager
  URL:=https://www.iotivity.org
endef

define Package/iotivity-things-manager/description
    IoTivity things manager
endef


define Package/iotivity-example-garage
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=iotivity
  TITLE:=IoTivity Garage example
  URL:=https://www.iotivity.org
endef

define Package/iotivity-example-garage/description
    An IoTivity example application
endef


PKG_CEREAL_NAME:=cereal
PKG_CEREAL_VERSION:=7121e91e6ab8c3e6a6516d9d9c3e6804e6f65245
PKG_CEREAL_SOURCE:=$(PKG_CEREAL_NAME)-$(PKG_CEREAL_VERSION).tar.bz2
PKG_CEREAL_PROTO:=git
PKG_CEREAL_SOURCE_URL:=https://github.com/USCiLab/cereal.git
PKG_CEREAL_SUBDIR:=$(PKG_CEREAL_NAME)
#PKG_CEREAL_MIRROR_MD5SUM:=?

define Download/iotivity-cereal
  FILE:=$(PKG_CEREAL_SOURCE)
  URL:=$(PKG_CEREAL_SOURCE_URL)
  PROTO:=$(PKG_CEREAL_PROTO)
  VERSION:=$(PKG_CEREAL_VERSION)
  SUBDIR:=$(PKG_CEREAL_SUBDIR)
  #MIRROR_MD5SUM:=$(PKG_CEREAL_MIRROR_MD5SUM)
endef
$(eval $(call Download,iotivity-cereal))


SCONS_OPTIONS += \
	TARGET_OS=linux \
	TARGET_TRANSPORT=ALL \
	TARGET_ARCH=$(ARCH) \
	STAGING_DIR=$(STAGING_DIR) \
	mqttclient examples samples libTGMSDK ConServerApp ConClientApp BootstrapServerApp

ifneq ($(findstring c,$(OPENWRT_VERBOSE)),)
  SCONS_OPTIONS += VERBOSE=true
endif

define Build/Prepare
	$(call Build/Prepare/Default)
	$(TAR) -C $(PKG_BUILD_DIR)/extlibs/cereal -xjf $(DL_DIR)/$(PKG_CEREAL_SOURCE)
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
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/release/liboc.so $(1)/usr/lib/liboc.so
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/release/liboc_logger.so $(1)/usr/lib/liboc_logger.so
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/release/liboctbstack.so $(1)/usr/lib/liboctbstack.so
endef

define Package/iotivity-things-manager-lib/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/release/libTGMSDKLibrary.so $(1)/usr/lib/libTGMSDKLibrary.so
endef

define Package/iotivity-plugin-manager-lib/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/release/libpmimpl.so $(1)/usr/lib/libpmimpl.so
endef

define Package/iotivity-mqttclient/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/release/service/protocol-plugin/sample-app/linux/mqtt/mqttclient $(1)/usr/bin/mqttclient
endef

define Package/iotivity-oic-middle/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/release/examples/OICMiddle/OICMiddle $(1)/usr/bin/OICMiddle
endef

define Package/iotivity-things-manager/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/release/service/things-manager/sampleapp/linux/configuration/bootstrapserver $(1)/usr/bin/bootstrapserver
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/release/service/things-manager/sampleapp/linux/configuration/con-server $(1)/usr/bin/con-server
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/release/service/things-manager/sampleapp/linux/configuration/con-client $(1)/usr/bin/con-client
endef

define Package/iotivity-example-garage/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/release/resource/examples/garageclient $(1)/usr/bin/garageclient
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/release/resource/examples/garageserver $(1)/usr/bin/garageserver
endef


$(eval $(call BuildPackage,iotivity))
$(eval $(call BuildPackage,iotivity-things-manager-lib))
$(eval $(call BuildPackage,iotivity-plugin-manager-lib))
$(eval $(call BuildPackage,iotivity-mqttclient))
$(eval $(call BuildPackage,iotivity-oic-middle))
$(eval $(call BuildPackage,iotivity-things-manager))
$(eval $(call BuildPackage,iotivity-example-garage))
