include $(TOPDIR)/rules.mk

PKG_NAME:=databag
PKG_VERSION:=1.1.11
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL_FILE:=server.tar.gz
PKG_SOURCE_URL:=https://github.com/balzack/databag/releases/download/v$(PKG_VERSION)/
PKG_HASH:=b4f9b46ffc9810156c6b8e50216ee4b703b5967a3a88acd982e0ce9ee42098e4

PKG_MAINTAINER:=Roland Osborne <roland.osborne@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DIR:=$(BUILD_DIR)/databag-openwrt-$(PKG_VERSION)
PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

UNPACK_CMD=tar xf "$(DL_DIR)/$(PKG_SOURCE)" -C $(1)

TARGET_CFLAGS += "-D_LARGEFILE64_SOURCE"
GO_PKG:=databag

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Download/static_web
	URL:=https://github.com/balzack/databag/releases/download/v$(PKG_VERSION)
	URL_FILE:=webapp.tar.gz
	FILE:=$(PKG_NAME)-$(PKG_VERSION)-webapp.tar.gz
	HASH:=9a9a4332a4837e356b3815fec3aacf5099d8a11dfcdad83847790d235101fa05
endef

define Package/databag/install
	$(call GoPackage/Package/Install/Bin,$(1))
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/databag $(1)/usr/bin/databag
	$(INSTALL_DIR) $(1)/opt/databag
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/databag.db $(1)/opt/databag/
	$(INSTALL_DIR) $(1)/opt/databag/web
	$(TAR) xf $(DL_DIR)/$(PKG_NAME)-$(PKG_VERSION)-webapp.tar.gz -C $(1)/opt/databag/web/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) files/databag.init $(1)/etc/init.d/databag
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) files/databag.config $(1)/etc/config/databag
endef

define Package/databag
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Instant Messaging
  TITLE:=Federated Messaging Service
  URL:=https://github.com/balzack/databag
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/databagdescription
  Databag is a federated messaging service with browser and mobile clients.
endef

$(eval $(call Download,static_web))
$(eval $(call GoBinPackage,databag))
$(eval $(call BuildPackage,databag))
