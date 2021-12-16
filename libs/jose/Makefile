#
# Author: Tibor Dudlák
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=jose
PKG_VERSION:=11
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/latchset/$(PKG_NAME)/releases/download/v$(PKG_VERSION)/
PKG_HASH:=e272afe7717e22790c383f3164480627a567c714ccb80c1ee96f62c9929d8225

PKG_MAINTAINER:=Tibor Dudlák <tibor.dudlak@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_DEPENDS:=openssl

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk

define Package/jose
  SECTION:=utils
  TITLE:=Provides a full crypto stack including key generation, signing and encryption.
  DEPENDS:=+jansson
  URL:=https://github.com/latchset/jose
endef

define Package/jose/description
	jose is a command line utility for performing various tasks on JSON
	Object Signing and Encryption (JOSE) objects. José provides a full
	crypto stack including key generation, signing and encryption.
endef

MESON_ARGS += \
	-Ddefault_library=static

define Build/InstallDev
	$(INSTALL_DIR)	$(1)/usr/lib
	$(INSTALL_DIR)  $(1)/usr/include
	$(INSTALL_DIR)	$(1)/usr/include/$(PKG_NAME)
	$(INSTALL_DIR)	$(1)/usr/lib/pkgconfig
	$(CP)	$(PKG_INSTALL_DIR)/usr/lib/lib$(PKG_NAME).a	$(1)/usr/lib
	$(CP)	$(PKG_INSTALL_DIR)/usr/include/$(PKG_NAME)/*.h	$(1)/usr/include/$(PKG_NAME)
	$(CP)	$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/*.pc	$(1)/usr/lib/pkgconfig
endef

define Package/jose/install
	$(INSTALL_DIR)  $(1)/usr/bin
	$(INSTALL_BIN)  $(PKG_INSTALL_DIR)/usr/bin/$(PKG_NAME)          $(1)/usr/bin/
endef

$(eval $(call BuildPackage,jose))
