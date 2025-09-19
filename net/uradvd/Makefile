include $(TOPDIR)/rules.mk

PKG_NAME:=uradvd
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/freifunk-gluon/uradvd.git
PKG_SOURCE_VERSION:=1e64364d323acb8c71285a6fb85d384334e7007d
PKG_MIRROR_HASH:=f16519b85332c03c3147f7eaecdc656186d5ae530b0ad550b48a42f39d40acc7
PKG_VERSION:=26~$(call version_abbrev,$(PKG_SOURCE_VERSION))

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

define Build/Compile
	$(call Build/Compile/Default,VERSION=r$(subst ~,-,$(PKG_VERSION)))
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
