include $(TOPDIR)/rules.mk

PKG_NAME:=mt5311
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/jimdigriz/mt5311.git
PKG_SOURCE_VERSION:=2cb13045cd82474416e7f454b36f3a07b0de49d7
PKG_MIRROR_HASH:=a1e1e9354fe9b9d6aa5da6b38ff6ef84458761533f9dbc55758dd403868c42ed

PKG_MAINTAINER:=jasle <jasle@riseup.net>
PKG_LICENSE:=AGPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/mt5311
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Utilities for working with Metanoia/Proscend VDSL2 SFP Modems
  URL:=https://github.com/jimdigriz/mt5311
  DEPENDS:=+lua +luaposix +lua-struct
endef

define Package/mt5311/description
	mt5311 is a tool to read status informationen from Metanoia/Proscend 
	VDSL2/Proscend VDSL2 SFP Modems.
endef

define Build/Compile
	echo "Nothing to compile, pure lua package"
endef

define Package/mt5311/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/mt5311
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/ebm-read.lua $(1)/usr/lib/lua/mt5311/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/ebm.lua $(1)/usr/lib/lua/mt5311/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/register.lua $(1)/usr/lib/lua/mt5311/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/register.map $(1)/usr/lib/lua/mt5311/
	$(INSTALL_DATA) ./files/init.lua $(1)/usr/lib/lua/mt5311/

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/ebm-read $(1)/usr/bin/
endef

$(eval $(call BuildPackage,mt5311))

