#
# Copyright (C) 2009-2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luasocket
PKG_SOURCE_DATE:=2019-04-21
PKG_SOURCE_VERSION:=733af884f1aa18ff469bf3c4d18810e815853211
PKG_RELEASE:=1

PKG_MIRROR_HASH:=60aef7544426cae3e6c7560a6e4ad556a04b879ca0ad0311645b2c513c872128
PKG_SOURCE_URL:=https://github.com/diegonehab/luasocket
PKG_SOURCE_PROTO:=git

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/luasocket5.3
  SUBMENU:=Lua
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=LuaSocket 5.3
  URL:=http://w3.impa.br/~diego/software/luasocket
  DEPENDS:=+liblua5.3
endef

define Package/luasocket5.3/description
  LuaSocket is the most comprehensive networking support
  library for the Lua language. It provides easy access to
  TCP, UDP, DNS, SMTP, FTP, HTTP, MIME and much more.  This
  version supports lua5.3
endef

define Build/Configure
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/ \
		LIBDIR="$(TARGET_LDFLAGS)" \
		CC="$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_CPPFLAGS) $(FPIC)" \
		LD="$(TARGET_CROSS)ld -shared" \
		LUAV=5.3 LUAINC_linux_base=$(STAGING_DIR)/usr/include \
		all
endef

define Package/luasocket5.3/install
	$(MAKE) -C $(PKG_BUILD_DIR)/src \
		DESTDIR="$(1)" \
		LUAV=5.3 \
		install
endef

$(eval $(call BuildPackage,luasocket5.3))
