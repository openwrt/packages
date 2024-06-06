include $(TOPDIR)/rules.mk

PKG_NAME:=pdns-recursor
PKG_VERSION:=5.0.6
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://downloads.powerdns.com/releases/
PKG_HASH:=d90885d2abb7ddfe9741cd8fbf5b9ba6902296c77b2f51248779066591ef3f32

PKG_MAINTAINER:=Peter van Dijk <peter.van.dijk@powerdns.com>, Remi Gacogne <remi.gacogne@powerdns.com>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:powerdns:recursor

PKG_FIXUP:=autoreconf
PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include ../../lang/rust/rust-values.mk

define Package/pdns-recursor
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  USERID:=pdns:pdns
  TITLE:=PowerDNS Recursor
  DEPENDS:=+boost +boost-context +boost-filesystem +libatomic +liblua +libopenssl +libfstrm +libcurl
  URL:=https://www.powerdns.com/recursor.html
endef

define Package/pdns-recursor/description
  High-performance resolving name server, utilizing multiple
  processor and including Lua scripting capabilities.
endef

define Package/pdns-recursor/conffiles
/etc/powerdns/recursor.conf
/etc/init.d/pdns-recursor
endef

# not everything groks --disable-nls
DISABLE_NLS:=

CONFIGURE_ARGS += \
	--sysconfdir=/etc/powerdns \
	--with-lua=lua \
	--without-libcap \
	--without-libsodium \
	--without-net-snmp \
	--enable-dns-over-tls \
	--enable-reproducible \
	--disable-silent-rules

MAKE_VARS += RUSTC_TARGET_ARCH=$(RUSTC_TARGET_ARCH)
MAKE_VARS += RUST_TARGET=--target=$(RUSTC_TARGET_ARCH)

define Package/pdns-recursor/install
	$(INSTALL_DIR) $(1)/etc/powerdns
	$(INSTALL_CONF) ./files/recursor.conf-dist $(1)/etc/powerdns/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/pdns-recursor.init $(1)/etc/init.d/pdns-recursor
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/rec_control $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/pdns_recursor $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,pdns-recursor))
