include $(TOPDIR)/rules.mk

PKG_NAME:=ucode-utest
PKG_VERSION:=0.9.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@GITHUB/m00qek/utest/v$(PKG_VERSION)
PKG_HASH:=7c750dd3006c6b85886eb559842e5b5c5487f22b679ddced9d893f18eafc2bf9

PKG_MAINTAINER:=António Mora <m00qek@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=devel
  CATEGORY:=Development
  TITLE:=Unit testing framework for ucode
  URL:=https://github.com/m00qek/utest
  DEPENDS:=+ucode
  PKGARCH:=all
endef

define Package/$(PKG_NAME)/description
  A modern, non-invasive testing framework for the ucode ecosystem.
  Provides a describe/it DSL, built-in mock proxies for uci, ubus, fs,
  uloop, and uclient, and both sequential and parallel test runners.
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./src/utest.sh $(1)/usr/bin/utest

	$(INSTALL_DIR) $(1)/usr/share/ucode
	$(CP) ./src/utest.uc $(1)/usr/share/ucode/
	$(CP) -r ./src/utest $(1)/usr/share/ucode/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
