
include $(TOPDIR)/rules.mk

PKG_SOURCE_URL:=https://github.com/RomanHargrave/n2n-v2
PKG_SOURCE_VERSION:=2ea679c
PKG_NAME:=n2n
PKG_VERSION:=2.1_git$(PKG_SOURCE_VERSION)
PKG_RELEASE:=1
PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Roman Hargrave <roman+contact@hargrave.info>
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_SOURCE_SUBDIR).tar.gz
PKG_SOURCE_PROTO:=git

include $(INCLUDE_DIR)/package.mk

define Package/n2n/Default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=N2Nv2
  URL:=http://www.ntop.org/n2n/
  SUBMENU:=VPN
  DEPENDS:=+kmod-tun +resolveip +libopenssl
endef

define Package/n2n-edge
$(call Package/n2n/Default)
TITLE+= client (edge)
endef

define Package/n2n-supernode
$(call Package/n2n/Default)
TITLE+= server (supernode)
endef

define Package/n2n-edge/description
N2Nv2 client (edge).
endef

define Package/n2n-supernode/description
N2Nv2 server (supernode).
endef

define Build/Compile
		$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		INSTALL_PROG=":"
endef

define Package/n2n-edge/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/edge $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/lib/netifd/proto
	$(INSTALL_BIN) ./files/n2n.sh $(1)/lib/netifd/proto
endef

define Package/n2n-supernode/conffiles
/etc/config/n2n
endef

define Package/n2n-supernode/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/supernode $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/n2n.init $(1)/etc/init.d/n2n
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/n2n.config $(1)/etc/config/n2n
endef

$(eval $(call BuildPackage,n2n-edge))
$(eval $(call BuildPackage,n2n-supernode))
