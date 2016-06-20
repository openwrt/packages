#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bandwidthd-php
PKG_VERSION:=2.0.1
PKG_RELEASE:=1

PKG_MAINTAINER:=Jean-Michel Lacroix <lacroix@lepine-lacroix.info>

PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define Package/bandwidthd-php
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=PHP files to use with the bandwidthd-pgsql package
  URL:=http://bandwidthd.sourceforge.net/
endef

define Package/bandwidthd-php/description
  Php files to use with the bandwidthd-pgsql package.
endef

define Build/Compile
endef

define Package/bandwidthd-php/install
	$(INSTALL_DIR) $(1)/www/phphtdocs
	$(INSTALL_DATA) ./files/legend.gif $(1)/www/phphtdocs/
	$(INSTALL_DATA) ./files/logo.gif $(1)/www/phphtdocs/
	$(INSTALL_DATA) ./files/config.conf $(1)/www/phphtdocs/
	$(INSTALL_DATA) ./files/details.php $(1)/www/phphtdocs/
	$(INSTALL_DATA) ./files/footer.php $(1)/www/phphtdocs/
	$(INSTALL_DATA) ./files/graph.php $(1)/www/phphtdocs/
	$(INSTALL_DATA) ./files/include.php $(1)/www/phphtdocs/
	$(INSTALL_DATA) ./files/index.php $(1)/www/phphtdocs/
endef

$(eval $(call BuildPackage,bandwidthd-php))
