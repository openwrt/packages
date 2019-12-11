include $(TOPDIR)/rules.mk

PKG_NAME:=uledd
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/blogic/uledd.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=b7abc41ac4e04131e5a81f0f1de4e4ffb6ae16eb
PKG_MIRROR_HASH:=751d6336619f282aa571cbd3aa64df9b326da74fc56477a425d49cb2b0a12aea
PKG_MAINTAINER:=John Crispin <john@phrozen.org>
PKG_LICENSE:=LGPL-2.1-only

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/uledd
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libubox +libubus +libblobmsg-json +libjson-c
  TITLE:=PWM/RGB LED ubus frontend
endef

define Package/uledd/install
	$(INSTALL_DIR) $(1)/sbin $(1)/etc/init.d

	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/uledd $(1)/sbin/
	$(INSTALL_BIN) ./files/uledd.init $(1)/etc/init.d/uledd
endef

$(eval $(call BuildPackage,uledd))
