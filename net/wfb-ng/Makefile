include $(TOPDIR)/rules.mk

PKG_NAME:=wfb-ng
PKG_VERSION:=24.09.23
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/svpcom/wfb-ng/tar.gz/$(PKG_NAME)-$(PKG_VERSION)?
PKG_HASH:=c6cf669090952f6e430166a23b2fd787c6f7d4fd2d8d1996e8e3713f5cc4f8d9
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_NAME)-$(PKG_VERSION)

PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Vasily Evseenko <svpcom@p2ptech.org>

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

MAKE_FLAGS += VERSION=$(PKG_VERSION)-$(PKG_RELEASE) COMMIT=openwrt all_bin

define Package/wfb-ng
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Wireless
  TITLE:=Long-range packet radio link using raw WiFi
  URL:=https://github.com/svpcom/wfb-ng
  DEPENDS:=+libpcap +libsodium +libstdcpp
endef

define Package/wfb-ng/description
  The next generation of long-range packet radio link using raw WiFi
  This is a base version that have only binaries and can act as cluster node,
  standalone receiver or transmitter without diversity.
endef

define Package/wfb-ng/conffiles
/usr/sbin/wfb-ng.sh
endef

define Package/wfb-ng/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wfb_rx $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wfb_tx $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/wfb-ng.init $(1)/etc/init.d/wfb-ng
endef

$(eval $(call BuildPackage,wfb-ng))
