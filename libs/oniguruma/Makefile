# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=oniguruma
PKG_VERSION:=6.9.5_rev1
PKG_RELEASE:=3

PKG_SOURCE:=onig-v$(subst _,-,$(PKG_VERSION)).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/kkos/oniguruma/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=e0c2212102fa4146c43b6c4f2f7727a84fd055cc2109c293d64298cef0c372b5

PKG_MAINTAINER:=Eneas U de Queiroz <cotequeiroz@gmail.com>
PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:oniguruma_project:oniguruma

PKG_INSTALL:=1
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += --enable-posix-api

define Package/oniguruma
    SECTION:=libs
    CATEGORY:=Libraries
    TITLE:=Regular expression library for different character encodings
    URL:=https://github.com/kkos/oniguruma
    ABI_VERSION:=5
endef

define Package/oniguruma/description
   Oniguruma is a modern and flexible regular expressions library.
   It encompasses features from different regular expression implementations that
   traditionally exist in different languages.

   Character encoding can be specified per regular expression object.
endef

define Package/oniguruma/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libonig.so.$(ABI_VERSION) $(1)/usr/lib/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/{include,lib}
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
	$(SED) 's,/usr,$(STAGING_DIR)/usr,g' $(1)/usr/lib/pkgconfig/oniguruma.pc
endef

$(eval $(call BuildPackage,oniguruma))
