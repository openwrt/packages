include $(TOPDIR)/rules.mk

PKG_NAME:=syncthing
PKG_VERSION:=1.24.0
PKG_RELEASE:=2

PKG_SOURCE:=syncthing-source-v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/syncthing/syncthing/releases/download/v$(PKG_VERSION)
PKG_HASH:=4a9459667f9b70a7d1e7d572c7c9d02431ef8f055679eef368300ce1a826608f

PKG_BUILD_DIR=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)/$(PKG_NAME)

PKG_MAINTAINER:=Paul Spooren <mail@aparcar.org>
PKG_LICENSE:=MPL-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:syncthing:syncthing

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/syncthing/syncthing
GO_PKG_BUILD_PKG:=\
	$(if $(CONFIG_PACKAGE_syncthing),$(GO_PKG)/cmd/syncthing/) \
	$(if $(CONFIG_PACKAGE_stdiscosrv),$(GO_PKG)/cmd/stdiscosrv/) \
	$(if $(CONFIG_PACKAGE_strelaysrv),$(GO_PKG)/cmd/strelaysrv/)
GO_PKG_INSTALL_EXTRA:=^gui/

GO_PKG_TAGS:=noupgrade
GO_PKG_LDFLAGS_X:=\
	$(GO_PKG)/lib/build.Version=v$(PKG_VERSION) \
	$(GO_PKG)/lib/build.Stamp=$(SOURCE_DATE_EPOCH) \
	$(GO_PKG)/lib/build.User=openwrt \
	$(GO_PKG)/lib/build.Host=openwrt \
	$(GO_PKG)/lib/build.Tags=$(GO_PKG_TAGS)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/syncthing/Default
  URL:=https://syncthing.net
  DEPENDS:=$(GO_ARCH_DEPENDS)
  SECTION:=utils
  CATEGORY:=Utilities
endef

define Package/syncthing
  $(call Package/syncthing/Default)
  TITLE:=Continuous file synchronization program
  USERID:=syncthing=499:syncthing=499
endef

define Package/stdiscosrv
  $(call Package/syncthing/Default)
  TITLE:=Discovery server for syncthing
endef

define Package/strelaysrv
  $(call Package/syncthing/Default)
  TITLE:=Relay server for syncthing
endef

define Package/syncthing/conffiles
/etc/config/syncthing
/etc/syncthing
endef

define Package/stdiscosrv/conffiles
/etc/config/stdiscosrv
/etc/stdiscosrv
endef

define Package/strelaysrv/conffiles
/etc/config/strelaysrv
/etc/strelaysrv
endef

define Package/syncthing/description
  Syncthing replaces proprietary sync and cloud services with something
  open, trustworthy and decentralized. Your data is your data alone and
  you deserve to choose where it is stored, if it is shared with some
  third party and how it's transmitted over the Internet.
endef

define Package/stdiscosrv/description
  Relay server for syncthing
endef

define Package/strelaysrv/description
  Relay server for syncthing
endef

define SyncthingInstall
	$(INSTALL_DIR) $(1)/etc/$(2)

	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_CONF) $(CURDIR)/files/$(2).conf $(1)/etc/config/$(2)

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) $(CURDIR)/files/$(2).init $(1)/etc/init.d/$(2)

	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/$(2) $(1)/usr/bin
endef


define Package/syncthing/install
	$(call SyncthingInstall,$(1),syncthing)

	$(INSTALL_DIR) $(1)/etc/sysctl.d/
	$(INSTALL_BIN) $(CURDIR)/files/syncthing-sysctl.conf $(1)/etc/sysctl.d/90-syncthing-inotify.conf
endef

define Package/stdiscosrv/install
	$(call SyncthingInstall,$(1),stdiscosrv)
endef

define Package/strelaysrv/install
	$(call SyncthingInstall,$(1),strelaysrv)
endef

$(eval $(call BuildPackage,syncthing))
$(eval $(call BuildPackage,stdiscosrv))
$(eval $(call BuildPackage,strelaysrv))
