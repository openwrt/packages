include $(TOPDIR)/rules.mk

PKG_NAME:=docker
PKG_VERSION:=27.1.0
PKG_RELEASE:=1
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_GIT_URL:=github.com/docker/cli
PKG_GIT_REF:=v$(PKG_VERSION)
PKG_SOURCE_URL:=https://codeload.$(PKG_GIT_URL)/tar.gz/$(PKG_GIT_REF)?
PKG_HASH:=8e58a2e419ba91ce1a27831c394bf214f7076758f55eccc6762b5265bec58b9f
PKG_GIT_SHORT_COMMIT:=6312585 # SHA1 used within the docker executables

PKG_MAINTAINER:=Gerard Ryan <G.M0N3Y.2503@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=$(PKG_GIT_URL)

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

GO_PKG_INSTALL_EXTRA:=\
	cli/compose/schema/data \
	vendor/google.golang.org/protobuf/internal/editiondefaults/editions_defaults.binpb

TAR_OPTIONS:=--strip-components 1 $(TAR_OPTIONS)
TAR_CMD=$(HOST_TAR) -C $(1) $(TAR_OPTIONS)
TARGET_LDFLAGS += $(if $(CONFIG_USE_GLIBC),-lc -lgcc_eh)

define Build/Prepare
	$(Build/Prepare/Default)

	# Verify PKG_GIT_SHORT_COMMIT
	( \
		EXPECTED_PKG_GIT_SHORT_COMMIT=$$$$( $(CURDIR)/../dockerd/git-short-commit.sh '$(PKG_GIT_URL)' '$(PKG_GIT_REF)' '$(TMP_DIR)/git-short-commit/$(PKG_NAME)-$(PKG_VERSION)' ); \
		if [ "$$$${EXPECTED_PKG_GIT_SHORT_COMMIT}" != "$(strip $(PKG_GIT_SHORT_COMMIT))" ]; then \
			echo "ERROR: Expected 'PKG_GIT_SHORT_COMMIT:=$$$${EXPECTED_PKG_GIT_SHORT_COMMIT}', found 'PKG_GIT_SHORT_COMMIT:=$(strip $(PKG_GIT_SHORT_COMMIT))'"; \
			exit 1; \
		fi \
	)
endef

define Build/Compile
	( \
		cd $(PKG_BUILD_DIR); \
		$(GO_PKG_VARS) \
		GITCOMMIT=$(PKG_GIT_SHORT_COMMIT) \
		VERSION=$(PKG_VERSION) \
		./scripts/build/binary; \
	)
endef

define Package/docker/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/build/docker $(1)/usr/bin/
endef

$(eval $(call BuildPackage,docker))
