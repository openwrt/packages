include $(TOPDIR)/rules.mk

PKG_NAME:=apk
PKG_VERSION:=3.0.0_pre0

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://git.alpinelinux.org/apk-tools.git
PKG_SOURCE_DATE:=2021-08-17
PKG_SOURCE_VERSION:=a46043bcc4cc15b456ef1eac5c5f9d93bd905d53
PKG_MIRROR_HASH:=e16fd04b18043e78a177acd8c6958fa03fd1484b62c879c2dd0bed8ce9c50625
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_SOURCE_DATE)-$(call version_abbrev,$(PKG_SOURCE_VERSION))
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)
HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/$(PKG_SOURCE_SUBDIR)
PKG_SOURCE:=$(PKG_SOURCE_SUBDIR).tar.xz
PKG_RELEASE:=r$(PKG_SOURCE_DATE)-$(call version_abbrev,$(PKG_SOURCE_VERSION))-$(AUTORELEASE)

PKG_MAINTAINER:=Paul Spooren <mail@aparcar.org>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

HOST_BUILD_DEPENDS:=lua/host lua-lzlib/host
PKG_BUILD_DEPENDS:=$(HOST_BUILD_DEPENDS)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

define Package/apk
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=apk package manager
  DEPENDS:=+liblua +libopenssl +zlib @!arc
  URL:=$(PKG_SOURCE_URL)
endef

define Package/alpine-keys
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Alpine apk public signing keys
  DEPENDS:=apk
endef

define Package/alpine-repositories
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Official Alpine repositories
  DEPENDS:=apk
endef

MAKE_FLAGS += \
	LUA=$(STAGING_DIR_HOSTPKG)/bin/lua \
	LUA_VERSION=5.1 \
	LUA_PC=lua

HOST_MAKE_FLAGS += \
	LUA=$(STAGING_DIR_HOSTPKG)/bin/lua \
	LUA_VERSION=5.1 \
	DESTDIR=$(STAGING_DIR_HOSTPKG) \
	SBINDIR=/bin \
	PREFIX=

HOST_LDFLAGS+=-Wl,-rpath=$(STAGING_DIR_HOSTPKG)/lib -lpthread

define Package/apk/install
	$(INSTALL_DIR) $(1)/lib/apk/db

	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/sbin/apk $(1)/bin/apk

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/*.so.* $(1)/usr/lib/

	$(INSTALL_DIR) $(1)/etc/apk/
	echo $(ARCH) > $(1)/etc/apk/arch
	touch $(1)/etc/apk/world
endef

define Package/alpine-keys/install
	$(INSTALL_DIR) $(1)/etc/apk/keys
	$(INSTALL_DATA) ./files/alpine-keys/* $(1)/etc/apk/keys
endef

define Package/alpine-repositories/install
	$(INSTALL_DIR) $(1)/etc/apk/keys
	$(INSTALL_DATA) ./files/alpine-repositories $(1)/etc/apk/repositories
endef

$(eval $(call BuildPackage,apk))
$(eval $(call BuildPackage,alpine-keys))
$(eval $(call BuildPackage,alpine-repositories))
$(eval $(call HostBuild))
