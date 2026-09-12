include $(TOPDIR)/rules.mk

PKG_NAME:=maddy
PKG_VERSION:=0.9.5
PKG_RELEASE:=1
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE:=$(PKG_NAME)-v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/foxcpp/maddy/tar.gz/v${PKG_VERSION}?
PKG_HASH:=c5670ff64930a4d69053557cdf252527b54c32bff882c33d120bd208f34a6e19

PKG_MAINTAINER:=Romain Isnel <ri@frmg.eu>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/foxcpp/maddy
GO_PKG_BUILD_PKG:=github.com/foxcpp/maddy/cmd/maddy
GO_PKG_LDFLAGS_X:=$(GO_PKG).Version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/maddy
  SECTION:=mail
  CATEGORY:=Mail
  TITLE:=Composable all-in-one mail server
  URL:=https://github.com/foxcpp/maddy
  USERID:=maddy:maddy
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
endef

define Package/maddy/conffiles
/etc/maddy/maddy.conf
/etc/config/maddy
endef

define Package/maddy/description
  Maddy Mail Server implements all functionality required to run an e-mail server.
  It can send messages via SMTP (works as MTA), accept messages via SMTP (works as MX)
  and store messages while providing access to them via IMAP. In addition to that it
  implements auxiliary protocols that are mandatory to keep email reasonably secure
  (DKIM, SPF, DMARC, DANE, MTA-STS).
endef

define Package/maddy/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/maddy $(1)/usr/bin/maddy

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) $(CURDIR)/files/maddy.init $(1)/etc/init.d/maddy

	$(INSTALL_DIR) $(1)/etc/maddy/
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/maddy.conf $(1)/etc/maddy/maddy.conf

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(CURDIR)/files/maddy.uci $(1)/etc/config/maddy

	$(INSTALL_DIR) $(1)/etc/capabilities/
	$(INSTALL_DATA) $(CURDIR)/files/maddy.json $(1)/etc/capabilities/maddy.json
endef

$(eval $(call GoBinPackage,maddy))
$(eval $(call BuildPackage,maddy))
