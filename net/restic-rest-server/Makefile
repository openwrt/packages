include $(TOPDIR)/rules.mk

PKG_NAME:=restic-rest-server
PKG_VERSION:=0.11.0
PKG_RELEASE:=2

PKG_BUILD_DIR:=$(BUILD_DIR)/rest-server-$(PKG_VERSION)
PKG_SOURCE:=rest-server-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/restic/rest-server/tar.gz/v${PKG_VERSION}?
PKG_HASH:=cd9b35ad2224244207a967ebbc78d84f4298d725e95c1fa9341ed95a350ea68f

PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Tom Stöveken <tom@naaa.de>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/restic/rest-server/
GO_PKG_BUILD_PKG:=github.com/restic/rest-server/cmd/rest-server/
GO_PKG_LDFLAGS_X:=main.version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/restic-rest-server
  TITLE:=restic REST server
  URL:=http://github.com/restic/rest-server
  DEPENDS:=$(GO_ARCH_DEPENDS)
  SECTION:=net
  CATEGORY:=Network
endef

define Package/restic-rest-server/conffiles
/etc/config/restic-rest-server
endef

define Package/restic-rest-server/description
Rest Server is a high performance HTTP server that implements restic's REST backend
API. It provides secure and efficient way to backup data remotely, using restic
backup client via the rest: URL.
endef

GO_PKG_BUILD_VARS += GO111MODULE=auto

define Package/restic-rest-server/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/rest-server $(1)/usr/bin/restic-rest-server
	$(CP) ./files/* $(1)/
endef

$(eval $(call GoBinPackage,restic-rest-server))
$(eval $(call BuildPackage,restic-rest-server))
