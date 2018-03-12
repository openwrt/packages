#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=opus-tools
PKG_VERSION:=0.1.10
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://downloads.xiph.org/releases/opus/
PKG_HASH:=a2357532d19471b70666e0e0ec17d514246d8b3cb2eb168f68bb0f6fd372b28c

PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Ted Hess <thess@kitschensync.net>, \
		Nicolas Thill <nico@openwrt.org>

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/opus-tools
  SECTION:=sound
  CATEGORY:=Sound
  DEPENDS:=+libogg +libopus
  TITLE:=OPUS Codec tools
  URL:=http://opus-codec.org/
endef

define Package/opus-tools/description
 This package provides command-line utilities to encode, inspect,
 and decode .opus files.
endef

CONFIGURE_ARGS += \
	--without-flac \

define Package/opus-tools/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/opus{dec,enc,info} $(1)/usr/bin/
endef

$(eval $(call BuildPackage,opus-tools))
