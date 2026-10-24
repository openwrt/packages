# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=sendspin-cli
PKG_VERSION:=0.3.0
PKG_RELEASE:=1

PKG_SOURCE:=sendspin-cpp-cli-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/Sendspin/sendspin-cpp-cli/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=baa9febbc08d58e1780d6a62fb0b20d458cd1a3cbb177929ba5f4ff0b01d335c
PKG_BUILD_DIR:=$(BUILD_DIR)/sendspin-cpp-cli-$(PKG_VERSION)

PKG_MAINTAINER:=Michaël Guay-Lambert <mguaylam.dev@gmail.com>
PKG_LICENSE:=Apache-2.0 BSD-3-Clause MIT
# The bundled dependencies land under openwrt-deps/ in Build/Prepare below.
PKG_LICENSE_FILES:=LICENSE \
	openwrt-deps/sendspin-cpp/LICENSE \
	openwrt-deps/ArduinoJson/LICENSE.txt \
	openwrt-deps/IXWebSocket/LICENSE.txt \
	openwrt-deps/micro-flac/LICENSE

PKG_BUILD_FLAGS:=no-mips16

# The versions sendspin-cli v$(PKG_VERSION) pins through FetchContent
# (SENDSPIN_GIT_TAG, then sendspin-cpp's cmake/host.cmake).
SENDSPIN_CPP_VERSION:=0.8.0
ARDUINOJSON_VERSION:=7.4.1
IXWEBSOCKET_VERSION:=11.4.5
MICRO_FLAC_VERSION:=0.1.1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/sendspin-cli
  SECTION:=sound
  CATEGORY:=Sound
  TITLE:=Sendspin synchronized audio player
  URL:=https://github.com/Sendspin/sendspin-cpp-cli
  # Not offered on big-endian: software volume, the Opus decoder and
  # micro-flac's sample packing write samples in host byte order into buffers
  # the ALSA sink opens as _LE. Reproduced under qemu-mips and reported as
  # Sendspin/sendspin-cpp-cli#70, Sendspin/sendspin-cpp#132 and
  # esphome-libs/micro-flac#36. Drop once they are fixed.
  DEPENDS:=+alsa-lib +libatomic +libopus +libstdcpp +umdns @!BIG_ENDIAN
  USERID:=sendspin:audio=29
endef

define Package/sendspin-cli/description
  Headless player for Sendspin, the synchronized multi-room audio protocol
  used by Music Assistant. It plays through ALSA and is announced over mDNS
  so a Sendspin server can discover it.
endef

define Package/sendspin-cli/conffiles
/etc/config/sendspin-cli
endef

define Download/sendspin-cpp
  URL:=https://codeload.github.com/Sendspin/sendspin-cpp/tar.gz/v$(SENDSPIN_CPP_VERSION)?
  FILE:=sendspin-cpp-$(SENDSPIN_CPP_VERSION).tar.gz
  HASH:=cfd485ca5ecaff2406af382f309ce7d0c8709d56ac6c0a3a7420f8d423978a02
endef
$(eval $(call Download,sendspin-cpp))

define Download/arduinojson
  URL:=https://codeload.github.com/bblanchon/ArduinoJson/tar.gz/v$(ARDUINOJSON_VERSION)?
  FILE:=ArduinoJson-$(ARDUINOJSON_VERSION).tar.gz
  HASH:=4db7245408c58c4869c135aece5e92c784d8026f5dbc6efd0485e52b84264d10
endef
$(eval $(call Download,arduinojson))

define Download/ixwebsocket
  URL:=https://codeload.github.com/machinezone/IXWebSocket/tar.gz/v$(IXWEBSOCKET_VERSION)?
  FILE:=IXWebSocket-$(IXWEBSOCKET_VERSION).tar.gz
  HASH:=c5fc225edec32bf7d583e55347ef2c9c4940d005c13ef5e848354a85602f5fd6
endef
$(eval $(call Download,ixwebsocket))

define Download/micro-flac
  URL:=https://codeload.github.com/esphome-libs/micro-flac/tar.gz/v$(MICRO_FLAC_VERSION)?
  FILE:=micro-flac-$(MICRO_FLAC_VERSION).tar.gz
  HASH:=4cc9c69f1ec06e7d0a7bd116bc61cc3f398d056eb9b2e9402a8a4790e307e854
endef
$(eval $(call Download,micro-flac))

DEPS_DIR:=$(PKG_BUILD_DIR)/openwrt-deps

# $(1): directory under $(DEPS_DIR), $(2): archive in $(DL_DIR)
define Prepare/dependency
	mkdir -p $(DEPS_DIR)/$(1)
	$(HOST_TAR) -C $(DEPS_DIR)/$(1) --strip-components=1 -xzf $(DL_DIR)/$(2)
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	$(call Prepare/dependency,sendspin-cpp,sendspin-cpp-$(SENDSPIN_CPP_VERSION).tar.gz)
	$(call Prepare/dependency,ArduinoJson,ArduinoJson-$(ARDUINOJSON_VERSION).tar.gz)
	$(call Prepare/dependency,IXWebSocket,IXWebSocket-$(IXWEBSOCKET_VERSION).tar.gz)
	$(call Prepare/dependency,micro-flac,micro-flac-$(MICRO_FLAC_VERSION).tar.gz)
	$(CP) ./cmake/micro-opus $(DEPS_DIR)/
endef

# Hand every FetchContent dependency a local source tree and forbid any
# download. micro-opus is replaced by a shim over the feed's libopus, and
# micro-flac's Ogg container support, which Sendspin does not use, is left out
# along with the micro-ogg-demuxer submodule it needs.
CMAKE_OPTIONS += \
	-DFETCHCONTENT_FULLY_DISCONNECTED=ON \
	-DFETCHCONTENT_SOURCE_DIR_SENDSPIN=$(DEPS_DIR)/sendspin-cpp \
	-DFETCHCONTENT_SOURCE_DIR_ARDUINOJSON=$(DEPS_DIR)/ArduinoJson \
	-DFETCHCONTENT_SOURCE_DIR_IXWEBSOCKET=$(DEPS_DIR)/IXWebSocket \
	-DFETCHCONTENT_SOURCE_DIR_MICRO_FLAC=$(DEPS_DIR)/micro-flac \
	-DFETCHCONTENT_SOURCE_DIR_MICRO_OPUS=$(DEPS_DIR)/micro-opus \
	-DMICRO_FLAC_ENABLE_OGG=OFF \
	-DSENDSPIN_CLI_BUILD_TESTS=OFF \
	-DSENDSPIN_CLI_WITH_ALSA=ON \
	-DSENDSPIN_CLI_WITH_MDNS=OFF \
	-DSENDSPIN_CLI_WITH_PIPEWIRE=OFF \
	-DSENDSPIN_CLI_WITH_PORTAUDIO=OFF \
	-DSENDSPIN_CLI_WITH_PULSE=OFF \
	-DSENDSPIN_CLI_WERROR=OFF

# 64-bit std::atomic needs libatomic on 32-bit targets without those ops
TARGET_LDFLAGS += -latomic

define Package/sendspin-cli/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/sendspin-cli $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/sendspin-cli.config $(1)/etc/config/sendspin-cli
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/sendspin-cli.init $(1)/etc/init.d/sendspin-cli
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DATA) ./files/sendspin-cli.hotplug $(1)/etc/hotplug.d/iface/50-sendspin-cli
endef

$(eval $(call BuildPackage,sendspin-cli))
