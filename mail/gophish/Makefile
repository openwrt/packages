include $(TOPDIR)/rules.mk

PKG_NAME:=gophish
PKG_VERSION:=0.12.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/gophish/gophish/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=d748b91bcd9ede187002ccaf9e3699ecbff2315aff02d54c0a29debf6fb5fb3e

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/gophish/gophish

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/gophish
  SECTION:=mail
  CATEGORY:=Mail
  TITLE:=Gophish phishing framework
  URL:=https://getgophish.com/
  DEPENDS:=$(GO_ARCH_DEPENDS)
  USERID:=gophish:gophish
endef

define Package/gophish/description
  Gophish is a powerful, open-source phishing framework that makes it easy to test your organization's exposure to phishing. 
endef

define Package/gophish/conffiles
/etc/gophish.json
endef

define Package/gophish/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gophish $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/gophish.init $(1)/etc/init.d/gophish
	$(INSTALL_DIR) $(1)/usr/libexec/gophish
	$(CP) $(PKG_BUILD_DIR)/db/* $(1)/usr/libexec/gophish/
	$(INSTALL_DIR) $(1)/www/gophish
	$(CP) $(PKG_BUILD_DIR)/static $(1)/www/gophish/
	$(CP) $(PKG_BUILD_DIR)/templates $(1)/www/gophish/
	$(INSTALL_CONF) ./files/gophish.json $(1)/etc/
endef

$(eval $(call GoBinPackage,gophish))
$(eval $(call BuildPackage,gophish))
