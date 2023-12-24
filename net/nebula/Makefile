# Copyright 2021-2023 Stan Grishin (stangri@melmac.ca)
# This is free software, licensed under the MIT License.

include $(TOPDIR)/rules.mk

PKG_NAME:=nebula
PKG_VERSION:=1.8.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/slackhq/nebula/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=85c048b6d39296eeb8cf2d3324124d834011121383d0550662018190494d433e

PKG_MAINTAINER:=Stan Grishin <stangri@melmac.ca>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

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
  URL:=https://docs.openwrt.melmac.net/nebula/
  DEPENDS:=$(GO_ARCH_DEPENDS) +kmod-tun
endef

define Package/nebula-cert
  SECTION:=net
  CATEGORY:=Network
  TITLE:=nebula-cert
  URL:=https://docs.openwrt.melmac.net/nebula/
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/nebula-proto
  SECTION:=net
  CATEGORY:=Network
  TITLE:=nebula-proto
  URL:=https://docs.openwrt.melmac.net/nebula/
  DEPENDS:=nebula
	DEPENDS+=+!BUSYBOX_DEFAULT_AWK:gawk
	DEPENDS+=+!BUSYBOX_DEFAULT_GREP:grep
	DEPENDS+=+!BUSYBOX_DEFAULT_SED:sed
  PKGARCH:=all
endef

define Package/nebula-service
  SECTION:=net
  CATEGORY:=Network
  TITLE:=nebula-service
  URL:=https://docs.openwrt.melmac.net/nebula/
  DEPENDS:=nebula
	DEPENDS+=+!BUSYBOX_DEFAULT_AWK:gawk
	DEPENDS+=+!BUSYBOX_DEFAULT_SED:sed
	CONFLICTS:=nebula-proto
  PKGARCH:=all
endef

define Build/Compile
  $(call GoPackage/Build/Compile)
endef

define Package/nebula/description
Nebula is a scalable overlay networking tool with a focus on performance, simplicity
and security. It lets you seamlessly connect computers anywhere in the world.
This package contains only nebula binary. Unless you want to start nebula manually,
you may want to also install *either* 'nebula-service' *or* 'nebula-proto' package.
endef

define Package/nebula-cert/description
Nebula is a scalable overlay networking tool with a focus on performance, simplicity
and security. It lets you seamlessly connect computers anywhere in the world.
This package contains only nebula-cert binary.
endef

define Package/nebula-proto/description
Nebula is a scalable overlay networking tool with a focus on performance, simplicity
and security. It lets you seamlessly connect computers anywhere in the world.
This package contains only OpenWrt protocol/interface support for nebula.
endef

define Package/nebula-service/description
Nebula is a scalable overlay networking tool with a focus on performance, simplicity
and security. It lets you seamlessly connect computers anywhere in the world.
This package contains only OpenWrt-specific init.d script for nebula.
endef

define Package/nebula/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/lib/upgrade/keep.d
	$(INSTALL_DIR) $(1)/usr/share/doc/nebula
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/nebula $(1)/usr/sbin/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/LICENSE $(1)/usr/share/doc/nebula/LICENSE
	$(INSTALL_DATA) ./files/nebula.upgrade $(1)/lib/upgrade/keep.d/nebula
endef

define Package/nebula-cert/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/lib/upgrade/keep.d
	$(INSTALL_DIR) $(1)/usr/share/doc/nebula-cert
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/nebula-cert $(1)/usr/sbin/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/LICENSE $(1)/usr/share/doc/nebula-cert/LICENSE
	$(INSTALL_DATA) ./files/nebula.upgrade $(1)/lib/upgrade/keep.d/nebula-cert
endef

define Package/nebula-proto/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/lib/netifd/proto
	$(INSTALL_BIN) ./files/nebula.proto $(1)/lib/netifd/proto/nebula.sh
	$(SED) "s|^\(readonly PKG_VERSION\).*|\1='$(PKG_VERSION)-$(PKG_RELEASE)'|" $(1)/lib/netifd/proto/nebula.sh
endef

define Package/nebula-service/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/nebula.init $(1)/etc/init.d/nebula
	$(SED) "s|^\(readonly PKG_VERSION\).*|\1='$(PKG_VERSION)-$(PKG_RELEASE)'|" $(1)/etc/init.d/nebula
endef

$(eval $(call GoBinPackage,nebula))
$(eval $(call BuildPackage,nebula))

$(eval $(call GoBinPackage,nebula-cert))
$(eval $(call BuildPackage,nebula-cert))

$(eval $(call BuildPackage,nebula-proto))

$(eval $(call BuildPackage,nebula-service))
