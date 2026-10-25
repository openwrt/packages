# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=sendspin-cli
PKG_VERSION:=0.4.0
PKG_RELEASE:=1

PKG_SOURCE:=sendspin-cpp-cli-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/Sendspin/sendspin-cpp-cli/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=baa7b5e05b504b7d530aecc21aba17b65793c570ff27587bf6351fe2f24d4b24
PKG_BUILD_DIR:=$(BUILD_DIR)/sendspin-cpp-cli-$(PKG_VERSION)

PKG_MAINTAINER:=Michaël Guay-Lambert <mguaylam.dev@gmail.com>
PKG_LICENSE:=Apache-2.0 BSD-3-Clause MIT
# The bundled dependencies land under openwrt-deps/ in Build/Prepare below.
PKG_LICENSE_FILES:=LICENSE \
	openwrt-deps/sendspin-cpp/LICENSE \
	openwrt-deps/ArduinoJson/LICENSE.txt \
	openwrt-deps/IXWebSocket/LICENSE.txt \
	openwrt-deps/micro-flac/LICENSE \
	openwrt-deps/noise-c/LICENSE

PKG_BUILD_FLAGS:=no-mips16

# The versions sendspin-cli v$(PKG_VERSION) pins through FetchContent
# (SENDSPIN_GIT_TAG, then sendspin-cpp's cmake/host.cmake).
SENDSPIN_CPP_VERSION:=0.9.5
ARDUINOJSON_VERSION:=7.4.1
IXWEBSOCKET_VERSION:=12.0.1
MICRO_FLAC_VERSION:=0.3.0
NOISE_C_VERSION:=0.1.13

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/sendspin-cli
  SECTION:=sound
  CATEGORY:=Sound
  TITLE:=Sendspin synchronized audio player
  URL:=https://github.com/Sendspin/sendspin-cpp-cli
  # Not offered on big-endian: noise-c's reference backend computes X25519
  # and ChaCha20 in host byte order, so the Noise handshake fails there.
  # Reproduced under qemu-mips against the RFC vectors; the audio itself is
  # correct there since 0.4.0, checked the same way. Drop once noise-c is
  # fixed.
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
  HASH:=e76e9491db42a8c00d7a978579dbf8a0b2f7459d49396baabf260d12cc7ffc6f
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
  HASH:=d23bdc91dbfe2b9ae13c322d539392d7a6b8b506560f41c90e227fa0f86a2405
endef
$(eval $(call Download,ixwebsocket))

define Download/micro-flac
  URL:=https://codeload.github.com/esphome-libs/micro-flac/tar.gz/v$(MICRO_FLAC_VERSION)?
  FILE:=micro-flac-$(MICRO_FLAC_VERSION).tar.gz
  HASH:=ac2c7a8ef05485b36f50468b056ec93ffb2503632b18b64a8966d0feb1c13337
endef
$(eval $(call Download,micro-flac))

define Download/noise-c
  URL:=https://codeload.github.com/esphome-libs/noise-c/tar.gz/v$(NOISE_C_VERSION)?
  FILE:=noise-c-$(NOISE_C_VERSION).tar.gz
  HASH:=a8ad31c6306150ab3ab24d0337efe82bf54f6404c23eaf42af5d1d2a62e4af01
endef
$(eval $(call Download,noise-c))

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
	$(call Prepare/dependency,noise-c,noise-c-$(NOISE_C_VERSION).tar.gz)
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
	-DFETCHCONTENT_SOURCE_DIR_NOISE_C=$(DEPS_DIR)/noise-c \
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
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/sendspin-cli.defaults $(1)/etc/uci-defaults/50-sendspin-cli
	$(INSTALL_DIR) $(1)/lib/upgrade/keep.d
	$(INSTALL_DATA) ./files/sendspin-cli.upgrade $(1)/lib/upgrade/keep.d/sendspin-cli
endef

$(eval $(call BuildPackage,sendspin-cli))
