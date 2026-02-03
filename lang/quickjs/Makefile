include $(TOPDIR)/rules.mk

PKG_NAME:=quickjs
PKG_VERSION:=2025.09.13
# The source versioning structure is somewhat bizarre as the file name
# might differ from the directory name and the version.
PKG_SRC_VERSION:=2025-09-13
PKG_SRC_VERSION_REV:=2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_SRC_VERSION)$(if $(PKG_SRC_VERSION_REV),-$(PKG_SRC_VERSION_REV)).tar.xz
PKG_SOURCE_URL:=https://bellard.org/quickjs/
PKG_HASH:=996c6b5018fc955ad4d06426d0e9cb713685a00c825aa5c0418bd53f7df8b0b4

PKG_MAINTAINER:=George Sapkin <george@sapk.in>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:quickjs_project:quickjs

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_SRC_VERSION)
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

# quickjs uses the same flags both for host and target compiler, so we need
# to separate these and build host and target parts separately.
HOST_MAKE_FLAGS := \
	$(MAKE_FLAGS) \
	CC="$(HOSTCC_NOCACHE)" \
	CFLAGS="$(HOST_CFLAGS) -D_GNU_SOURCE -DCONFIG_VERSION=\\\"$(PKG_SRC_VERSION)\\\"" \
	CROSS_PREFIX="$(TARGET_CROSS)"

TARGET_MAKE_FLAGS := \
	$(MAKE_FLAGS) \
	CC="$(TARGET_CC)" \
	CFLAGS_OPT="$(TARGET_CFLAGS) -D_GNU_SOURCE -DCONFIG_VERSION=\\\"$(PKG_SRC_VERSION)\\\"" \
	EXTRA_LIBS="-latomic" \
	QJSC=./host-qjsc

define Package/quickjs
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=QuickJS JavaScript engine
  URL:=https://bellard.org/quickjs
  DEPENDS:=+libatomic
endef

define Package/quickjs/description
  QuickJS is a small and embeddable JavaScript engine. It supports the
  ES2023 specification including modules, asynchronous generators, proxies
  and BigInt.
endef

define Build/Compile
	$(INSTALL_DIR) $(PKG_BUILD_DIR)/.obj
	$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) $(HOST_MAKE_FLAGS) host-qjsc
	$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) $(TARGET_MAKE_FLAGS) qjs
endef

define Package/quickjs/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/qjs $(1)/usr/bin
endef

$(eval $(call BuildPackage,quickjs))
