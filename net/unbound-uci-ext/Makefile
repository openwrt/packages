include $(TOPDIR)/rules.mk

PKG_NAME:=unbound-uci-ext
PKG_VERSION:=0.2.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/openwrt-iac/unbound-uci-ext/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=741a0362817cd8874f8d53e745fde664f92c64e1b5bc57a48cd27b2efee06d26

PKG_MAINTAINER:=Guy Godfroy <guy.godfroy@gugod.fr>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/unbound-uci-ext
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=UCI options for unbound's extended config files
  URL:=https://github.com/openwrt-iac/unbound-uci-ext
  PKGARCH:=all
  DEPENDS:=+unbound-daemon
endef

define Package/unbound-uci-ext/description
  UCI options for the unbound directives that the unbound package
  leaves out of UCI. /etc/config/unbound_srv renders lines of the
  server: clause into /etc/unbound/unbound_srv.conf, and
  /etc/config/unbound_ext renders other clauses, such as forward-zone:,
  into /etc/unbound/unbound_ext.conf. Only a marked region of each file
  changes.
endef

define Package/unbound-uci-ext/conffiles
/etc/config/unbound_ext
/etc/config/unbound_srv
endef

Build/Compile=

define Package/unbound-uci-ext/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/unbound_ext.config $(1)/etc/config/unbound_ext
	$(INSTALL_CONF) ./files/unbound_srv.config $(1)/etc/config/unbound_srv

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/unbound-uci-ext.init $(1)/etc/init.d/unbound-uci-ext

	$(INSTALL_DIR) $(1)/usr/lib/unbound-uci-ext
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/usr/lib/unbound-uci-ext/generator.sh \
		$(1)/usr/lib/unbound-uci-ext/
endef

$(eval $(call BuildPackage,unbound-uci-ext))
