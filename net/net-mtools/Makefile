include $(TOPDIR)/rules.mk

PKG_NAME:=net-mtools
PKG_VERSION:=3.2
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/troglobit/mtools
PKG_SOURCE_VERSION:=262053773a43eb38cb708b9f0877ece0fe5b55d2
PKG_MIRROR_HASH:=bf0d24919a0f9dd5f902a2cb3de133705e25c8d84e637e508a0d512d52c8ef9d

include $(INCLUDE_DIR)/package.mk

define Package/net-mtools
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Debug multicast setups with mtools (msend and mreceive)
  URL:=https://github.com/troglobit/mtools
endef

define Package/net-mtools/description
  The tools msend and mreceive can be particularly useful
  when debugging multicast setups.

  msend continuously sends UDP packets to the multicast
  group specified by the -g and -p options.

  mreceive joins a multicast group specified by the -g and
  -p options, then receives and displays the multicast
  packets sent to this group:port combination by the msend
  command.
endef

define Package/net-mtools/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_BUILD_DIR)/msend $(1)/usr/sbin/
	$(CP) $(PKG_BUILD_DIR)/mreceive $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,net-mtools))
