include $(TOPDIR)/rules.mk

PKG_NAME:=syncthing
PKG_VERSION:=1.2.1
PKG_RELEASE:=1

PKG_SOURCE:=syncthing-source-v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/syncthing/syncthing/releases/download/v$(PKG_VERSION)
PKG_HASH:=313bd59ddc2562e833fc4caa8d90360a06d5ff02976c0a4d5d42393e6f8bceac

PKG_BUILD_DIR=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)/$(PKG_NAME)

PKG_MAINTAINER:=Paul Spooren <mail@aparcar.org>
PKG_LICENSE:=MPL-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:syncthing:syncthing

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/syncthing/syncthing/
GO_PKG_BUILD_PKG:=github.com/syncthing/syncthing/cmd/syncthing/
GO_PKG_INSTALL_EXTRA:=^gui/

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/syncthing
  TITLE:=Continuous file synchronization program
  URL:=https://syncthing.net
  DEPENDS:=$(GO_ARCH_DEPENDS)
  SECTION:=utils
  CATEGORY:=Utilities
endef

GO_PKG_LDFLAGS_X:=\
	main.Version=v$(PKG_VERSION) \
	main.BuildUser=openwrt \
	main.BuildHost=openwrt \
	main.BuildStamp=$(SOURCE_DATE_EPOCH)

define Build/Compile
  $(call GoPackage/Build/Compile,-tags noupgrade)
endef

define Package/syncthing/conffiles
/etc/config/syncthing
/etc/syncthing
endef

define Package/syncthing/description
		Syncthing replaces proprietary sync and cloud services with something
		open, trustworthy and decentralized. Your data is your data alone and
		you deserve to choose where it is stored, if it is shared with some
		third party and how it's transmitted over the Internet.
endef

define Package/syncthing/install
	$(call GoPackage/Package/Install/Bin,$(1))

	$(CP) ./files/* $(1)/
endef

$(eval $(call GoBinPackage,syncthing))
$(eval $(call BuildPackage,syncthing))
