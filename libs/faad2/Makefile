#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=faad2
PKG_VERSION:=2.8.8
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/faac/faad2-src/$(PKG_NAME)-2.8.0
PKG_HASH:=985c3fadb9789d2815e50f4ff714511c79c2710ac27a4aaaf5c0c2662141426d
PKG_MAINTAINER:=Ted Hess <thess@kitschensync.net>
PKG_CPE_ID:=cpe:/a:audiocoding:faad2

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
  MENU:=1
endef

define Package/libfaad2/description
$(call Package/faad2/Default/description)
  This package contains the library.
endef

TARGET_CFLAGS += $(FPIC)
CONFIGURE_ARGS+= --without-xmms

ifeq ($(CONFIG_SOFT_FLOAT),y)
	TARGET_CFLAGS+= -DFIXED_POINT
	CONFIGURE_ARGS+= -nfp
endif

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
