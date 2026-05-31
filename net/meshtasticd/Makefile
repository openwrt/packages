# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=meshtasticd
PKG_VERSION:=2.7.15
PKG_SOURCE_VERSION:=v$(PKG_VERSION).567b8ea
PKG_RELEASE:=2

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/meshtastic/firmware.git
PKG_MIRROR_HASH:=07a85f6fb62103e841b88fbc38c2ed235b12dab8310fe4fe619c8a1754a9aa22

FRONTEND_VERSION:=2.6.7
FRONTEND_DEST:=$(PKG_NAME)-frontend-$(FRONTEND_VERSION).tar
FRONTEND_URL:=https://github.com/meshtastic/web/releases/download/v$(FRONTEND_VERSION)/
FRONTEND_HASH:=a34f4360a0486543a698de20de533557492e763ab459fc27fcea95d0495144ed

PKG_BUILD_DEPENDS:= \
	python3/host \
	python-platformio/host \
	python-pyelftools/host \
	!USE_GLIBC:argp-standalone

PKG_MAINTAINER:=Austin Lane <vidplace7@gmail.com>, George Sapkin <george@sapk.in>
PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/python/python3-host.mk
include $(INCLUDE_DIR)/nls.mk

define Package/meshtasticd/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Meshtastic
  TITLE:=Meshtastic daemon
  URL:=https://github.com/meshtastic/firmware
endef

# Leaving a possibility for adding a light variant without the web UI support if
# it's made configurable upstream. Currently headers are autodetected so it's
# not possible to add it.
define Package/meshtasticd-full
  $(call Package/meshtasticd/Default)
  TITLE+= (with web UI support)
  DEPENDS:= \
    +bluez-libs \
    +kmod-spi-dev \
    +libgpiod \
    +libi2c \
    +libopenssl \
    +liborcania \
    +libulfius-gnutls \
    +libusb-1.0 \
    +libuv \
    +libyaml-cpp \
    +libyder \
    +zlib \
    $(INTL_DEPENDS)
  PROVIDES:=meshtasticd
endef

define Package/meshtasticd-avahi-service
  $(call Package/meshtasticd/Default)
  TITLE+= (avahi service)
  DEPENDS:= \
    +avahi-daemon \
    +meshtasticd
endef

define Package/meshtasticd-web
  $(call Package/meshtasticd/Default)
  TITLE:=Meshtastic daemon web interface
  URL:=https://github.com/meshtastic/web
  DEPENDS:=+meshtasticd-full
  VERSION:=$(FRONTEND_VERSION)-r$(PKG_RELEASE)
endef

define Package/meshtasticd-full/description
  Meshtastic daemon with web interface support
endef

define Package/meshtasticd-avahi-service/description
  Service definition for announcing the Meshtastic daemon via mDNS
endef

define Package/meshtasticd-web/description
  The official Meshtastic web interface
endef

define Download/meshtasticd-web
  URL:=$(FRONTEND_URL)
  URL_FILE:=build.tar
  FILE:=$(FRONTEND_DEST)
  HASH:=$(FRONTEND_HASH)
endef

PLATFORMIO_BUILD_FLAGS := \
	-fdata-sections \
	-ffunction-sections \
	-Os \
	-Wl,--gc-sections \
	-lcrypto \
	-lorcania \
	-lssl \
	-lulfius \
	-lyder \
	$(if $(CONFIG_USE_GLIBC),,-largp) \
	$(if $(INTL_FULL),-lintl)

BUILD_FLAGS := \
	TARGET_AR="$(TARGET_AR)" \
	TARGET_AS="$(TARGET_CC) -c $(TARGET_ASFLAGS)" \
	TARGET_CC="$(TARGET_CC)" \
	TARGET_CFLAGS="$(TARGET_CFLAGS)" \
	TARGET_CXX="$(TARGET_CXX)" \
	TARGET_CXXFLAGS="$(TARGET_CXXFLAGS)" \
	TARGET_LD="$(TARGET_LD)" \
	TARGET_LDFLAGS="$(TARGET_LDFLAGS)" \
	TARGET_OBJCOPY="$(TARGET_CROSS)objcopy" \
	TARGET_RANLIB="$(TARGET_RANLIB)" \
	PLATFORMIO_BUILD_CACHE_DIR="$(PKG_BUILD_DIR)/.pio-build-cache" \
	PLATFORMIO_CACHE_DIR="$(DL_DIR)/platformio-cache"

define Build/Prepare/meshtasticd-web
	mkdir -p $(PKG_BUILD_DIR)/web
	$(HOST_TAR) -xf $(DL_DIR)/$(FRONTEND_DEST) -C $(PKG_BUILD_DIR)/web
	gzip -dr $(PKG_BUILD_DIR)/web/
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	$(call Build/Prepare/meshtasticd-web)
endef

define Build/Compile/meshtasticd-full
	mkdir -p $(PKG_BUILD_DIR)/full

	$(BUILD_FLAGS) \
	PLATFORMIO_BUILD_DIR="$(PKG_BUILD_DIR)/full" \
	PLATFORMIO_BUILD_FLAGS="$(PLATFORMIO_BUILD_FLAGS)" \
	$(HOST_PYTHON3_BIN) -m platformio run \
		--environment buildroot \
		--project-dir $(PKG_BUILD_DIR)
endef

define Build/Compile
	$(call Build/Compile/meshtasticd-full)
endef

define Package/meshtasticd-full/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/meshtasticd.conf $(1)/etc/config/meshtasticd

	$(INSTALL_DIR) $(1)/etc/meshtasticd
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/bin/config-dist.yaml $(1)/etc/meshtasticd/config.yaml

	$(INSTALL_DIR) $(1)/etc/meshtasticd/available.d
	$(CP) -R $(PKG_BUILD_DIR)/bin/config.d/* $(1)/etc/meshtasticd/available.d

	$(INSTALL_DIR) $(1)/etc/meshtasticd/config.d

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/meshtasticd.init $(1)/etc/init.d/meshtasticd

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/full/buildroot/program $(1)/usr/bin/meshtasticd
endef

define Package/meshtasticd-avahi-service/install
	$(INSTALL_DIR) $(1)/etc/avahi/services
	$(INSTALL_CONF) ./files/meshtasticd.service $(1)/etc/avahi/services/
endef

define Package/meshtasticd-web/install
	$(INSTALL_DIR) $(1)/usr/share/meshtasticd/web
	$(CP) $(PKG_BUILD_DIR)/web/* $(1)/usr/share/meshtasticd/web

	$(INSTALL_DIR) $(1)/etc/meshtasticd/ssl
endef

define Package/meshtasticd-full/conffiles
/etc/config/meshtasticd
/etc/meshtasticd/config.d/
/etc/meshtasticd/config.yaml
/etc/meshtasticd/ssl
endef

define Package/meshtasticd-avahi-service/conffiles
/etc/avahi/services/meshtasticd.service
endef

$(eval $(call Download,meshtasticd-web))
$(eval $(call BuildPackage,meshtasticd-full))
$(eval $(call BuildPackage,meshtasticd-avahi-service))
$(eval $(call BuildPackage,meshtasticd-web))
