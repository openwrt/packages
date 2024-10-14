include $(TOPDIR)/rules.mk

PKG_NAME:=crun
PKG_VERSION:=1.17
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/containers/crun/tar.gz/$(PKG_VERSION)?
PKG_HASH:=f106f6adb752af5e0a867e226440e9ddaaf2d7400149d181f171b78ca19ad5e5

PKG_BUILD_DEPENDS:=argp-standalone
PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

PKG_MAINTAINER:=Oskari Rauta <oskari.rauta@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:crun_project:crun

include $(INCLUDE_DIR)/package.mk

define Package/crun
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=crun
  URL:=https://github.com/containers/crun
  DEPENDS:=@!arc +libseccomp +libcap +libgcrypt
endef

define Package/crun/description
  A fast and low-memory footprint OCI Container Runtime fully written in C.
endef

LIBOCISPEC_COMMIT:=68211ccc41201c45ad276b04c7f67d61e80b1f7a

define Download/libocispec
  PROTO:=git
  URL:=https://github.com/containers/libocispec.git
  VERSION:=$(LIBOCISPEC_COMMIT)
  MIRROR_HASH:=688d00600dbdf46d4b52acc8e43313b14471026ccff8c3cc5983e2f5dfd15571
  FILE:=libocispec-$(LIBOCISPEC_COMMIT).tar.xz
  SUBDIR:=libocispec
endef
$(eval $(call Download,libocispec))

CONFIGURE_ARGS+= \
	--disable-systemd \
	--enable-embedded-yajl \
	--enable-caps \
	--enable-dl \
	--enable-seccomp \
	--enable-bpf

define Build/Prepare
	$(call Build/Prepare/Default)
	$(SED) '/#include <git-version.h>/d' $(PKG_BUILD_DIR)/src/{crun.c,libcrun/container.c}
	xzcat $(DL_DIR)/libocispec-$(LIBOCISPEC_COMMIT).tar.xz | $(HOST_TAR) -C $(PKG_BUILD_DIR) $(TAR_OPTIONS)
endef

define Build/Configure
	$(call Build/Configure/Default)

	$(SED) '/#define PACKAGE \"/d' $(PKG_BUILD_DIR)/config.h
	$(SED) '/#define VERSION \"/d' $(PKG_BUILD_DIR)/config.h
	$(SED) '/#define GIT_VERSION \"/d' $(PKG_BUILD_DIR)/config.h
	$(SED) '/#define PACKAGE_BUGREPORT \"/d' $(PKG_BUILD_DIR)/config.h
	$(SED) '/#define PACKAGE_NAME \"/d' $(PKG_BUILD_DIR)/config.h
	$(SED) '/#define PACKAGE_STRING \"/d' $(PKG_BUILD_DIR)/config.h
	$(SED) '/#define PACKAGE_TARNAME \"/d' $(PKG_BUILD_DIR)/config.h
	$(SED) '/#define PACKAGE_VERSION \"/d' $(PKG_BUILD_DIR)/config.h

	echo "#define PACKAGE \"$(PKG_NAME)\"" >> $(PKG_BUILD_DIR)/config.h
	echo "#define VERSION \"$(PKG_VERSION)\"" >> $(PKG_BUILD_DIR)/config.h
	echo "#define PACKAGE_NAME \"$(PKG_NAME)\"" >> $(PKG_BUILD_DIR)/config.h
	echo "#define PACKAGE_VERSION \"$(PKG_VERSION)\"" >> $(PKG_BUILD_DIR)/config.h
	echo "#define PACKAGE_STRING \"$(PKG_NAME) $(PKG_VERSION)\"" >> $(PKG_BUILD_DIR)/config.h
	echo "#define PACKAGE_TARNAME \"$(PKG_NAME)\"" >> $(PKG_BUILD_DIR)/config.h
	echo "#define PACKAGE_BUGREPORT \"bugs@openwrt.org\"" >> $(PKG_BUILD_DIR)/config.h
	echo "#define GIT_VERSION \"$(PKG_SOURCE_VERSION)\"" >> $(PKG_BUILD_DIR)/config.h
endef

define Package/crun/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/crun $(1)/usr/bin/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libcrun.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,crun))
