#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bandwidthd-php
PKG_VERSION:=2.0.1
PKG_RELEASE:=2

PKG_MAINTAINER:=Jean-Michel Lacroix <lacroix@lepine-lacroix.info>

PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define Package/bandwidthd-php
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libpcre +libxml2 +php7 +php7-cgi +php7-mod-pgsql +php7-mod-gd
  TITLE:=PHP files to graph bandwidthd data in a postgresql database
  URL:=http://bandwidthd.sourceforge.net/
endef

define Package/bandwidthd-php/description
  PHP files to graph bandwidthd data in a postgresql database
endef

define Build/Compile
endef

define Package/bandwidthd-php/install
	$(INSTALL_DIR) $(1)/www/phphtdocs
	$(INSTALL_DATA) ./files/legend.gif $(1)/www/phphtdocs/
	$(INSTALL_DATA) ./files/logo.gif $(1)/www/phphtdocs/
	$(INSTALL_DATA) ./files/details.php $(1)/www/phphtdocs/
	$(INSTALL_DATA) ./files/footer.php $(1)/www/phphtdocs/
	$(INSTALL_DATA) ./files/graph.php $(1)/www/phphtdocs/
	$(INSTALL_DATA) ./files/include.php $(1)/www/phphtdocs/
	$(INSTALL_DATA) ./files/index.php $(1)/www/phphtdocs/
	ln -s /var/etc/bandwidthd-php.conf $(1)/www/phphtdocs/config.conf
	$(INSTALL_DIR) $(1)//etc/config
	$(INSTALL_CONF) ./files/bandwidthd-php.config $(1)/etc/config/bandwidthd-php
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/bandwidthd-php.init $(1)/etc/init.d/bandwidthd-php
endef

$(eval $(call BuildPackage,bandwidthd-php))
