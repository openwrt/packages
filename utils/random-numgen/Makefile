# This is free software, licensed under the GNU General Public License v3.
# See /LICENSES for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=random-numgen
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_MAINTAINER:=Ilario Gelmetti <ilario@sindominio.net>
PKG_LICENSE:=GPL-3.0-or-later

include $(INCLUDE_DIR)/package.mk

define Package/random-numgen
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Generates a random number 0-65535
endef

define Package/random-numgen/description
  Offers an alternative to the RANDOM shell variable,
  generating a pseudo-random integer number from 0 to
  65535 using /dev/urandom as a random data source.
endef

define Build/Compile
endef

define Build/Configure
endef

define Package/random-numgen/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/random-numgen $(1)/usr/bin/
endef

$(eval $(call BuildPackage,random-numgen))
