include $(TOPDIR)/rules.mk

PKG_NAME:=uradvd
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/freifunk-gluon/uradvd.git
PKG_SOURCE_VERSION:=3cc2f33623f025da152890aae8afd3ecdaa15e56
PKG_MIRROR_HASH:=e1d7d51a2ed9bf272fad6ccf079ccea5a6d99fedeacb73850d3e99c816bf3fee
PKG_VERSION:=21~3cc2f336

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
	$(call Build/Compile/Default,VERSION=$(PKG_VERSION))
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
