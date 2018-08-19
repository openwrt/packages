include $(TOPDIR)/rules.mk

PKG_NAME:=rpcbind
PKG_VERSION:=1.2.5
PKG_RELEASE:=1

PKG_SOURCE_URL:=@SF/rpcbind
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_HASH:=2ce360683963b35c19c43f0ee2c7f18aa5b81ef41c3fdbd15ffcb00b8bffda7a

PKG_MAINTAINER:=Andy Walsh <andy.walsh44+github@gmail.com>
PKG_LICENSE:=BSD-3-Clause

PKG_FIXUP:=autoreconf
PKG_REMOVE_FILES:=autogen.sh aclocal.m4
PKG_INSTALL:=1

PKG_CONFIG_DEPENDS:= \
	CONFIG_RPCBIND_LIBWRAP \
	CONFIG_RPCBIND_WARMSTARTS

include $(INCLUDE_DIR)/package.mk

define Package/rpcbind
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libtirpc +RPCBIND_LIBWRAP:libwrap
  TITLE:=Universal addresses to RPC mapper
  URL:=http://rpcbind.sourceforge.net/
  USERID:=rpc=65533:rpc=65533
endef

define Package/rpcbind/description
  The rpcbind utility is a server that converts RPC program numbers into universal addresses.
  It must be running on the host to be able to make RPC calls on a server on that machine.

  Rpcbind replaces portmap for NFS v2/v3. It has more features, like ipv6 support.
  Note: Nfs4 only configurations can run without it.
endef

define Package/rpcbind/config
if PACKAGE_rpcbind
	config RPCBIND_LIBWRAP
		bool "Enable libwrap (TCP wrappers) support."
		default y

	config RPCBIND_WARMSTARTS
		bool "Enable warmstarts support"
		default y
		help
		  The warmstart feature saves RPC registrations on termination.
endif
endef

CONFIGURE_ARGS += \
	--with-rpcuser=rpc \
	--without-systemdsystemunitdir

ifeq ($(CONFIG_RPCBIND_LIBWRAP),y)
	CONFIGURE_ARGS += --enable-libwrap
else
	CONFIGURE_ARGS += --disable-libwrap
endif
ifeq ($(CONFIG_RPCBIND_WARMSTARTS),y)
	CONFIGURE_ARGS += --enable-warmstarts
endif

define Package/rpcbind/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/rpcinfo $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/rpcbind $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/rpcbind.init $(1)/etc/init.d/rpcbind
endef

$(eval $(call BuildPackage,rpcbind))
