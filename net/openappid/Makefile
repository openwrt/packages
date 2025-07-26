#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=openappid
PKG_VERSION:=20230609
URL_CODE:=33380
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.snort.org/downloads/openappid/$(URL_CODE)?
PKG_HASH:=3046c5af1dd81a104f13d8e895226ef64bca7fa358238fb5f29c659081eaee2a

PKG_MAINTAINER:=John Audia <thereadgraysky@proton.me>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
TAR_OPTIONS+= --strip-components 1
TAR_CMD=$(HOST_TAR) -C $(1) $(TAR_OPTIONS)

define Package/openappid
  SUBMENU:=Firewall
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+snort3
  TITLE:=Detection language and processing module for Snort
  URL:=https://www.snort.org/
endef

define Package/openappid/description
  OpenAppId is an open, application-focused detection language and processing
  module for Snort that enables users to create, share, and implement
  application and service detection.
endef

define Build/Compile
  true
endef

define Package/openappid/install
	$(INSTALL_DIR) $(1)/usr/lib/openappid/odp
	$(CP) $(PKG_BUILD_DIR)/lua $(1)/usr/lib/openappid/odp
	$(CP) $(PKG_BUILD_DIR)/libs $(1)/usr/lib/openappid/odp
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/appMapping.data $(1)/usr/lib/openappid/odp
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/LICENSE $(1)/usr/lib/openappid/odp
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/README $(1)/usr/lib/openappid/odp
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/appid.conf $(1)/usr/lib/openappid/odp
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/AUTHORS $(1)/usr/lib/openappid/odp
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/version.conf $(1)/usr/lib/openappid/odp
endef

$(eval $(call BuildPackage,openappid))
