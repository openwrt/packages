#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=v4l-utils
PKG_VERSION:=1.26.1
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://www.linuxtv.org/downloads/v4l-utils
PKG_HASH:=4a71608c0ef7df2931176989e6d32b445c0bdc1030a2376d929c8ca6e550ec4e

PKG_MAINTAINER:=Ted Hess <thess@kitschensync.net>

PKG_BUILD_FLAGS:=no-mips16

PKG_BUILD_DEPENDS:=!USE_GLIBC:argp-standalone
PKG_CONFIG_DEPENDS:= \
	CONFIG_BUILD_NLS \
	CONFIG_PACKAGE_v4l-utils

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk
include $(INCLUDE_DIR)/nls.mk

define Package/libv4l/Default
  TITLE:=Video 4 Linux
  URL:=https://www.linuxtv.org/
endef

define Package/libv4l/Default/description
  libv4l is a collection of libraries which adds a thin abstraction layer on
  top of video4linux2 devices. The purpose of this (thin) layer is to make it
  easy for application writers to support a wide variety of devices without
  having to write separate code for different devices in the same class. libv4l
  consists of 3 different libraries: libv4lconvert, libv4l1 and libv4l2.

  libv4l1 offers the (deprecated) v4l1 API on top of v4l2 devices, independent
  of the drivers for those devices supporting v4l1 compatibility (which many
  v4l2 drivers do not).

  libv4l2 offers the v4l2 API on top of v4l2 devices, while adding for the
  application transparent libv4lconvert conversion where necessary.
endef

define Package/libv4l
  $(call Package/libv4l/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE+= wrapper libraries
  DEPENDS:=$(ICONV_DEPENDS)
  LICENSE:=LGPL-2.1-or-later
  LICENSE_FILES:=COPYING.libv4l
endef

define Package/libv4l/description
  $(call Package/libv4l/Default/description)
endef

define Package/v4l-utils
  $(call Package/libv4l/Default)
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE+= utilities
  DEPENDS:=+libudev +libv4l +libstdcpp $(ICONV_DEPENDS) $(INTL_DEPENDS)
  LICENSE:=GPL-2.0-or-later
  LICENSE_FILES:=COPYING
endef

define Package/v4l-utils/description
  $(call Package/libv4l/Default/description)
  This package contains the video4linux utilities.
endef

MESON_ARGS += \
	-Db_lto=true \
	-Ddefault_library=both \
	-Dbpf=disabled \
	-Dgconv=disabled \
	-Djpeg=disabled \
	-Dlibdvbv5=disabled \
	-Dqv4l2=disabled \
	-Dqvidcap=disabled \
	-Dv4l-utils=$(if $(CONFIG_PACKAGE_v4l-utils),true,false) \
	-Ddoxygen-doc=disabled

TARGET_LDFLAGS += -Wl,--gc-sections

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/*.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libv4l{1,2,convert,2rds}.{a,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libv4l{1,2,convert,2rds}.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libv4l/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libv4l{1,2,convert,2rds}.so.* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/libv4l
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libv4l/v4l{1compat,2convert}.so $(1)/usr/lib/libv4l/
endef

define Package/v4l-utils/install
	$(INSTALL_DIR) $(1)/etc
	$(CP) $(PKG_INSTALL_DIR)/etc/rc_maps.cfg $(1)/etc/
	$(CP) $(PKG_INSTALL_DIR)/etc/rc_keymaps $(1)/etc/
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/{rds,media,cx18,ivtv}-ctl $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/decode_tm6000 $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/ir-{ctl,keytable} $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/v4l2-{compliance,ctl,sysfs-path} $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/cec-{compliance,ctl,follower} $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libv4l))
$(eval $(call BuildPackage,v4l-utils))
