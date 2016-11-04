#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=iotivity
PKG_VERSION:=1.1.0
PKG_RELEASE=1

PKG_SOURCE:=${PKG_NAME}-${PKG_VERSION}.tar.gz
PKG_SOURCE_URL:=http://mirrors.kernel.org/${PKG_NAME}/${PKG_VERSION}/
PKG_MD5SUM:=98f8d5b0304c357520c4343d983491e2
PKG_USE_MIPS16:=0

PKG_BUILD_DEPENDS:=boost

PKG_MAINTAINER:=Hauke Mehrtens <hauke.mehrtens@intel.com>

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE.md

PKG_CONFIG_DEPENDS := \
	CONFIG_PACKAGE_iotivity \
	CONFIG_PACKAGE_iotivity-cpp \
	CONFIG_PACKAGE_iotivity-things-manager-lib \
	CONFIG_PACKAGE_iotivity-oic-middle \
	CONFIG_PACKAGE_iotivity-things-manager \
	CONFIG_PACKAGE_iotivity-resource-container-lib \
	CONFIG_PACKAGE_iotivity-resource-container-sample \
	CONFIG_PACKAGE_iotivity-resource-container-hue \
	CONFIG_PACKAGE_iotivity-example-garage \
	CONFIG_PACKAGE_iotivity_DEBUG \
	CONFIG_PACKAGE_iotivity_SECURE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/scons.mk


define Package/iotivity
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=@!USE_UCLIBC +libpthread +librt +libuuid
  TITLE:=IoTivity C Library
  URL:=https://www.iotivity.org
  MENU:=1
endef

define Package/iotivity/description
    IoTivity is a framework for the Internet of Things based on the
    Open Interconnect Consortium Specification.
endef

define Package/iotivity/config
  if PACKAGE_iotivity
	config PACKAGE_iotivity_DEBUG
		bool "IoTivity with debug support"
		help
		  Build IoTivity with debuging support.

	config PACKAGE_iotivity_SECURE
		bool "IoTivity with security support"
		default y
		help
		  Activate security support.

  endif
endef


define Package/iotivity-cpp
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+iotivity +libpthread +libstdcpp
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
  DEPENDS:=+iotivity +iotivity-cpp +libstdcpp
  TITLE:=IoTivity things manager lib
  URL:=https://www.iotivity.org
endef

define Package/iotivity-things-manager-lib/description
    IoTivity things-manager lib
endef


define Package/iotivity-oic-middle
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+iotivity +iotivity-cpp
  TITLE:=IoTivity OIC Middle
  URL:=https://www.iotivity.org
endef

define Package/iotivity-oic-middle/description
    IoTivity OIC Middle
endef


define Package/iotivity-things-manager
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+iotivity +iotivity-cpp +iotivity-things-manager-lib
  TITLE:=IoTivity things manager
  URL:=https://www.iotivity.org
endef

define Package/iotivity-things-manager/description
    IoTivity things manager
endef

define Package/iotivity-resource-container-lib
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+iotivity +iotivity-cpp +boost +boost-system +boost-thread +boost-date_time
  TITLE:=IoTivity Resource Container library
  URL:=https://www.iotivity.org
endef

define Package/iotivity-resource-container-sample
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+iotivity +iotivity-resource-container-lib
  TITLE:=IoTivity Resource Container sample Application
  URL:=https://www.iotivity.org
endef

define Package/iotivity-resource-container-hue
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+iotivity +iotivity-resource-container-lib +libcurl
  TITLE:=IoTivity Resource Container Hue Bundle
  URL:=https://www.iotivity.org
endef

define Package/iotivity-example-garage
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+iotivity +iotivity-cpp
  TITLE:=IoTivity Garage example
  URL:=https://www.iotivity.org
endef

define Package/iotivity-example-garage/description
    An IoTivity example application
endef


PKG_TINYCBOR_NAME:=tinycbor
PKG_TINYCBOR_VERSION:=43e3ac9490cf19459ec7b7bd13df3b66810fb62a
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

PKG_SQLITE_NAME:=sqlite
PKG_SQLITE_VERSION:=3081101
PKG_SQLITE_SOURCE:=$(PKG_SQLITE_NAME)-amalgamation-$(PKG_SQLITE_VERSION).zip
PKG_SQLITE_SOURCE_URL:=http://www.sqlite.org/2015/
PKG_SQLITE_SUBDIR:=$(PKG_SQLITE_NAME)
PKG_SQLITE_MD5SUM:=94907e831502e2080b76e281cfa24dde

define Download/iotivity-sqlite
  FILE:=$(PKG_SQLITE_SOURCE)
  URL:=$(PKG_SQLITE_SOURCE_URL)
  VERSION:=$(PKG_SQLITE_VERSION)
  SUBDIR:=$(PKG_SQLITE_SUBDIR)
  MD5SUM:=$(PKG_SQLITE_MD5SUM)
endef
$(eval $(call Download,iotivity-sqlite))


