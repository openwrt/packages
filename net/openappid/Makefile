#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=openappid
PKG_VERSION:=20220617
URL_CODE:=26425
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.snort.org/downloads/openappid/$(URL_CODE)?
PKG_HASH:=8513877ce2264bb22119d911c2cf11f73735c866e2ca0d061c35eef6740d51f9

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
	$(INSTALL_DIR) $(1)/usr/lib/openappid/custom/{libs,lua,port}
	$(INSTALL_DIR) $(1)/usr/lib/openappid/odp
	$(CP) $(PKG_BUILD_DIR)/lua $(1)/usr/lib/openappid/odp
	$(CP) $(PKG_BUILD_DIR)/libs $(1)/usr/lib/openappid/odp
	$(CP) $(PKG_BUILD_DIR)/port $(1)/usr/lib/openappid/odp
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/appMapping.data $(1)/usr/lib/openappid/odp
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/LICENSE $(1)/usr/lib/openappid/odp
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/README $(1)/usr/lib/openappid/odp
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/appid.conf $(1)/usr/lib/openappid/odp
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/AUTHORS $(1)/usr/lib/openappid/odp
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/version.conf $(1)/usr/lib/openappid/odp
endef

$(eval $(call BuildPackage,openappid))
