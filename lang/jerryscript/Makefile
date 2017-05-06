include $(TOPDIR)/rules.mk

PKG_NAME:=jerryscript
PKG_VERSION:=b2f3ec2
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/Samsung/jerryscript.git
PKG_SOURCE:=$(PKG_NAME).tar.gz
PKG_SOURCE_VERSION:=b2f3ec225e931e5b2ddac6a249626ffce8fdf045
PKG_SOURCE_SUBDIR:=$(PKG_NAME)

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_MAINTAINER:=Benjamin Henrion <zoobab@gmail.com>
PKG_LICENSE=WTFPL
PKG_INSTALL:=0
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

TARGET_CFLAGS:=$(filter-out -Werror, $(TARGET_CFLAGS))

# don't strip for now, there is an error where cmake does not find the -strip from the toolchain
CMAKE_OPTIONS+=-DUSE_COMPILER_DEFAULT_LIBC=YES -DSTRIP_RELEASE_BINARY=NO
PKG_MAKE_ARGS+=release.linux-cp_minimal

define Package/jerryscript
  MAINTAINER:=zoobab@gmail.com
  TITLE:=jerryscript
  SECTION:=lang
  SUBMENU:=Javascript
  CATEGORY:=Languages
endef

define Package/jerryscript/description
	Ultra-lightweight JavaScript engine for Internet of Things
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) $(PKG_MAKE_ARGS)
endef

define Build/Install
	$(INSTALL_DIR) $(PKG_INSTALL_DIR)/usr/bin
	$(CP) $(PKG_BUILD_DIR)/release.linux-cp_minimal $(PKG_INSTALL_DIR)/usr/bin/jerryscript
endef

define Package/jerryscript/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
endef

$(eval $(call BuildPackage,jerryscript))
