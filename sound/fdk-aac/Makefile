#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=fdk-aac
PKG_VERSION:=0.1.6
PKG_RELEASE:=1
PKG_MAINTAINER:=Ted Hess <thess@kitschensync.net>
PKG_LICENSE:=Fraunhofer-FDK-AAC-for-Android
PKG_LICENSE_FILES:=NOTICE


PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/mstorsjo/fdk-aac/
PKG_SOURCE_SUBDIR=:$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=a30bfced6b6d6d976c728552d247cb30dd86e238
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_MIRROR_HASH:=8589905a946c19cb1ce4b29d08f60bb927818e92033ba90e5ab49f63351bee26

PKG_FIXUP:=autoreconf

PKG_CONFIG_DEPENDS:= CONFIG_FDK-AAC_OPTIMIZE_SPEED

ifeq ($(CONFIG_FDK-AAC_OPTIMIZE_SPEED),y)
	TARGET_CFLAGS := $(filter-out -O%,$(TARGET_CFLAGS))
	TARGET_CFLAGS += $(TARGET_CFLAGS) -O2 -flto
	TARGET_CXXFLAGS := $(filter-out -O%,$(TARGET_CXXFLAGS))
	TARGET_CXXFLAGS += $(TARGET_CXXFLAGS) -O2 -flto
	TARGET_LDFLAGS += $(TARGET_LDFLAGS) -flto
endif

include $(INCLUDE_DIR)/package.mk

define Package/fdk-aac
  SECTION:=sound
  CATEGORY:=Sound
  TITLE:=Fraunhofer FDK AAC Codec Library
  URL:=https://sourceforge.net/projects/opencore-amr/
endef

define Package/fdk-aac/description
  Port of the Fraunhofer FDK AAC Codec Library for Android
endef

define Package/fdk-aac/config
	source "$(SOURCE)/Config.in"
endef

define Package/fdk-aac/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/.libs/*.so* $(1)/usr/lib/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/fdk-aac
	$(CP) $(PKG_BUILD_DIR)/libAACdec/include/aacdecoder_lib.h $(1)/usr/include/fdk-aac
	$(CP) $(PKG_BUILD_DIR)/libAACenc/include/aacenc_lib.h $(1)/usr/include/fdk-aac
	$(CP) $(PKG_BUILD_DIR)/libSYS/include/FDK_audio.h $(1)/usr/include/fdk-aac
	$(CP) $(PKG_BUILD_DIR)/libSYS/include/genericStds.h $(1)/usr/include/fdk-aac
	$(CP) $(PKG_BUILD_DIR)/libSYS/include/machine_type.h $(1)/usr/include/fdk-aac
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/.libs/*.{la,so*} $(1)/usr/lib/
endef

$(eval $(call BuildPackage,fdk-aac))
