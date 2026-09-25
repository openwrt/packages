include $(TOPDIR)/rules.mk

PKG_NAME:=crun
PKG_VERSION:=1.28
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/containers/crun/tar.gz/$(PKG_VERSION)?
PKG_HASH:=90284c7f097f8ee72a6447978c263e1b1355727c2f2ca0ac667e6d57788f46f5

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
  DEPENDS:=@!arc +libseccomp +libcap +libgcrypt +libjson-c
endef

define Package/crun/description
  A fast and low-memory footprint OCI Container Runtime fully written in C.
endef

LIBOCISPEC_COMMIT:=8034d0ecd27f646ba3ffae5ff24db234ce062825

define Download/libocispec
  PROTO:=git
  URL:=https://github.com/containers/libocispec.git
  SOURCE_VERSION:=$(LIBOCISPEC_COMMIT)
  MIRROR_HASH:=ac132910952d2d5c6bf3c8b891cced10d1c6113d50c78779a6b8d21851dc908a
  FILE:=libocispec-$(LIBOCISPEC_COMMIT).tar.xz
  SUBDIR:=libocispec
endef
$(eval $(call Download,libocispec))

CONFIGURE_ARGS+= \
	--disable-systemd \
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
