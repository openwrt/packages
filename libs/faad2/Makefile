#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=faad2
PKG_VERSION:=2.8.0~cvs20161113
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)_$(PKG_VERSION).orig.tar.xz
PKG_SOURCE_URL:=http://ftp.debian.org/debian/pool/main/f/$(PKG_NAME)
PKG_HASH:=de34bce327eac8a89cd58b7d44dfb58988033de6fda0ab9582ed0585fc3fd07e
PKG_MAINTAINER:=Ted Hess <thess@kitschensync.net>

PKG_CONFIG_DEPENDS := \
	CONFIG_SOFT_FLOAT \
	CONFIG_FAAD2_ALWAYS_USE_FLOATING_POINT

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/faad2/Default
  URL:=http://www.audiocoding.com/faad2.html
  TITLE:=Freeware Advanced Audio Decoder
endef

define Package/faad2/Default/description
	FAAD2 is the fastest ISO AAC audio decoder available.
	FAAD2 correctly decodes all MPEG-4 and MPEG-2 MAIN,
	LOW, LTP, LD and ER object type AAC files.
endef

define Package/faad2
$(call Package/faad2/Default)
  SECTION:=sound
  CATEGORY:=Sound
  TITLE+=player
  DEPENDS:=+libfaad2
endef

define Package/faad2/description
$(call Package/faad2/Default/description)
  This package contains a binary to play AAC or MP4 files.
endef

define Package/libfaad2
$(call Package/faad2/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE+=library
  DEPENDS:=@BUILD_PATENTED
  MENU:=1
endef

define Package/libfaad2/config
	source "$(SOURCE)/Config.in"
endef

define Package/libfaad2/description
$(call Package/faad2/Default/description)
  This package contains the library.
endef

TARGET_CFLAGS += $(FPIC)
CONFIGURE_ARGS+= --without-xmms

# Use fixed point math, if we're using soft floats, and the user didn't
# specifically ask to use floats anyways.
#ifeq ($(CONFIG_SOFT_FLOAT)-$(CONFIG_FAAD2_ALWAYS_USE_FLOATING_POINT),y-)
TARGET_CFLAGS+= -DFIXED_POINT
CONFIGURE_ARGS+= -nfp
#endif

CONFIGURE_VARS+= CPPFLAGS="-fno-builtin-cos -fno-builtin-sin -fno-builtin-log"

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/*.h $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libfaad.{a,so*} $(1)/usr/lib/
endef

define Package/faad2/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/faad $(1)/usr/bin/
endef

define Package/libfaad2/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libfaad.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,faad2))
$(eval $(call BuildPackage,libfaad2))
