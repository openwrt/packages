include $(TOPDIR)/rules.mk

PKG_NAME:=crun
PKG_VERSION:=0.18
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/containers/crun.git
PKG_SOURCE_DATE:=2021-03-18
PKG_SOURCE_VERSION:=496e81bdd69f117f10e4477e4204e4611a94b68f
PKG_MIRROR_HASH:=26941b0d84bbeabeb5e982af48d131f55d0aa16f4a2f2ca3279a5c812cdeea8b

PKG_BUILD_DEPENDS:=argp-standalone
PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

PKG_MAINTAINER:=Oskari Rauta <oskari.rauta@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/crun
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=crun
  URL:=https://github.com/containers/crun
  DEPENDS:=@!arc +libseccomp +libcap
endef

define Package/crun/description
  A fast and low-memory footprint OCI Container Runtime fully written in C.
endef

CONFIGURE_ARGS+= \
	--disable-systemd \
	--enable-embedded-yajl \
	--enable-caps \
	--enable-dl \
	--enable-seccomp \
	--enable-bpf

define Build/Prepare
	$(call Build/Prepare/Default)
	$(SED) '/#include <git-version.h>/d' $(PKG_BUILD_DIR)/src/crun.c
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
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/crun $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libcrun.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,crun))
