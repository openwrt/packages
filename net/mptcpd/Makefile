include $(TOPDIR)/rules.mk

PKG_NAME:=mptcpd
PKG_VERSION:=0.12
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/multipath-tcp/mptcpd/releases/download/v$(PKG_VERSION)
PKG_HASH:=0507d497383b773a168cd35f4680b41894fcd8d941cb6619800a8e2bed831cbe

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=BSD-3-clause
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_DEPENDS:=USE_MUSL:argp-standalone
PKG_BUILD_PARALLEL:=1
PKG_CHECK_FORMAT_SECURITY:=0
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += --with-kernel=upstream

define Package/mptcpd/Default
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+ell
  URL:=https://github.com/multipath-tcp/mptcpd
endef

define Package/mptcpd
  $(call Package/mptcpd/Default)
  TITLE:=Multipath TCP Daemon
endef

define Package/mptcpize
  $(call Package/mptcpd/Default)
  TITLE:=Multipath TCP wrapper
endef

define Package/mptcpd/conffiles
/etc/mptcpd/mptcpd.conf
endef

define Package/mptcpd/install
	$(INSTALL_DIR) $(1)/etc/mptcpd
	$(CP) $(PKG_INSTALL_DIR)/etc/mptcpd/mptcpd.conf $(1)/etc/mptcpd
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mptcpd $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib/mptcpd
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libmptcpd.so* $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/mptcpd/*.so $(1)/usr/lib/mptcpd
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/mptcpd.init $(1)/etc/init.d/mptcpd
endef

define Package/mptcpize/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/mptcpize $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib/mptcpize
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/mptcpize/libmptcpwrap.so* $(1)/usr/lib/mptcpize
endef

$(eval $(call BuildPackage,mptcpd))
$(eval $(call BuildPackage,mptcpize))
