#
# Copyright (C) 2017 Shane Peelar
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pcre2
PKG_VERSION:=10.35
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=@SF/pcre/$(PKG_NAME)/$(PKG_VERSION)
PKG_HASH:=9ccba8e02b0ce78046cdfb52e5c177f0f445e421059e43becca4359c669d4613

PKG_MAINTAINER:=Shane Peelar <lookatyouhacker@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENCE
PKG_CPE_ID:=cpe:/a:pcre:pcre

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

PKG_CONFIG_DEPENDS:=\
	CONFIG_PCRE2_JIT_ENABLED

include $(INCLUDE_DIR)/package.mk

define Package/libpcre2/default
  SECTION:=libs
  CATEGORY:=Libraries
  URL:=https://www.pcre.org/
endef

define Package/libpcre2/config
  source "$(SOURCE)/Config.in"
endef

define Package/libpcre2
  $(call Package/libpcre2/default)
  TITLE:=A Perl Compatible Regular Expression library
endef

define Package/libpcre2-16
  $(call Package/libpcre2/default)
  TITLE:=A Perl Compatible Regular Expression library (16bit support)
endef


define Package/libpcre2-32
  $(call Package/libpcre2/default)
  TITLE:=A Perl Compatible Regular Expression library (32bit support)
endef

TARGET_CFLAGS += $(FPIC)

CONFIGURE_ARGS += \
	--enable-pcre2-16 \
	--enable-pcre2-32 \
	$(if $(CONFIG_PCRE2_JIT_ENABLED),--enable-jit,--disable-jit)

MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS)"

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/pcre2-config $(1)/usr/bin/

	$(INSTALL_DIR) $(2)/bin
	$(LN) $(STAGING_DIR)/usr/bin/pcre2-config $(2)/bin

	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/pcre*.h $(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpcre*.{a,so*} $(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libpcre*.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libpcre2/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpcre2-{8,posix}.so* $(1)/usr/lib/
endef

define Package/libpcre2-16/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpcre2-16.so* $(1)/usr/lib/
endef

define Package/libpcre2-32/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpcre2-32.so* $(1)/usr/lib/
endef



$(eval $(call BuildPackage,libpcre2))
$(eval $(call BuildPackage,libpcre2-16))
$(eval $(call BuildPackage,libpcre2-32))
