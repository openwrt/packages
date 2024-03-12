#
# Copyright (C) 2024 Dengfeng Liu <liudf0716@gmail.com>
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=whispercpp
PKG_VERSION:=1.5.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/ggerganov/whisper.cpp/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=06eed84de310fdf5408527e41e863ac3b80b8603576ba0521177464b1b341a3a
PKG_BUILD_DIR:=$(BUILD_DIR)/whisper.cpp-$(PKG_VERSION)

PKG_MAINTAINER:=Dengfeng Liu <liudf0716@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/whispercpp
  SECTION:=multimedia
  CATEGORY:=Multimedia
  DEPENDS:=@(aarch64||i386||x86_64) +libstdcpp +ffmpeg
  TITLE:=Port of OpenAI's Whisper model in C/C++
  URL:=https://github.com/ggerganov/whisper.cpp
endef

define Package/whispercpp/description
 Whisper is a general-purpose speech recognition model.
 Whispercpp is a	port of OpenAI's Whisper model in C/C++.
endef

define Package/whispercpp/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/main $(1)/usr/bin/whispercpp
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libwhisper.so $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/share/whispercpp/model
	$(CP) ./files/ggml-tiny.en-q5_0.bin $(1)/usr/share/whispercpp/model/
endef

$(eval $(call BuildPackage,whispercpp))
