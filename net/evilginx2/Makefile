include $(TOPDIR)/rules.mk

PKG_NAME:=evilginx2
PKG_VERSION:=3.2.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/kgretzky/evilginx2/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=1c9f51c447704d0097280b6e743134cf108e8adc654a0ac4343400b5800e77f0

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/kgretzky/evilginx2
GO_PKG_LDFLAGS_X:=$(GO_PKG)/cmd.Version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/evilginx2
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Man-in-the-middle reverse-proxy attack framework
  URL:=https://help.evilginx.com/
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/evilginx/description
  Evilginx is a man-in-the-middle reverse-proxy attack framework that
  is useful for testing your organization's exposure to phishing and
  other similar attacks.
endef

define Package/gophish/conffiles
/etc/evilginx2.json
endef

define Package/evilginx2/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/evilginx2 $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/usr/libexec/evilginx2
	$(CP) $(PKG_BUILD_DIR)/phishlets $(1)/usr/libexec/evilginx2/
	$(CP) $(PKG_BUILD_DIR)/redirectors $(1)/usr/libexec/evilginx2/
endef

$(eval $(call GoBinPackage,evilginx2))
$(eval $(call BuildPackage,evilginx2))
