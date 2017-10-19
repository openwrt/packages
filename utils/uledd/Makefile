include $(TOPDIR)/rules.mk

PKG_NAME:=uledd
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/blogic/uledd.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=bc94c7e52009f7ec33b23652502b4754351d8040
PKG_MIRROR_HASH:=23a407197d6a423bb0b32f381e93ad3676e15f07465d7b53c843a2b510c7c284
PKG_MAINTAINER:=John Crispin <john@phrozen.org>
PKG_LICENSE:=GPL-2.0

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/uledd
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libubox +libubus
  TITLE:=PWM/RGB LED ubus frontend
endef

define Package/uledd/install
	$(INSTALL_DIR) $(1)/sbin $(1)/etc/init.d

	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/uledd $(1)/sbin/
	$(INSTALL_BIN) ./files/uledd.init $(1)/etc/init.d/uledd
endef

$(eval $(call BuildPackage,uledd))
