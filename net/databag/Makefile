include $(TOPDIR)/rules.mk

PKG_NAME:=databag
PKG_VERSION:=1.1.11
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/balzack/databag/releases/download/v$(PKG_VERSION)/server.tar.gz?
PKG_HASH:=b4f9b46ffc9810156c6b8e50216ee4b703b5967a3a88acd982e0ce9ee42098e4

PKG_MAINTAINER:=Roland Osborne <roland.osborne@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=databag

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

TAR_CMD=$(HOST_TAR) -C $(1) $(TAR_OPTIONS)

define Package/databag
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Instant Messaging
  TITLE:=Federated Messaging Service
  URL:=https://github.com/balzack/databag
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/databag/description
  Databag is a federated messaging service with browser and mobile clients.
endef

define Package/databag/conffiles
/etc/config/databag
endef

define Download/static_web
	URL:=https://github.com/balzack/databag/releases/download/v$(PKG_VERSION)
	URL_FILE:=webapp.tar.gz
	FILE:=$(PKG_NAME)-$(PKG_VERSION)-webapp.tar.gz
	HASH:=9a9a4332a4837e356b3815fec3aacf5099d8a11dfcdad83847790d235101fa05
endef

TARGET_CFLAGS += "-D_LARGEFILE64_SOURCE"

define Package/databag/install
	$(call GoPackage/Package/Install/Bin,$(1))
	$(INSTALL_DIR) $(1)/usr/share/databag
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/databag.db $(1)/usr/share/databag/
	$(INSTALL_DIR) $(1)/usr/share/databag/web
	gzip -dc $(DL_DIR)/$(PKG_NAME)-$(PKG_VERSION)-webapp.tar.gz | $(HOST_TAR) -C $(1)/usr/share/databag/web/ $(TAR_OPTIONS)

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) files/databag.init $(1)/etc/init.d/databag
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) files/databag.config $(1)/etc/config/databag
endef

$(eval $(call Download,static_web))
$(eval $(call GoBinPackage,databag))
$(eval $(call BuildPackage,databag))
