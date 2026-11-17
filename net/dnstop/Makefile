include $(TOPDIR)/rules.mk

PKG_NAME:=dnstop
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/measurement-factory/dnstop.git
PKG_SOURCE_DATE:=2018-05-22
PKG_SOURCE_VERSION:=a5a5d2e2ca9a433bb8f017682ac6f2085741bdf8
PKG_MIRROR_HASH:=2753a595026c02ea865a6bb7256fe2eebc5883df054bb4a956d33ff35045d546

PKG_MAINTAINER:=Ken Xu <windedge99@gmail.com>
PKG_LICENSE:=NLPL
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/dnstop
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libpcap +libncurses
  TITLE:=stay on top of your dns traffic
  URL:=http://dns.measurement-factory.com/tools/dnstop/
endef

define Package/dnstop/description
 dnstop is a libpcap application (like tcpdump) that displays various tables of DNS traffic on your network
endef

define Package/dnstop/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dnstop $(1)/usr/bin/
endef

$(eval $(call BuildPackage,dnstop))
