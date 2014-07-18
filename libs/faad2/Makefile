#
# Copyright (C) 2008-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=faad2
PKG_VERSION:=2.7
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=@SF/faac
PKG_MD5SUM:=4c332fa23febc0e4648064685a3d4332
PKG_MAINTAINER:=Ted Hess <thess@kitschensync.net>

PKG_CONFIG_DEPENDS := \
	CONFIG_SOFT_FLOAT \
	CONFIG_FAAD2_ALWAYS_USE_FLOATING_POINT

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

TARGET_CFLAGS += $(FPIC)

# Use fixed point math, if we're using soft floats, and the user didn't
# specifically ask to use floats anyways.
ifeq ($(CONFIG_SOFT_FLOAT)-$(CONFIG_FAAD2_ALWAYS_USE_FLOATING_POINT),y-)
TARGET_CFLAGS+= -DFIXED_POINT
FAAD2_CONFIG_OPTS= --without-fp -nfp
endif

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

define Build/Configure
	# This replacement were do according to many comments on the web because of gcc 3.4.5 version (.6 included).-
	# wich doesn't recognices the -iquote parameter to AM_CFLAGS
	($(SED) 's,-iquote $$$$(top_srcdir),-I$$$$(top_srcdir),g' $(PKG_BUILD_DIR)/libfaad/Makefile.am; \
	$(SED) 's,-iquote $$$$(top_srcdir),-I$$$$(top_srcdir),g' $(PKG_BUILD_DIR)/libfaad/Makefile.in);
	(cd $(PKG_BUILD_DIR); rm -rf config.{cache,status}; \
		autoreconf -vif \
	);
	$(call Build/Configure/Default, \
		--with-mp4v2 \
		$(FAAD2_CONFIG_OPTS) \
		--without-xmms \
		, \
		FAAD2_CPPFLAGS="-fno-builtin-cos -fno-builtin-sin -fno-builtin-log" \
	)
endef

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
