include $(TOPDIR)/rules.mk

PKG_NAME:=uradvd
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/freifunk-gluon/uradvd.git
PKG_SOURCE_DATE:=2025-08-16
PKG_SOURCE_VERSION:=b37524dfb0292c425fd61f5bffb3101fb1979264
PKG_MIRROR_HASH:=1f681e2baf6f9b825668aeed9c075f532db509d7d1848e76f3e8101acf2bd476

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
	$(INSTALL_CONF) ./files/uradvd.config $(1)/etc/config/uradvd
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/uradvd.init $(1)/etc/init.d/uradvd
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/uradvd $(1)/usr/sbin/
endef

define Package/uradvd/conffiles
/etc/config/uradvd
endef

$(eval $(call BuildPackage,uradvd))
