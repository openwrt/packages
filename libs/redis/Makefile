include $(TOPDIR)/rules.mk

PKG_NAME:=redis
PKG_VERSION:=8.8.0
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://download.redis.io/releases/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=88422181efb0c9c0abba332e3e391d409e1e13714b838931669235e5796f704b

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
# Redis 8.x is tri-licensed: RSALv2 / SSPLv1 / AGPL-3.0. Pick AGPL-3.0
# as the canonical SPDX identifier and document the choice for downstream
# consumers in the package description. (Redis <= 7.2 was BSD-3-Clause.)
PKG_LICENSE:=AGPL-3.0-only
PKG_LICENSE_FILES:=LICENSE.txt
PKG_CPE_ID:=cpe:/a:redis:redis

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

MAKE_FLAGS+= \
	MALLOC="libc" \
	USE_JEMALLOC="no" \
	PREFIX="$(PKG_INSTALL_DIR)/usr" \
	ARCH=""

# The bundled vector-sets module is 32-bit-incompatible: it fails to initialize
# and aborts redis-server at startup. redis' own build passes SKIP_VEC_SETS=yes
# for 32-bit targets, so do the same here.
ifeq ($(CONFIG_ARCH_64BIT),)
  MAKE_FLAGS += SKIP_VEC_SETS=yes
endif

# redis 8.x builds with -Werror -pedantic -Werror=deprecated-declarations,
# which the musl fortify wrappers trip (void-returning bcopy, deprecated
# sprintf/strcpy/strcat); demote both diagnostics from error to warning.
TARGET_CFLAGS += -Wno-error=pedantic -Wno-error=deprecated-declarations

TARGET_LDFLAGS += -latomic

define Package/redis/Default
  SUBMENU:=Database
  SECTION:=libs
  CATEGORY:=Libraries
  URL:=https://redis.io
endef

define Package/redis-server
$(call  Package/redis/Default)
  TITLE:=Redis server
  DEPENDS:=+libpthread +libatomic
endef

define Package/redis-cli
$(call  Package/redis/Default)
  TITLE:=Redis cli
  DEPENDS+=+libatomic
endef

define Package/redis-utils
$(call  Package/redis/Default)
  TITLE:=Redis utilities
  DEPENDS:=+redis-server
endef

define Package/redis-full
$(call  Package/redis/Default)
  TITLE:=All Redis binaries (server,cli and utils)
  DEPENDS:=+redis-utils +redis-cli
  BUILDONLY:=1
endef

define Package/redis-full/description
  Redis is an open source, advanced key-value cache and store. Redis 8.x is
  tri-licensed under RSALv2 / SSPLv1 / AGPL-3.0; this package builds it under
  AGPL-3.0. It is often referred to as a data structure server since keys can
  contain strings, hashes, lists, sets, sorted sets, bitmaps and hyperloglogs.
endef

define Package/redis-server/conffiles
/etc/redis.conf
endef

define Build/Compile
	$(MAKE) -C "$(PKG_BUILD_DIR)/deps/hiredis" static $(MAKE_FLAGS)  $(MAKE_VARS)
	$(MAKE) -C "$(PKG_BUILD_DIR)/deps/linenoise" $(MAKE_FLAGS)  $(MAKE_VARS)
	$(MAKE) -C "$(PKG_BUILD_DIR)/deps/lua" posix $(MAKE_FLAGS)  $(MAKE_VARS) AR="${AR} ru"
	$(call Build/Compile/Default)
endef

define Package/redis-server/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/redis-server $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/redis.init $(1)/etc/init.d/redis
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/redis.conf $(1)/etc/
	$(SED) "s|^dir .*|dir /var/lib/redis|" $(1)/etc/redis.conf
endef

define Package/redis-cli/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/redis-cli $(1)/usr/bin/
endef

define Package/redis-utils/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/redis-{check-aof,benchmark} $(1)/usr/bin/
endef

$(eval $(call BuildPackage,redis-full))
$(eval $(call BuildPackage,redis-server))
$(eval $(call BuildPackage,redis-cli))
$(eval $(call BuildPackage,redis-utils))
