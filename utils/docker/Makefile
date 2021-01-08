include $(TOPDIR)/rules.mk

PKG_NAME:=docker
PKG_VERSION:=20.10.2
PKG_RELEASE:=1
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/docker/cli/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=a663f54a158c6b2b23b253b14bf0de56ff035750098e760319de1edb7f4ae76d
PKG_SOURCE_VERSION:=2291f61 # SHA1 used within the docker executable

PKG_MAINTAINER:=Gerard Ryan <G.M0N3Y.2503@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/docker/cli

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/docker
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Docker Community Edition CLI
  URL:=https://www.docker.com/
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/docker/description
The CLI used in the Docker CE and Docker EE products.
endef

TAR_OPTIONS:=--strip-components 1 $(TAR_OPTIONS)
TAR_CMD=$(HOST_TAR) -C $(1) $(TAR_OPTIONS)

define Build/Compile
	( \
		cd $(PKG_BUILD_DIR); \
		$(GO_PKG_VARS) \
		GITCOMMIT=$(PKG_SOURCE_VERSION) \
		VERSION=$(PKG_VERSION) \
		./scripts/build/binary; \
	)
endef

define Package/docker/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/build/docker $(1)/usr/bin/
endef
$(eval $(call BuildPackage,docker))
