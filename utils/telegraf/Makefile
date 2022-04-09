# SPDX-License-Identifier: GPL-2.0-or-later

include $(TOPDIR)/rules.mk

PKG_NAME:=telegraf
PKG_VERSION:=1.22.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/influxdata/telegraf/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=ccfcf7ae1dbc1c99f1362742f1680ff7e026a93a90dce82c73de4ff21aeb01dc

PKG_MAINTAINER:=Jonathan Pagel <jonny_tischbein@systemli.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/influxdata/telegraf
GO_PKG_BUILD_PKG:=github.com/influxdata/telegraf/cmd/telegraf
GO_PKG_LDFLAGS_X:=main.version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/telegraf/Default
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=Telegraf
	DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/telegraf-full
	$(call Package/telegraf/Default)
	TITLE+= (Full)
	VARIANT:=full
endef

define Package/telegraf
	$(call Package/telegraf/Default)
	TITLE+= (Small)
	VARIANT:=small
endef

define Package/telegraf/description/Default
	Telegraf is a plugin-driven agent for collecting and sending metrics and events.
	It supports various inputs (including prometheus endpoints) and is able to send data into InfluxDB.
endef

define Package/telegraf/description
	$(call Package/telegraf/description/Default)
	(Small build. Most plugins excluded)
endef

define Package/telegraf-full/description
	$(call Package/telegraf/description/Default)
	(Full build. including all plugins)
endef

define Package/telegraf/conffiles
/etc/telegraf.conf
endef

Package/telegraf-full/conffiles = $(Package/telegraf/conffiles)

define Build/Prepare
	$(call Build/Prepare/Default)
ifeq ($(BUILD_VARIANT),small)
	$(CP) ./variant-$(BUILD_VARIANT)/* $(PKG_BUILD_DIR)/
endif
endef

define Package/telegraf/install
	$(call GoPackage/Package/Install/Bin,$(1))
	$(INSTALL_DIR) $(1)/etc/init.d $(1)/etc/config
	$(INSTALL_BIN) ./files/etc/init.d/telegraf $(1)/etc/init.d/telegraf
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/etc/telegraf.conf $(1)/etc/telegraf.conf
endef

define Package/telegraf-full/install
	$(call Package/telegraf/install,$(1))
endef

$(eval $(call GoBinPackage,telegraf))
$(eval $(call BuildPackage,telegraf))

$(eval $(call GoBinPackage,telegraf-full))
$(eval $(call BuildPackage,telegraf-full))
