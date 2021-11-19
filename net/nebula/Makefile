# Copyright 2021 Stan Grishin (stangri@melmac.ca)
# This is free software, licensed under the MIT License.

include $(TOPDIR)/rules.mk

PKG_NAME:=nebula
PKG_VERSION:=1.5.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/slackhq/nebula/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=f67684a8eba6da91de3601afc97567fddd0e198973bba950fcf15cded92cdc50

PKG_MAINTAINER:=Stan Grishin <stangri@melmac.ca>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/slackhq/nebula
GO_PKG_BUILD_PKG:= \
	github.com/slackhq/nebula/cmd/nebula \
	github.com/slackhq/nebula/cmd/nebula-cert
GO_PKG_LDFLAGS_X:=\
	main.Build=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/nebula
  SECTION:=net
  CATEGORY:=Network
  TITLE:=nebula
  URL:=https://github.com/slackhq/nebula
  DEPENDS:=$(GO_ARCH_DEPENDS) +kmod-tun
endef

define Package/nebula-cert
  SECTION:=net
  CATEGORY:=Network
  TITLE:=nebula-cert
  URL:=https://github.com/slackhq/nebula
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/nebula/description
  Nebula is a scalable overlay networking tool with a focus on performance, simplicity
  and security. It lets you seamlessly connect computers anywhere in the world.
endef

define Package/nebula-cert/description
$(call Package/nebula/description)
  This package contains only nebula-cert binary.
endef

define Package/nebula/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/etc/init.d $(1)/usr/sbin $(1)/usr/share/doc/nebula $(1)/lib/upgrade/keep.d 
	$(INSTALL_BIN) ./files/nebula.init $(1)/etc/init.d/nebula
	$(SED) "s|^\(PKG_VERSION\).*|\1='$(PKG_VERSION)-$(PKG_RELEASE)'|" $(1)/etc/init.d/nebula
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/nebula $(1)/usr/sbin/nebula
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/LICENSE $(1)/usr/share/doc/nebula/LICENSE
	$(INSTALL_DATA) ./files/nebula.upgrade $(1)/lib/upgrade/keep.d/nebula
endef

define Package/nebula-cert/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/usr/share/doc/nebula-cert $(1)/lib/upgrade/keep.d
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/nebula-cert $(1)/usr/sbin/nebula-cert
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/LICENSE $(1)/usr/share/doc/nebula-cert/LICENSE
	$(INSTALL_DATA) ./files/nebula.upgrade $(1)/lib/upgrade/keep.d/nebula-cert
endef

$(eval $(call GoBinPackage,nebula))
$(eval $(call BuildPackage,nebula))

$(eval $(call GoBinPackage,nebula-cert))
$(eval $(call BuildPackage,nebula-cert))
