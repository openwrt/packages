#
# Copyright (C) 2011-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Package/php5-pecl/Default
  SUBMENU:=PHP
  SECTION:=lang
  CATEGORY:=Languages
  URL:=http://pecl.php.net/
  MAINTAINER:=Michael Heimpold <mhei@heimpold.de>
  DEPENDS:=php5
endef

define Build/Configure
	( cd $(PKG_BUILD_DIR); $(STAGING_DIR_HOST)/usr/bin/phpize )
	$(Build/Configure/Default)
endef

CONFIGURE_ARGS+= \
	--with-php-config=$(STAGING_DIR_HOST)/usr/bin/php-config

define PECLPackage

  define Package/php5-pecl-$(1)
    $(call Package/php5-pecl/Default)
    TITLE:=$(2)

    ifneq ($(3),)
      DEPENDS+=$(3)
    endif
  endef

  define Package/php5-pecl-$(1)/install
	$(INSTALL_DIR) $$(1)/usr/lib/php
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/modules/$(subst -,_,$(1)).so $$(1)/usr/lib/php/
	$(INSTALL_DIR) $$(1)/etc/php5
    ifeq ($(4),zend)
	echo "zend_extension=/usr/lib/php/$(subst -,_,$(1)).so" > $$(1)/etc/php5/$(subst -,_,$(1)).ini
    else
	echo "extension=$(subst -,_,$(1)).so" > $$(1)/etc/php5/$(subst -,_,$(1)).ini
    endif
  endef

endef