SCONS_OPTIONS += \
	TARGET_OS=linux \
	TARGET_TRANSPORT=IP \
	TARGET_ARCH=$(ARCH) \
	STAGING_DIR=$(STAGING_DIR) \
	LOGGING=true \
	$(if $(CONFIG_PACKAGE_iotivity),liboctbstack) \
	$(if $(CONFIG_PACKAGE_iotivity-cpp),liboc) \
	$(if $(CONFIG_PACKAGE_iotivity-things-manager-lib),libTGMSDK) \
	$(if $(CONFIG_PACKAGE_iotivity-oic-middle),examples) \
	$(if $(CONFIG_PACKAGE_iotivity-things-manager),ConServerApp ConClientApp BootstrapServerApp) \
	$(if $(CONFIG_PACKAGE_iotivity-resource-container-lib),libResContainer) \
	$(if $(CONFIG_PACKAGE_iotivity-resource-container-sample),containersample) \
	$(if $(CONFIG_PACKAGE_iotivity-resource-container-hue),libHueBundle) \
	$(if $(CONFIG_PACKAGE_iotivity-example-garage),examples) \

ifeq ($(CONFIG_PACKAGE_iotivity_DEBUG),y)
  SCONS_OPTIONS += RELEASE=false
  APP_OPTIM:=debug
else
  SCONS_OPTIONS += RELEASE=true
  APP_OPTIM:=release
endif

ifeq ($(CONFIG_PACKAGE_iotivity_SECURE),y)
  SCONS_OPTIONS += SECURED=1
else
  SCONS_OPTIONS += SECURED=0
endif

ifneq ($(findstring c,$(OPENWRT_VERBOSE)),)
  SCONS_OPTIONS += VERBOSE=true
endif

define Build/Prepare
	$(call Build/Prepare/Default)
	$(TAR) -C $(PKG_BUILD_DIR)/extlibs/tinycbor/ -xjf $(DL_DIR)/$(PKG_TINYCBOR_SOURCE)
	unzip -d $(PKG_BUILD_DIR)/extlibs/sqlite3/ $(DL_DIR)/$(PKG_SQLITE_SOURCE)
	mv $(PKG_BUILD_DIR)/extlibs/sqlite3/$(PKG_SQLITE_NAME)-amalgamation-$(PKG_SQLITE_VERSION)/sqlite3.h $(PKG_BUILD_DIR)/extlibs/sqlite3/
	mv $(PKG_BUILD_DIR)/extlibs/sqlite3/$(PKG_SQLITE_NAME)-amalgamation-$(PKG_SQLITE_VERSION)/sqlite3.c $(PKG_BUILD_DIR)/extlibs/sqlite3/
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
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/$(APP_OPTIM)/liboctbstack.so $(1)/usr/lib/
ifeq ($(CONFIG_PACKAGE_iotivity_SECURE),y)
	$(INSTALL_DIR) $(1)/etc/iotivity/
	$(INSTALL_DATA) ./files/etc/iotivity/oic_svr_db.cbor $(1)/etc/iotivity/
endif
endef

define Package/iotivity-cpp/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/$(APP_OPTIM)/liboc.so $(1)/usr/lib/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/$(APP_OPTIM)/liboc_logger.so $(1)/usr/lib/
endef

define Package/iotivity-things-manager-lib/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/$(APP_OPTIM)/libTGMSDKLibrary.so $(1)/usr/lib/
endef

define Package/iotivity-oic-middle/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/$(APP_OPTIM)/examples/OICMiddle/OICMiddle $(1)/usr/bin/
endef

define Package/iotivity-things-manager/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/$(APP_OPTIM)/service/things-manager/sampleapp/linux/configuration/bootstrapserver $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/$(APP_OPTIM)/service/things-manager/sampleapp/linux/configuration/con-server $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/$(APP_OPTIM)/service/things-manager/sampleapp/linux/configuration/con-client $(1)/usr/bin/
endef

define Package/iotivity-resource-container-lib/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/$(APP_OPTIM)/librcs_common.so $(1)/usr/lib/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/$(APP_OPTIM)/librcs_client.so $(1)/usr/lib/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/$(APP_OPTIM)/librcs_server.so $(1)/usr/lib/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/$(APP_OPTIM)/librcs_container.so $(1)/usr/lib/
endef

define Package/iotivity-resource-container-sample/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/$(APP_OPTIM)/service/resource-container/ContainerSample  $(1)/usr/bin/
endef

define Package/iotivity-resource-container-hue/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/$(APP_OPTIM)/libHueBundle.so $(1)/usr/lib/
endef

define Package/iotivity-example-garage/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/$(APP_OPTIM)/resource/examples/garageclient $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/$(APP_OPTIM)/resource/examples/garageserver $(1)/usr/bin/
endef


$(eval $(call BuildPackage,iotivity))
$(eval $(call BuildPackage,iotivity-cpp))
$(eval $(call BuildPackage,iotivity-things-manager-lib))
$(eval $(call BuildPackage,iotivity-oic-middle))
$(eval $(call BuildPackage,iotivity-things-manager))
$(eval $(call BuildPackage,iotivity-resource-container-lib))
$(eval $(call BuildPackage,iotivity-resource-container-sample))
$(eval $(call BuildPackage,iotivity-resource-container-hue))
$(eval $(call BuildPackage,iotivity-example-garage))
