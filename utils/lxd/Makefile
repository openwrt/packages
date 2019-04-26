#
# Copyright (C) 2019 TDT AG <development@tdt.de>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lxd
PKG_VERSION:=3.11
PKG_RELEASE:=1

PKG_MAINTAINER:=Florian Eckert <fe@dev.tdt.de>
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/lxc/lxd/tar.gz/lxd-${PKG_VERSION}?
PKG_HASH:=3e5dea96a2880ff378c2fe1d9123b3a925b09900e7b039cc12a9f56a14bb1b0f
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1

GO_PKG:=github.com/lxc/lxd
GO_PKG_BUILD_PKG:=github.com/lxc/lxd/lxc
GO_PKG_INSTALL_ALL:=1

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/lxd/Default
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=LXD - System container manager
  URL:=https://linuxcontainers.org/lxd/
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Build/Configure
	$(call GoPackage/Build/Configure)

	# PREPARE PACKAGE BUILD DEPENDENCIES
	$(CP) $(GO_PKG_BUILD_DIR)/src/* $(GO_PKG_TMP_DIR)
	$(RM) -rf $(GO_PKG_BUILD_DIR)/src
	$(CP) $(PKG_BUILD_DIR)/dist/src $(GO_PKG_BUILD_DIR)
	$(RM) -rf $(GO_PKG_BUILD_DIR)/src/github.com/lxc
	$(CP) $(GO_PKG_TMP_DIR)/github.com/* $(GO_PKG_BUILD_DIR)/src/github.com
	$(RM) -rf $(GO_PKG_TMP_DIR)/github.com
endef

define Package/lxd-server
$(call Package/lxd/Default)
  TITLE+= server
endef

define Package/lxd-server/description
  System container manager using linux containers
  LXD daemon (server) package.
endef

define Package/lxd-client
$(call Package/lxd/Default)
  TITLE+= client
endef

define Package/lxd-client/description
  System container manager using linux containers
  LXD client tools
endef

$(eval $(call GoBinPackage,lxd-server))
$(eval $(call BuildPackage,lxd-server))

$(eval $(call GoBinPackage,lxd-client))
$(eval $(call BuildPackage,lxd-client))
