include $(TOPDIR)/rules.mk

PKG_NAME:=uradvd
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/freifunk-gluon/uradvd.git
PKG_SOURCE_DATE:=2021-09-14
PKG_SOURCE_VERSION:=9b0da60e27c67305d251b10163e388191d566d7a
PKG_MIRROR_HASH:=84221d0044dd1e622b26ace7cb316be613d3c863293379d551d2c5c280124ddb

PKG_MAINTAINER:=Moritz Warning <moritzwarning@web.de>
PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/uradvd
  SECTION:=net
  CATEGORY:=Network
  TITLE:=A tiny radvd
endef

define Package/uradvd/description
	 Advertise an IPv6 prefix/route via SLAAC.
endef

define Package/uradvd/install
	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_DATA) ./files/uradvd.config $(1)/etc/config/uradvd
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/uradvd.init $(1)/etc/init.d/uradvd
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/uradvd $(1)/usr/sbin/
endef

define Package/uradvd/conffiles
/etc/config/uradvd
endef

$(eval $(call BuildPackage,uradvd))
