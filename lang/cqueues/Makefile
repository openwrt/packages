#
# Copyright (C) 2022 Siger Yang <siger.yang@outlook.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=cqueues
PKG_VERSION:=20200726
PKG_RELEASE:=1
PKG_MAINTAINER:=Siger Yang <siger.yang@outlook.com>

PKG_MIRROR_HASH:=214a09c250e92d12cd63cdaedce9491f874a920e8222cc4faf10a978ec7bd1bd
PKG_SOURCE_URL:=https://github.com/wahern/cqueues.git
PKG_SOURCE_VERSION:=rel-$(PKG_VERSION)
PKG_SOURCE_PROTO:=git

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/cqueues
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=lua cqueues
  URL:=http://25thandclement.com/~william/projects/cqueues.html
  DEPENDS:=+liblua +libopenssl
endef

define Package/cqueues/description
 Continuation Queues: Embeddable asynchronous networking, threading, and
 notification framework for Lua on Unix. 
endef

TARGET_CFLAGS += $(FPIC)
TARGET_LDFLAGS += $(FPIC)

MAKE_FLAGS += \
	LUA_APIS="5.1" \
	lua51cpath="/usr/lib/lua" \
	lua51path="/usr/lib/lua"

define Package/cqueues/install
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/lua/_cqueues.so $(1)/usr/lib/lua/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/lua/cqueues.lua $(1)/usr/lib/lua/

	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lua/cqueues $(1)/usr/lib/lua/
endef

$(eval $(call BuildPackage,cqueues))
