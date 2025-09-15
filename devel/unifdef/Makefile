include $(TOPDIR)/rules.mk

PKG_NAME:=unifdef
PKG_VERSION:=2.12
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://dotat.at/prog/$(PKG_NAME)
PKG_HASH:=fba564a24db7b97ebe9329713ac970627b902e5e9e8b14e19e024eb6e278d10b

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=BSD-2-clause

PKG_HOST_ONLY:=1
HOST_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

HOST_CFLAGS += -std=gnu17
TARGET_CFLAGS += -std=gnu17

define Package/unifdef
  SECTION:=devel
  CATEGORY:=Development
  TITLE:=selectively remove C preprocessor conditionals
  URL:=https://dotat.at/prog/unifdef
  BUILDONLY:=1
endef

define Package/unifdef/description
 The unifdef utility selectively processes conditional C preprocessor #if and
 #ifdef directives. It removes from a file both the directives and the
 additional text that they delimit, while otherwise leaving the file alone.
endef

define Host/Install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/unifdef $(1)/bin
endef

define Host/Uninstall
	$(RM) $(1)/bin/unifdef
endef

define Package/unifdef/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/unifdef $(1)/usr/bin/
endef

$(eval $(call BuildPackage,unifdef))
$(eval $(call HostBuild))
