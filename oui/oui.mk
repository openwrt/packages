#
# Copyright (C) 2022 Jianhui Zhao <zhaojh329@gmail.com>
#
# This is free software, licensed under the MIT.
#

include ${CURDIR}/../../version.mk

PKG_NAME:=$(notdir ${CURDIR})
PKG_VERSION:=$(strip $(call findrev))
PKG_RELEASE?=1

ifeq ($(CONFIG_OUI_USE_HOST_NODE),)
NPM:=$(STAGING_DIR_HOSTPKG)/bin/npm
endif

NPM?=npm

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=oui
  CATEGORY:=Oui
  SUBMENU:=Applications
  TITLE:=$(APP_TITLE)
  DEPENDS:=+oui-ui-core $(APP_DEPENDS)
  PKGARCH:=all
endef

define Build/Prepare
	$(CP) ./htdoc $(PKG_BUILD_DIR)
	echo "VITE_APP_NAME=$(APP_NAME)" > $(PKG_BUILD_DIR)/htdoc/.env.local
	$(NPM) --prefix $(PKG_BUILD_DIR)/htdoc install
endef

define Build/Compile
	$(NPM) --prefix $(PKG_BUILD_DIR)/htdoc run build
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/www/views
	$(CP) $(PKG_BUILD_DIR)//htdoc/dist/* $(1)/www/views
	if [ -f ./files/menu.json ]; then \
		$(INSTALL_DIR) $(1)/usr/share/oui/menu.d; \
		$(INSTALL_CONF) ./files/menu.json $(1)/usr/share/oui/menu.d/$(APP_NAME).json; \
	fi
	if [ -d ./files/rpc ]; then \
		$(CP) ./files/rpc $(1)/usr/share/oui/rpc; \
	fi
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
