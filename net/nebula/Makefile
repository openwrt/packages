# Copyright 2021-2023 Stan Grishin (stangri@melmac.ca)
# This is free software, licensed under the Apache 2.0 License.

include $(TOPDIR)/rules.mk

PKG_NAME:=nebula
PKG_VERSION:=1.9.5
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/slackhq/nebula/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=5f7000e943cbe8cc7d7e2651ee2301121654fe1f51902f010ca908ac9ca0eede

PKG_MAINTAINER:=Yuxi Yang <i@bgme.me>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:slack:nebula

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

define Package/nebula/Default
  SECTION:=net
  CATEGORY:=Network
  URL:=https://docs.openwrt.melmac.net/nebula/
endef

define Package/nebula
  $(call Package/nebula/Default)
  TITLE:=nebula
  DEPENDS:=$(GO_ARCH_DEPENDS) +kmod-tun
endef

define Package/nebula-cert
  $(call Package/nebula/Default)
  TITLE:=nebula-cert
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/nebula-proto
  $(call Package/nebula/Default)
  TITLE:=nebula-proto
  DEPENDS:=nebula
	DEPENDS+=+!BUSYBOX_DEFAULT_AWK:gawk
	DEPENDS+=+!BUSYBOX_DEFAULT_GREP:grep
	DEPENDS+=+!BUSYBOX_DEFAULT_SED:sed
  PKGARCH:=all
endef

define Package/nebula-service
  $(call Package/nebula/Default)
  TITLE:=nebula-service
  DEPENDS:=nebula
	DEPENDS+=+!BUSYBOX_DEFAULT_AWK:gawk
	DEPENDS+=+!BUSYBOX_DEFAULT_SED:sed
	CONFLICTS:=nebula-proto
  PKGARCH:=all
endef

define Package/nebula/description/Default
  Nebula is a scalable overlay networking tool with a focus on performance, simplicity
  and security. It lets you seamlessly connect computers anywhere in the world.
endef

define Package/nebula/description
  $(call Package/nebula/description/Default)
  This package contains only nebula binary. Unless you want to start nebula manually,
  you may want to also install *either* 'nebula-service' *or* 'nebula-proto' package.
endef

define Package/nebula-cert/description
  $(call Package/nebula/description/Default)
  This package contains only nebula-cert binary.
endef

define Package/nebula-proto/description
  $(call Package/nebula/description/Default)
  This package contains only OpenWrt protocol/interface support for nebula.
endef

define Package/nebula-service/description
  $(call Package/nebula/description/Default)
  This package contains only OpenWrt-specific init.d script for nebula.
endef

define Package/nebula/conffiles
/etc/nebula/
endef

Package/nebula-cert/conffiles = $(Package/nebula/conffiles)

define Package/nebula/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/nebula $(1)/usr/sbin/
endef

define Package/nebula-cert/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/nebula-cert $(1)/usr/sbin/
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
