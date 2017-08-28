# 
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=findutils
PKG_VERSION:=4.6.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@GNU/$(PKG_NAME)
PKG_HASH:=ded4c9f73731cd48fec3b6bdaccce896473b6d8e337e9612e16cf1431bb1169d
PKG_MAINTAINER:=Daniel Dickinson <lede@daniel.thecshore.com>

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/findutils/Default
	TITLE:=GNU findutils
	SECTION:=utils
	CATEGORY:=Utilities
endef

define Package/findutils/description/Default
Replace busybox versions of findutils with full GNU versions.
This is normally not needed as busybox is smaller and provides
sufficient functionality, but some users may want or need
the full functionality of the GNU tools.
endef

define Package/findutils-find
	$(call Package/findutils/Default)
	TITLE+= (find)
endef

define Package/findutils-find/description
$(call Package/findutils/description/Default)
This package contains the find utility
endef

define Package/findutils-xargs
	$(call Package/findutils/Default)
	TITLE := (xargs)
endef

define Package/findutils-xargs/description
$(call Package/findutils/description/Default)
This package contains the xargs utility
endef

define Package/findutils-locate
	$(call Package/findutils/Default)
	TITLE := (locate)
endef

define Package/findutils-locate/description
$(call Package/findutils/description/Default)
This package contains the locate and related updatedb utility
endef

CONFIGURE_ARGS += --localstatedir=/srv/var
CONFIGURE_VARS += ac_cv_path_SORT=sort

define Package/findutils-find/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/find $(1)/usr/bin/	
endef

define Package/findutils-xargs/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/xargs $(1)/usr/bin/	
endef

define Package/findutils-locate/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/srv/var
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/locate $(1)/usr/bin/	
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/updatedb $(1)/usr/bin/	
	$(CP) $(PKG_INSTALL_DIR)/usr/lib $(1)/usr/
endef

$(eval $(call BuildPackage,findutils-find))
$(eval $(call BuildPackage,findutils-xargs))
$(eval $(call BuildPackage,findutils-locate))
