include $(TOPDIR)/rules.mk

PKG_NAME:=syncthing
PKG_VERSION:=1.22.1
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=syncthing-source-v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/syncthing/syncthing/releases/download/v$(PKG_VERSION)
PKG_HASH:=b024d112167e0e81a785ab98c1a044aee1ac041dfe57a62772c08284f875a5bd

PKG_BUILD_DIR=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)/$(PKG_NAME)

PKG_MAINTAINER:=Paul Spooren <mail@aparcar.org>
PKG_LICENSE:=MPL-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:syncthing:syncthing

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/syncthing/syncthing/
GO_PKG_BUILD_PKG:=\
	$(if $(CONFIG_PACKAGE_syncthing),github.com/syncthing/syncthing/cmd/syncthing/) \
	$(if $(CONFIG_PACKAGE_stdiscosrv),github.com/syncthing/syncthing/cmd/stdiscosrv/) \
	$(if $(CONFIG_PACKAGE_strelaysrv),github.com/syncthing/syncthing/cmd/strelaysrv/)
GO_PKG_INSTALL_EXTRA:=^gui/

GO_PKG_LDFLAGS_X:=\
	github.com/syncthing/syncthing/lib/build.Version=v$(PKG_VERSION) \
	github.com/syncthing/syncthing/lib/build.Stamp=$(SOURCE_DATE_EPOCH) \
	github.com/syncthing/syncthing/lib/build.User=openwrt \
	github.com/syncthing/syncthing/lib/build.Host=openwrt \
	github.com/syncthing/syncthing/lib/build.Tags=noupgrade
GO_PKG_TAGS:=noupgrade

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

define Build/Install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
endef

define SyncthingInstall
	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_CONF) $(CURDIR)/files/$(2).conf $(1)/etc/config/$(2)

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) $(CURDIR)/files/$(2).init $(1)/etc/init.d/$(2)

	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/$(2) $(1)/usr/bin
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
