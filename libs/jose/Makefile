#
# Author: Tibor Dudlák
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=jose
PKG_VERSION:=10
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://github.com/latchset/$(PKG_NAME)/releases/download/v$(PKG_VERSION)/
PKG_HASH:=5c9cdcfb535c4d9f781393d7530521c72b1dd81caa9934cab6dd752cc7efcd72

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/libjose
  SECTION:=libs
  TITLE:=Provides a full crypto stack including key generation, signing and encryption.
  DEPENDS:=+zlib +jansson +libopenssl +libpthread
  URL:=https://github.com/latchset/jose
  MAINTAINER:=Tibor Dudlák <tibor.dudlak@gmail.com>
endef

define Package/jose
  SECTION:=utils
  TITLE:=Provides a full crypto stack including key generation, signing and encryption.
  DEPENDS:=+libjose
  URL:=https://github.com/latchset/jose
  MAINTAINER:=Tibor Dudlák <tibor.dudlak@gmail.com>
endef

define Package/jose/description
	jose is a command line utility for performing various tasks on JSON
	Object Signing and Encryption (JOSE) objects. José provides a full
	crypto stack including key generation, signing and encryption.
endef

define Package/libjose/description
	libjose is a library for performing various tasks on JSON
	Object Signing and Encryption (JOSE) objects. José provides a full
	crypto stack including key generation, signing and encryption.
endef

define Build/InstallDev
	$(INSTALL_DIR)	$(1)/usr/lib
	$(INSTALL_DIR)  $(1)/usr/include
	$(INSTALL_DIR)	$(1)/usr/include/$(PKG_NAME)
	$(INSTALL_DIR)	$(1)/usr/lib/pkgconfig
	$(CP)	$(PKG_INSTALL_DIR)/usr/lib/lib$(PKG_NAME).so*	$(1)/usr/lib
	$(CP)	$(PKG_INSTALL_DIR)/usr/include/$(PKG_NAME)/*.h	$(1)/usr/include/$(PKG_NAME)
	$(CP)	$(PKG_BUILD_DIR)/*.pc				$(1)/usr/lib/pkgconfig
endef

define Package/libjose/install
	$(INSTALL_DIR)	$(1)/usr/lib
	$(CP)		$(PKG_INSTALL_DIR)/usr/lib/lib$(PKG_NAME).so*	$(1)/usr/lib/
endef

define Package/jose/install
	$(INSTALL_DIR)  $(1)/usr/bin
	$(INSTALL_BIN)  $(PKG_INSTALL_DIR)/usr/bin/$(PKG_NAME)          $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libjose))
$(eval $(call BuildPackage,jose))
