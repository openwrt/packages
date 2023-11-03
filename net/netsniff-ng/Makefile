include $(TOPDIR)/rules.mk

PKG_NAME:=netsniff-ng
PKG_VERSION:=0.6.8
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/netsniff-ng/netsniff-ng/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=4bbd8e286aee929d5f71788d226938e0ad6a7873f882412221a240faa2439a45

PKG_MAINTAINER:=Toni Uhlig <matzeton@googlemail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_FLAGS:=no-mips16
PKG_BUILD_PARALLEL:=1

PKG_CONFIG_DEPENDS:= \
	CONFIG_PACKAGE_mausezahn \
	CONFIG_PACKAGE_netsniff-ng

include $(INCLUDE_DIR)/package.mk

define Package/netsniff-ng/Default
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libpthread +libpcap
  URL:=https://github.com/netsniff-ng/netsniff-ng
endef

define Package/netsniff-ng
  $(call Package/netsniff-ng/Default)
  DEPENDS+=+libncurses +libnetfilter-conntrack +libsodium +liburcu +zlib
  TITLE:=netsniff-ng
endef

define Package/netsniff-ng/description
	netsniff-ng is a free, performant Linux network analyzer and
	networking toolkit. If you will, the Swiss army knife for network
	packets.
endef

define Package/mausezahn
  $(call Package/netsniff-ng/Default)
  DEPENDS+=+libcli +libnet-1.2.x
  TITLE:=mausezahn
endef

define Package/mausezahn/description
	Mausezahn is a traffic generator written which allows sending
	nearly every possible and impossible packet. It is mainly used
	to test VoIP or multicast networks.
endef

define Build/Configure
	( cd $(PKG_BUILD_DIR); \
	  CC="$(TARGET_CC)" \
	  LD="$(TARGET_LD)" \
	  CFLAGS="$(TARGET_CFLAGS)" \
	  LDFLAGS="$(TARGET_LDFLAGS)" \
	  CROSS_COMPILE="$(REAL_GNU_TARGET_NAME)-" \
	  ./configure --prefix=/usr --disable-geoip --disable-libnl )
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) Q= \
	  CC="$(TARGET_CC)" \
	  LD="$(TARGET_LD)" \
	  CFLAGS="$(TARGET_CFLAGS)" \
	  LDFLAGS="$(TARGET_LDFLAGS)" \
	  CROSS_COMPILE="$(REAL_GNU_TARGET_NAME)-"
endef

define Package/netsniff-ng/install
	$(INSTALL_DIR) $(1)/etc/netsniff-ng
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_BUILD_DIR)/ether.conf $(1)/etc/netsniff-ng
	$(CP) $(PKG_BUILD_DIR)/tcp.conf $(1)/etc/netsniff-ng
	$(CP) $(PKG_BUILD_DIR)/udp.conf $(1)/etc/netsniff-ng
	$(CP) $(PKG_BUILD_DIR)/oui.conf $(1)/etc/netsniff-ng
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/netsniff-ng/netsniff-ng $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/trafgen/trafgen $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/astraceroute/astraceroute $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/flowtop/flowtop $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ifpps/ifpps $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bpfc/bpfc $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/curvetun/curvetun $(1)/usr/sbin/
endef

define Package/mausezahn/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mausezahn/mausezahn $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,netsniff-ng))
$(eval $(call BuildPackage,mausezahn))
