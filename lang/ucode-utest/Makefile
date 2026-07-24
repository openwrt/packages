include $(TOPDIR)/rules.mk

PKG_NAME:=ucode-utest
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/m00qek/utest/tar.gz/refs/tags/v$(PKG_VERSION)
PKG_HASH:=b53fed829dd05cc513d18b8c1dae7e0ea3737aa5b68524ed192231bae97fa531
PKG_SOURCE_SUBDIR:=utest-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)

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
