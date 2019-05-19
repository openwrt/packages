#
# Copyright (C) 2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libcap
PKG_VERSION:=2.27
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@KERNEL/linux/libs/security/linux-privs/libcap2
PKG_HASH:=dac1792d0118bee6aae6ba7fb93ff1602c6a9bda812fd63916eee1435b9c486a

PKG_MAINTAINER:=Paul Wassi <p.wassi@gmx.at>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=License

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

define Package/libcap
  TITLE:=Linux capabilities library
  SECTION:=libs
  CATEGORY:=Libraries
  URL:=https://www.kernel.org/pub/linux/libs/security/linux-privs/libcap2/
endef

define Package/libcap/config
  if PACKAGE_libcap

  config PACKAGE_libcap-bin
    bool "install libcap executables"
    help
      Install capsh, getcap, getpcaps, setcap into the target image.
    default n

  config PACKAGE_libcap-bin-capsh-shell
    string "capsh shell"
    depends on PACKAGE_libcap-bin
    help
      Set the capsh shell.
    default "/bin/sh"

  endif
endef

MAKE_FLAGS += \
    BUILD_CC="$(CC)" \
    BUILD_CFLAGS="$(FPIC) -I$(PKG_BUILD_DIR)/libcap/include" \
    CFLAGS="$(TARGET_CFLAGS)" \
    LD="$(TARGET_CC) -Wl,-x -shared" \
    LDFLAGS="$(TARGET_LDFLAGS)" \
    INDENT="| true" \
    PAM_CAP="no" \
    RAISE_SETFCAP="no" \
    DYNAMIC="yes" \
    lib="lib"

ifneq ($(CONFIG_PACKAGE_libcap-bin-capsh-shell),)
TARGET_CFLAGS += -DSHELL='\"$(CONFIG_PACKAGE_libcap-bin-capsh-shell)\"'
endif

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/sys
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/lib/* $(1)/usr/lib/
endef

define Package/libcap/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libcap.so* $(1)/usr/lib/
ifneq ($(CONFIG_PACKAGE_libcap-bin),)
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/sbin/capsh     $(1)/usr/sbin/
	$(CP) $(PKG_INSTALL_DIR)/sbin/getcap    $(1)/usr/sbin/
	$(CP) $(PKG_INSTALL_DIR)/sbin/getpcaps  $(1)/usr/sbin/
	$(CP) $(PKG_INSTALL_DIR)/sbin/setcap    $(1)/usr/sbin/
endif
endef

$(eval $(call BuildPackage,libcap))
