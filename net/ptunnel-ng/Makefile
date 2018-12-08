include $(TOPDIR)/rules.mk

PKG_NAME:=ptunnel-ng
PKG_VERSION:=1.31
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/lnslbrty/ptunnel-ng/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=8324741f55aae8ccee6800912662a429774378088d81028a5f3f62f3ea9edaf4

PKG_LICENSE:=BSD-3
PKG_LICENSE_FILES:=COPYING
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/ptunnel-ng
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libpthread
  TITLE:=PingTunnel [N]ew[G]eneration
  MAINTAINER:=Toni Uhlig <matzeton@googlemail.com>
  URL:=https://github.com/lnslbrty/ptunnel-ng
endef

define Package/ptunnel-ng/description
	Tunnel TCP connections through ICMP.
endef

CONFIGURE_ARGS += \
	--disable-pcap \
	--disable-selinux

define Package/ptunnel-ng/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/$(PKG_NAME) $(1)/usr/sbin/$(PKG_NAME)
endef

$(eval $(call BuildPackage,ptunnel-ng))
