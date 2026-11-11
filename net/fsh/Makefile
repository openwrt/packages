include $(TOPDIR)/rules.mk

PKG_NAME:=fsh
PKG_VERSION:=4.12.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/heiher/hev-fsh/releases/download/$(PKG_VERSION)
PKG_HASH:=43f4c9c4ca726f8c04e727b7c4e2ef740c358b46b0f90f26714a599101af5ff4

PKG_MAINTAINER:=Ray Wang <git@hev.cc>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=License

PKG_BUILD_FLAGS:=no-mips16
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/fsh
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Fsh helps you access local shell and TCP services behind a NAT or firewall
  URL:=https://github.com/heiher/hev-fsh
endef

define Package/fsh/conffiles
/etc/config/fsh
endef

define Package/fsh/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/hev-fsh $(1)/usr/bin/fsh
	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_CONF) ./files/fsh.config $(1)/etc/config/fsh
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/fshs.init $(1)/etc/init.d/fshs
	$(INSTALL_BIN) ./files/fshc.init $(1)/etc/init.d/fshc
endef

$(eval $(call BuildPackage,fsh))
