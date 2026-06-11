# Copyright 2024 MOSSDeF, Stan Grishin (stangri@melmac.ca).
# This is free software, licensed under the GPL-3.0 License.

include $(TOPDIR)/rules.mk

PKG_NAME:=sunwait
PKG_VERSION:=0.9.1
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/risacher/sunwait/tar.gz/$(PKG_VERSION)?
PKG_HASH:=02fe8165a60ede67f1d0dc98acf4dfbe40865a215d9bd039f57806f1e100b406

PKG_MAINTAINER:=Stan Grishin <stangri@melmac.ca>
PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/sunwait
	SUBMENU:=Utilities
	CATEGORY:=Utilities
	SECTION:=util
	TITLE:=Sunwait
	URL:=https://github.com/risacher/sunwait
	DEPENDS:=+libc
endef

define Package/sunwait/description
	Calculate sunrise and sunset, as well as civil, nautical, and astronomical twilights. 
	Has features that make it useful for home automation tasks.
endef

define Package/sunwait/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sunwait $(1)/usr/bin/sunwait
endef

$(eval $(call BuildPackage,sunwait))
