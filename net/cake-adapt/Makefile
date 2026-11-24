# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=cake-adapt
PKG_VERSION:=1.0.5
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/huydoan94/cake-adapt/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=d5558cd419c8d46bdc958064cb97f963d1ea793866414c025906ec15033512ed

PKG_MAINTAINER:=Huy Doan <danghuy1994@gmail.com>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/bpf.mk

# Three variants of one daemon: without MQTT, with plain MQTT and with MQTT
# over TLS. They install the same files and each provides cake-adapt, so only
# one is installed and luci-app-cake-adapt accepts any of them.
MQTT_SUPPORTED:=$(if $(filter mqtt mqtt-ssl,$(BUILD_VARIANT)),1,0)
MQTT_TLS_SUPPORTED:=$(if $(filter mqtt-ssl,$(BUILD_VARIANT)),1,0)
# What the installed variant supports, read by LuCI: one word per line.
FEATURES:=$(if $(filter 1,$(MQTT_SUPPORTED)),mqtt) $(if $(filter 1,$(MQTT_TLS_SUPPORTED)),tls)

define Package/cake-adapt/Default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Adaptive bandwidth for CAKE
  URL:=https://github.com/huydoan94/cake-adapt
  DEPENDS:=+libuci +libubox +libubus +libnl-tiny +libbpf +zlib $(BPF_DEPENDS)
endef

define Package/cake-adapt
$(call Package/cake-adapt/Default)
  VARIANT:=base
  DEFAULT_VARIANT:=1
endef

define Package/cake-adapt-mqtt
$(call Package/cake-adapt/Default)
  TITLE+= (with MQTT)
  DEPENDS+= +libmosquitto-nossl
  VARIANT:=mqtt
  PROVIDES:=cake-adapt
  CONFLICTS:=cake-adapt
endef

define Package/cake-adapt-mqtt-ssl
$(call Package/cake-adapt/Default)
  TITLE+= (with MQTT over TLS)
  DEPENDS+= +libmosquitto-ssl +ca-bundle
  VARIANT:=mqtt-ssl
  PROVIDES:=cake-adapt
  CONFLICTS:=cake-adapt cake-adapt-mqtt
endef

define Package/cake-adapt/description
  Adjusts the bandwidth of existing CAKE qdiscs (set up by SQM) as the line's
  capacity changes, from ICMP delay measurements, to keep latency low under
  load. A native C port of cake-autorate.
endef

define Package/cake-adapt-mqtt/description
  $(call Package/cake-adapt/description)
  This variant can also send its log records to an MQTT broker.
endef

define Package/cake-adapt-mqtt-ssl/description
  $(call Package/cake-adapt/description)
  This variant can also send its log records to an MQTT broker, optionally
  over TLS with certificate and hostname verification.
endef

define Build/Compile
	$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR)/src \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(TARGET_CPPFLAGS)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		NETLINK_CFLAGS="-isystem $(STAGING_DIR)/usr/include/libnl-tiny" \
		NETLINK_LIBS="-lnl-tiny" \
		LIBBPF_CFLAGS="-isystem $(STAGING_DIR)/usr/include" \
		BPF_CLANG="$(CLANG)" \
		BPF_TARGET="$(BPF_TARGET)" \
		BPF_STRIP="$(LLVM_STRIP)" \
		BPF_INCLUDES="-I$(STAGING_DIR)/usr/include -I$(TOOLCHAIN_DIR)/include" \
		OBJECT_DIR="$(PKG_BUILD_DIR)/build" \
		MQTT_SUPPORTED="$(MQTT_SUPPORTED)" \
		MQTT_TLS_SUPPORTED="$(MQTT_TLS_SUPPORTED)" \
		WERROR= \
		VERSION="$(PKG_VERSION)-r$(PKG_RELEASE)"
endef

define Package/cake-adapt/conffiles
/etc/config/cake-adapt
/etc/cake-adapt/exec
endef

define Package/cake-adapt/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/cake-adapt $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/lib/bpf
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/build/tcpdelay.bpf.o $(1)/lib/bpf/cake-adapt-tcpdelay.o
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/cake-adapt.init $(1)/etc/init.d/cake-adapt
	$(INSTALL_DIR) $(1)/usr/libexec/cake-adapt
	$(INSTALL_BIN) ./files/cake-adapt.import $(1)/usr/libexec/cake-adapt/import
	$(INSTALL_BIN) ./files/cake-adapt.import-bash $(1)/usr/libexec/cake-adapt/import-bash
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/cake-adapt.config $(1)/etc/config/cake-adapt
	$(INSTALL_DIR) $(1)/etc/cake-adapt
	$(INSTALL_CONF) ./files/cake-adapt-exec.config $(1)/etc/cake-adapt/exec
	$(INSTALL_DIR) $(1)/usr/share/cake-adapt
	$(if $(strip $(FEATURES)),printf '%s\n' $(FEATURES),printf '') > $(1)/usr/share/cake-adapt/features
endef

Package/cake-adapt-mqtt/conffiles = $(Package/cake-adapt/conffiles)
Package/cake-adapt-mqtt-ssl/conffiles = $(Package/cake-adapt/conffiles)
Package/cake-adapt-mqtt/install = $(Package/cake-adapt/install)
Package/cake-adapt-mqtt-ssl/install = $(Package/cake-adapt/install)

$(eval $(call BuildPackage,cake-adapt))
$(eval $(call BuildPackage,cake-adapt-mqtt))
$(eval $(call BuildPackage,cake-adapt-mqtt-ssl))
