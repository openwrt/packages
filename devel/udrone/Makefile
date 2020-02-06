include $(TOPDIR)/rules.mk

PKG_NAME:=udrone
PKG_VERSION:=839eee4c6fbb85d17528cfd23d5c9cde902f622d
PKG_SOURC_DATE:=2020-02-10
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://codeload.github.com/blogic/udrone/tar.gz/$(PKG_VERSION)?
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=0e9a9193f25ae331b900d3557ddb0427325bb2132b672ebf69be3d8ad5e6a1f3

PKG_MAINTAINER:=John Crispin <john@phrozen.org>, Paul Spooren <mail@aparcar.org>
PKG_LICENSE:=GPL-2.0-or-later

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/udrone
  SECTION:=devel
  CATEGORY:=Development
  TITLE:=OpenWrt QA Daemon
  DEPENDS:=+libjson-c +libubox +libblobmsg-json +libubus +libuci
endef

TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include

define Package/udrone/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/udrone $(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/init $(1)/etc/init.d/udrone
endef

$(eval $(call BuildPackage,udrone))
