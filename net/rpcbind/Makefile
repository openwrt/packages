include $(TOPDIR)/rules.mk

PKG_NAME:=rpcbind
PKG_VERSION:=0.2.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://downloads.sourceforge.net/rpcbind/
PKG_MD5SUM:=c8875246b2688a1adfbd6ad43480278d

PKG_LICENSE:=BSD-4c

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/rpcbind
	SECTION:=net
	CATEGORY:=Network
	DEPENDS:=+libtirpc
	TITLE:=Universal addresses to RPC program number mapper
	URL:=https://sourceforge.net/projects/rpcbind/
endef

define Package/rpcbind/description
 The rpcbind utility is a server that converts RPC program numbers into
 universal addresses. It must be running on the host to be able to make
 RPC calls on a server on that machine.
endef

CONFIGURE_ARGS += \
	--with-rpcuser=root \
	--without-systemdsystemunitdir

define Package/rpcbind/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/rpcbind $(1)/usr/bin/rpcbind
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/rpcinfo $(1)/usr/bin/rpcinfo
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/rpcbind $(1)/etc/init.d/rpcbind
endef

$(eval $(call BuildPackage,rpcbind))
