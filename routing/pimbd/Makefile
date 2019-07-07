include $(TOPDIR)/rules.mk

PKG_NAME:=pimbd
PKG_SOURCE_VERSION:=dbf4e5913b06e3160f506df15e6a047a403a5f21
PKG_VERSION:=2018-06-19-$(PKG_SOURCE_VERSION)
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/Oryon/pimbd.git
PKG_MAINTAINER:=Pierre Pfister <pierre.pfister@darou.fr>
PKG_LICENSE:=Apache-2.0

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

# Spammy debug builds for now
CMAKE_OPTIONS += -DL_LEVEL=7 \
		 -DWITH_LIBUBOX=1

define Package/pimbd
  SECTION:=net
  CATEGORY:=Network
  TITLE:=PIM BIDIR daemon
  URL:=https://github.com/Oryon/pimbd.git
  DEPENDS+=@IPV6
  DEPENDS+=netifd
endef

define Package/pimbd/description
This package provides a daemon which implements the Protocol Independent
Multicast BIDIR routing protocol. Note that a routing protocol must be 
installed and running in order for PIM to function.
endef

define Package/pimbd/install
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/pimbd $(1)/usr/sbin/pimbd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/generic/pimbc.sh $(1)/usr/sbin/pimbc
	ln -s pimbd $(1)/usr/sbin/pimb-ipc
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/pimbd.init $(1)/etc/init.d/pimbd
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) files/firewall-uci.sh $(1)/etc/uci-defaults/99_pimbd_firewall
endef

$(eval $(call BuildPackage,pimbd))
