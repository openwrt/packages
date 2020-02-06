#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=iotivity
PKG_VERSION:=1.2.1
PKG_RELEASE:=2

PKG_SOURCE:=${PKG_NAME}-${PKG_VERSION}.tar.gz
PKG_SOURCE_URL:=http://mirrors.kernel.org/${PKG_NAME}/${PKG_VERSION}/
PKG_HASH:=7dcd9f0f48263c6b27a2c3d085dd7278b5c0feed1dfec8872a04899707fa23d8
PKG_USE_MIPS16:=0

PKG_BUILD_DEPENDS:=boost python/host scons/host

PKG_MAINTAINER:=Hauke Mehrtens <hauke.mehrtens@intel.com>

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE.md

PKG_CONFIG_DEPENDS := \
	CONFIG_PACKAGE_iotivity \
	CONFIG_PACKAGE_iotivity-cpp \
	CONFIG_PACKAGE_iotivity-resource-directory-lib \
	CONFIG_PACKAGE_iotivity-oic-middle \
	CONFIG_PACKAGE_iotivity-resource-container-lib \
	CONFIG_PACKAGE_iotivity-resource-container-sample \
	CONFIG_PACKAGE_iotivity-resource-container-hue \
	CONFIG_PACKAGE_iotivity-example-garage \
	CONFIG_PACKAGE_iotivity-example-simple \
	CONFIG_PACKAGE_iotivity_DEBUG \
	CONFIG_PACKAGE_iotivity_SECURE

include $(INCLUDE_DIR)/package.mk
include ../../devel/scons/scons.mk


define Package/iotivity
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=@!USE_UCLIBC +libpthread +librt +libuuid +libsqlite3 +PACKAGE_iotivity_SECURE:libmbedtls
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
		help
		  Activate security support.

	config PACKAGE_iotivity_LOGGING
		bool "IoTivity with logging support"
		default y
		help
		  Activate logging support.
		  This will make IoTivity write a lot of log messages to stdout.
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

define Package/iotivity-resource-directory-lib
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+iotivity +iotivity-cpp
  TITLE:=IoTivity Resource Directory library
  URL:=https://www.iotivity.org
endef


define Package/iotivity-oic-middle
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+iotivity +iotivity-cpp +iotivity-resource-directory-lib
  TITLE:=IoTivity OIC Middle
  URL:=https://www.iotivity.org
endef

define Package/iotivity-oic-middle/description
    IoTivity OIC Middle
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
  DEPENDS:=+iotivity +iotivity-cpp +iotivity-resource-directory-lib
  TITLE:=IoTivity Garage example
  URL:=https://www.iotivity.org
endef

define Package/iotivity-example-garage/description
    An IoTivity example application
endef

define Package/iotivity-example-simple
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+iotivity +iotivity-cpp +iotivity-resource-directory-lib
  TITLE:=IoTivity simple client + server
  URL:=https://www.iotivity.org
endef

define Package/iotivity-example-simple/description
    The IoTivity simple client and simple server exmaple
endef


PKG_TINYCBOR_NAME:=tinycbor
PKG_TINYCBOR_PROTO:=git
PKG_TINYCBOR_VERSION:=0.4
PKG_TINYCBOR_SOURCE_VERSION:=a088996aa5f59b4f27f20fadad053d88bee357d4
PKG_TINYCBOR_MIRROR_HASH:=77c600bd7362df8291148fa3d94ca780815ea2b74b817dca7565310ea0abff96
PKG_TINYCBOR_SOURCE:=$(PKG_TINYCBOR_NAME)-$(PKG_TINYCBOR_VERSION).tar.bz2
PKG_TINYCBOR_SOURCE_URL:=https://github.com/01org/tinycbor.git
PKG_TINYCBOR_SUBDIR:=$(PKG_TINYCBOR_NAME)

define Download/iotivity-tinycbor
  FILE:=$(PKG_TINYCBOR_SOURCE)
  URL:=$(PKG_TINYCBOR_SOURCE_URL)
  MIRROR_HASH:=$(PKG_TINYCBOR_MIRROR_HASH)
  PROTO:=$(PKG_TINYCBOR_PROTO)
  VERSION:=$(PKG_TINYCBOR_SOURCE_VERSION)
  SUBDIR:=$(PKG_TINYCBOR_SUBDIR)
endef
$(eval $(call Download,iotivity-tinycbor))


EXTRA_CXXFLAGS += -std=gnu++11

SCONS_OPTIONS += \
	TARGET_OS=linux \
	TARGET_TRANSPORT=IP \
	TARGET_ARCH=$(ARCH) \
	STAGING_DIR=$(STAGING_DIR) \
	WITH_ENV=true \
	octbstack oc \
	$(if $(CONFIG_PACKAGE_iotivity-oic-middle),examples) \
	$(if $(CONFIG_PACKAGE_iotivity-resource-container-lib),libResContainer) \
	$(if $(CONFIG_PACKAGE_iotivity-resource-container-sample),containersample) \
	$(if $(CONFIG_PACKAGE_iotivity-resource-container-hue),libHueBundle) \
	$(if $(CONFIG_PACKAGE_iotivity-example-garage),examples) \
	$(if $(CONFIG_PACKAGE_iotivity-example-simple),examples) \
	install

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

ifeq ($(CONFIG_PACKAGE_iotivity_LOGGING),y)
  SCONS_OPTIONS += LOGGING=true
endif

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
		python2.7 $(STAGING_DIR_HOSTPKG)/bin/scons \
			$(SCONS_OPTIONS) \
	)
endef


define Package/iotivity/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/$(APP_OPTIM)/libconnectivity_abstraction.so $(1)/usr/lib/
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

define Package/iotivity-resource-directory-lib/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/$(APP_OPTIM)/libresource_directory.so $(1)/usr/lib/
endef

define Package/iotivity-oic-middle/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/$(APP_OPTIM)/examples/OICMiddle/OICMiddle $(1)/usr/bin/
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

define Package/iotivity-example-simple/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/$(APP_OPTIM)/resource/examples/simpleclient $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/$(APP_OPTIM)/resource/examples/simpleserver $(1)/usr/bin/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/$(APP_OPTIM)/include $(1)/usr/include/iotivity

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/$(APP_OPTIM)/libconnectivity_abstraction.so $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/$(APP_OPTIM)/liboctbstack.so $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/$(APP_OPTIM)/liboc.so $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/$(APP_OPTIM)/liboc_logger.so $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/out/linux/$(ARCH)/$(APP_OPTIM)/libresource_directory.so $(1)/usr/lib/
endef
	

$(eval $(call BuildPackage,iotivity))
$(eval $(call BuildPackage,iotivity-cpp))
$(eval $(call BuildPackage,iotivity-resource-directory-lib))
$(eval $(call BuildPackage,iotivity-oic-middle))
$(eval $(call BuildPackage,iotivity-resource-container-lib))
$(eval $(call BuildPackage,iotivity-resource-container-sample))
$(eval $(call BuildPackage,iotivity-resource-container-hue))
$(eval $(call BuildPackage,iotivity-example-garage))
$(eval $(call BuildPackage,iotivity-example-simple))
