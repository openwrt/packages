include $(TOPDIR)/rules.mk

PKG_NAME:=oci-runtime-tools
PKG_VERSION:=1.0.0-pre20210122
PKG_RELEASE:=2
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE_PROTO:=git
PKG_SOURCE_NAME:=runtime-tools
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/opencontainers/runtime-tools.git
PKG_SOURCE_VERSION:=453547deb724af135587e654f52d86b8619f21b9
PKG_MIRROR_HASH:=34f3aefc4f6f3bb93330ec7cbeb2eb987b82184da53d453e8b04b5750faa8728

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/opencontainers/runtime-tools/
GO_PKG_LDFLAGS_X:=main.gitCommit=$(PKG_SOURCE_VERSION) main.version=$(PKG_SOURCE_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/oci-runtime-tool
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=oci-runtime-tool
  URL:=https://github.com/opencontainers/runtime-tools
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/oci-runtime-tool/description
  OCI (Open Container Initiative) runtime tools
  Generate OCI runtime spec configuration files and validate OCI bundles.
endef

define Package/oci-runtime-tests
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=OCI runtimetest tool
  URL:=https://github.com/opencontainers/runtime-tools
  DEPENDS:=@(i386||i686||x86_64) oci-runtime-tool +tar
endef

define Package/oci-runtime-tests/description
  OCI (Open Container Initiative) runtime tools
  This package provides test cases as well as artifacts required to
  validate an OCI runtime.
  Best used in combination with a TAP consumer like 'node-tap',
  installable via npm.
endef

GO_PKG_BUILD_VARS += GO111MODULE=auto

define Build/Compile
	$(call GoPackage/Build/Compile)
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
endef

define Package/oci-runtime-tool/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/oci-runtime-tool $(1)/usr/bin
endef

define Package/oci-runtime-tests/install
	$(INSTALL_DIR) $(1)/usr/libexec/oci-runtime-test
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/runtimetest $(1)/usr/libexec/oci-runtime-test/
	( cd $(PKG_BUILD_DIR) ; $(FIND) ./validation/ -name *.go | grep -v util | \
	xargs -I'%' -n 1 basename % .go | while read testbin; do \
		$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/$$$${testbin} \
			$(1)/usr/libexec/oci-runtime-test/$$$${testbin}.t ; \
	done )
ifdef CONFIG_x86_64
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/rootfs-amd64.tar.gz $(1)/usr/libexec/oci-runtime-test
endif
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/rootfs-386.tar.gz $(1)/usr/libexec/oci-runtime-test
endef

$(eval $(call GoBinPackage,oci-runtime-tools))
$(eval $(call BuildPackage,oci-runtime-tool))
$(eval $(call BuildPackage,oci-runtime-tests))
