#
# Copyright (C) 2019 CZ.NIC, z. s. p. o. (https://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=augeas
PKG_VERSION:=1.14.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/hercules-team/augeas/releases/download/release-$(PKG_VERSION)
PKG_HASH:=368bfdd782e4b9c7163baadd621359c82b162734864b667051ff6bcb57b9edff

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec1@gmail.com>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:augeas:augeas

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/augeas
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=A configuration editing tool
  URL:=http://augeas.net
  DEPENDS:=+libxml2 +libreadline +libncurses
endef

define Package/augeas/description
  Augeas is a configuration editing tool.
  It parses configuration files in their
  native formats and transforms them into a tree.
  Configuration changes are made by manipulating this
  tree and saving it back into native config files.
endef

define Package/augeas-lenses
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Augeas lenses
  URL:=http://augeas.net
  DEPENDS:=+augeas
endef

define Package/augeas-lense/description
  Set of Augeas lenses.
endef

CONFIGURE_ARGS+= \
        --without-selinux

define Package/augeas-lenses-tests
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Augeas lenses tests
  URL:=http://augeas.net
  DEPENDS:=+augeas
endef

define Package/augeas-lenses-tests/description
  Set of tests for official Augeas lenses.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/* $(1)/usr/lib/pkgconfig/
endef

define Package/augeas/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
endef

define Package/augeas-lenses/install
	$(INSTALL_DIR) $(1)/usr/share/augeas/lenses/dist
	$(CP) $(PKG_INSTALL_DIR)/usr/share/augeas/lenses/dist/* $(1)/usr/share/augeas/lenses/dist/
endef

define Package/augeas-lenses-tests/install
	$(INSTALL_DIR) $(1)/usr/share/augeas/lenses/dist/tests
	$(CP) $(PKG_INSTALL_DIR)/usr/share/augeas/lenses/dist/tests/* $(1)/usr/share/augeas/lenses/dist/tests
endef

$(eval $(call BuildPackage,augeas))
$(eval $(call BuildPackage,augeas-lenses))
$(eval $(call BuildPackage,augeas-lenses-tests))
