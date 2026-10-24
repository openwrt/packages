include $(TOPDIR)/rules.mk

PKG_NAME:=mt5311d
PKG_VERSION:=0.2.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/jasle/$(PKG_NAME)/tar.gz/$(PKG_VERSION)?
PKG_HASH:=cbcbf418c891a45dbfc2ab2309f57dfcf8a5f59f119b7c4db8e16348fa871dcf

PKG_MAINTAINER:=Jakob Schade <jasle@riseup.net>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/mt5311d
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Line status of Metanoia MT5311 VDSL2 SFP modems on ubus
  DEPENDS:=+ucode +ucode-mod-fs +ucode-mod-log +ucode-mod-socket \
    +ucode-mod-struct +ucode-mod-ubus +ucode-mod-uci +ucode-mod-uloop
  PKGARCH:=all
endef

define Package/mt5311d/description
  Provides the line status of a Metanoia MT5311 VDSL2 SFP modem as ubus
  object "dsl" in the format of the Lantiq DSL daemon.
endef

define Package/mt5311d/conffiles
/etc/config/mt5311d
endef

define Build/Compile
endef

define Package/mt5311d/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/usr/share/ucode/mt5311d $(1)/etc/init.d $(1)/etc/config
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/mt5311d.uc $(1)/usr/sbin/mt5311d
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/mt5311d/*.uc $(1)/usr/share/ucode/mt5311d/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/mt5311d.init $(1)/etc/init.d/mt5311d
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/files/mt5311d.config $(1)/etc/config/mt5311d
endef

$(eval $(call BuildPackage,mt5311d))
