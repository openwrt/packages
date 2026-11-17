#
# Copyright (C) 2022 Siger Yang <siger.yang@outlook.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=cqueues
PKG_VERSION:=20200726
PKG_RELEASE:=3
PKG_MAINTAINER:=Siger Yang <siger.yang@outlook.com>

PKG_MIRROR_HASH:=214a09c250e92d12cd63cdaedce9491f874a920e8222cc4faf10a978ec7bd1bd
PKG_SOURCE_URL:=https://github.com/wahern/cqueues.git
PKG_SOURCE_VERSION:=rel-$(PKG_VERSION)
PKG_SOURCE_PROTO:=git

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/cqueues/default
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=cqueues for $(1)
  URL:=https://25thandclement.com/~william/projects/cqueues.html
  DEPENDS:=+libopenssl
endef

define Package/cqueues/default/description
 Continuation Queues: Embeddable asynchronous networking, threading, and
 notification framework for Lua on Unix. 
endef

TARGET_CFLAGS += $(FPIC)
TARGET_LDFLAGS += $(FPIC)

define Package/cqueues
  $(call Package/cqueues/default,lua5.1)
  DEPENDS+=+liblua
  VARIANT:=lua51
endef

define Package/cqueues-lua5.3
  $(call Package/cqueues/default,lua5.3)
  DEPENDS+=+liblua5.3
  VARIANT:=lua53
endef

define Package/cqueues-lua5.4
  $(call Package/cqueues/default,lua5.4)
  DEPENDS+=+liblua5.4
  VARIANT:=lua54
endef

Package/cqueues/description = $(Package/cqueues/default/description)
Package/cqueues-lua5.3/description = $(Package/cqueues/default/description)
Package/cqueues-lua5.4/description = $(Package/cqueues/default/description)

ifeq ($(BUILD_VARIANT),lua51)
  MAKE_FLAGS += \
	LUA_APIS="5.1" \
	LUA51_CPPFLAGS="-I$(STAGING_DIR)/usr/include" \
	lua51cpath="/usr/lib/lua" \
	lua51path="/usr/lib/lua"
  LUA_INSTALL_DIR:=/usr/lib/lua
endif
ifeq ($(BUILD_VARIANT),lua53)
  MAKE_FLAGS += \
	LUA_APIS="5.3" \
	LUA53_CPPFLAGS="-I$(STAGING_DIR)/usr/include/lua5.3" \
	lua53cpath="/usr/local/lib/lua/5.3" \
	lua53path="/usr/local/lib/lua/5.3"
  LUA_INSTALL_DIR:=/usr/local/lib/lua/5.3
endif
ifeq ($(BUILD_VARIANT),lua54)
  MAKE_FLAGS += \
	LUA_APIS="5.4" \
	LUA54_CPPFLAGS="-I$(STAGING_DIR)/usr/include/lua5.4" \
	lua54cpath="/usr/lib/lua/5.4" \
	lua54path="/usr/lib/lua/5.4"
  LUA_INSTALL_DIR:=/usr/lib/lua/5.4
endif

define Package/cqueues/install
	$(INSTALL_DIR) $(1)$(LUA_INSTALL_DIR)
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)$(LUA_INSTALL_DIR)/_cqueues.so $(1)$(LUA_INSTALL_DIR)/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)$(LUA_INSTALL_DIR)/cqueues.lua $(1)$(LUA_INSTALL_DIR)/

	$(CP) $(PKG_INSTALL_DIR)$(LUA_INSTALL_DIR)/cqueues $(1)$(LUA_INSTALL_DIR)/
endef
Package/cqueues-lua5.3/install = $(Package/cqueues/install)
Package/cqueues-lua5.4/install = $(Package/cqueues/install)

$(eval $(call BuildPackage,cqueues))
$(eval $(call BuildPackage,cqueues-lua5.3))
$(eval $(call BuildPackage,cqueues-lua5.4))
