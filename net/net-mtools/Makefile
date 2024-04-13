include $(TOPDIR)/rules.mk

PKG_NAME:=net-mtools
PKG_VERSION:=2.3
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/troglobit/mtools
PKG_SOURCE_VERSION:=db665a4303c38cee908eba4dac50873c3f1d899c
PKG_MIRROR_HASH:=a554990482054b26a207dc9eb6ed5685eb228773cc07f45fb2d37fca59122ca0

include $(INCLUDE_DIR)/package.mk

define Package/net-mtools
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Debug multicast setups with mtools (msend and mreceive)
  URL:=https://github.com/troglobit/mtools
endef

define Package/net-mtools/description
  The tools msend and mreceive can be particulary useful
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
