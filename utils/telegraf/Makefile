# SPDX-License-Identifier: GPL-2.0-or-later

include $(TOPDIR)/rules.mk

PKG_NAME:=telegraf
PKG_VERSION:=1.36.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/influxdata/telegraf/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=d4f647b3ff995698e4490cf9f156ec6d53552cd16287782a196c937ff8d748c3

PKG_MAINTAINER:=Niklas Thorild <niklas@thorild.se>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/influxdata/telegraf
GO_PKG_BUILD_PKG:=github.com/influxdata/telegraf/cmd/telegraf
GO_PKG_LDFLAGS_X := \
  github.com/influxdata/telegraf/internal.Version=$(PKG_VERSION) \
  github.com/influxdata/telegraf/internal.Branch=HEAD \
  github.com/influxdata/telegraf/internal.Commit=467473bd

ifeq ($(CONFIG_mips)$(CONFIG_mipsel),y)
  TARGET_LDFLAGS += -static
endif

TELEGRAF_SMALL_PLUGINS:=custom \
	inputs.cpu \
	inputs.ethtool \
	inputs.internal \
	inputs.interrupts \
	inputs.ipset \
	inputs.iptables \
	inputs.kernel \
	inputs.mem \
	inputs.net \
	inputs.net_response \
	inputs.ping \
	inputs.processes \
	inputs.procstat \
	inputs.prometheus \
	inputs.sensors \
	inputs.snmp \
	inputs.socket_listener \
	inputs.swap \
	inputs.syslog \
	inputs.system \
	inputs.tail \
	inputs.wireguard \
	inputs.wireless \
	outputs.exec \
	outputs.file \
	outputs.graphite \
	outputs.http \
	outputs.influxdb \
	outputs.influxdb_v2 \
	outputs.prometheus_client \
	outputs.syslog

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

ifeq ($(BUILD_VARIANT),small)
	GO_PKG_TAGS:=$(TELEGRAF_SMALL_PLUGINS)
else
	GO_PKG_TAGS:=
endif

define Package/telegraf/install
	$(call GoPackage/Package/Install/Bin,$(1))
	$(INSTALL_DIR) $(1)/etc/init.d $(1)/etc/config
	$(INSTALL_BIN) ./files/etc/init.d/telegraf $(1)/etc/init.d/telegraf
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/etc/uci-defaults/90-telegraf $(1)/etc/uci-defaults/90-telegraf
endef

define Package/telegraf-full/install
	$(call Package/telegraf/install,$(1))
endef

$(eval $(call GoBinPackage,telegraf))
$(eval $(call BuildPackage,telegraf))

$(eval $(call GoBinPackage,telegraf-full))
$(eval $(call BuildPackage,telegraf-full))
