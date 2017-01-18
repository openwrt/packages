#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=redis
PKG_VERSION:=3.2.6
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://download.redis.io/releases/
PKG_MD5SUM:=d0e81d1e19f673fd84d01784bf9fb5f0

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

MAKE_FLAGS+= \
	MALLOC="libc" \
	PREFIX="$(PKG_INSTALL_DIR)/usr"

TARGET_LDFLAGS += -L$(STAGING_DIR)/usr/lib/

define Package/redis
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Advanced key-value cache and store
  DEPENDS:=+libpthread
  URL:=http://redis.io
endef

define Package/redis/description
	Redis is an open source, BSD licensed, advanced key-value cache and store.
	It is often referred to as a data structure server since keys can contain
	strings, hashes, lists, sets, sorted sets, bitmaps and hyperloglogs.
endef

define Package/redis/conffiles
/etc/redis.conf
endef

define Build/Compile
	sed -e 's#^\(REAL_CFLAGS.* \)$$$$(ARCH)#\1#g' -i $(PKG_BUILD_DIR)/deps/hiredis/Makefile
	# sed -e 's#^\([[:space:]]*$$$$(AR)\)#\1 rcu#g' -i $(PKG_BUILD_DIR)/deps/lua/src/Makefile
	#
	# if you want to build jemalloc support un-comment out the next line
	# sed -i '/enable-cc-silence/ s|$$$$| --host=$(REAL_GNU_TARGET_NAME) --target=$(REAL_GNU_TARGET_NAME)|' \
		$(PKG_BUILD_DIR)/deps/Makefile
	$(call Build/Compile/Default,-C $(PKG_BUILD_DIR)/deps hiredis lua linenoise PLAT=linux)
	$(call Build/Compile/Default)
endef

define Package/redis/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/$(PKG_NAME)-cli $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/$(PKG_NAME)-server $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/$(PKG_NAME)-check-aof $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/$(PKG_NAME)-check-rdb $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/$(PKG_NAME)-benchmark $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/redis.init $(1)/etc/init.d/redis
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DATA) ./files/redis.conf $(1)/etc
endef

$(eval $(call BuildPackage,redis))
