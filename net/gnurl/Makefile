#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gnurl
PKG_VERSION:=7.57.0
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://gnunet.org/sites/default/files

PKG_HASH:=2ccd2a641a9815df924b6a79ee47d12a27ee43bd05a3c6ba958108564580d3b7

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/gnurl/Default
  SECTION:=net
  CATEGORY:=Network
  URL:=https://gnunet.org/gnurl
  MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
endef

define Package/gnurl
  $(call Package/gnurl/Default)
  SUBMENU:=File Transfer
  DEPENDS:=+libgnurl
  TITLE:=A client-side HTTP/HTTPS transfer utility
endef

define Package/libgnurl
  $(call Package/gnurl/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libgnutls +libidn2 +zlib
  TITLE:=A client-side HTTP/HTTPS transfer library
endef

TARGET_CFLAGS += $(FPIC)

CONFIGURE_ARGS += \
	$(call autoconf_bool,CONFIG_IPV6,ipv6) \
	--with-gnutls="$(STAGING_DIR)/usr" \
	--with-libidn="$(STAGING_DIR)/usr" \
	--with-zlib="$(STAGING_DIR)/usr" \
	--with-ca-path="/etc/ssl/certs/" \
	--enable-shared \
	--enable-static \
	--without-axtls \
	--without-libssh2 \
	--without-libmetalink \
	--without-winidn \
	--without-librtmp \
	--without-nghttp2 \
	--without-nss \
	--without-cyassl \
	--without-polarssl \
	--without-ssl \
	--without-winssl \
	--without-darwinssl \
	--disable-ares \
	--disable-sspi \
	--disable-ntlm-wb \
	--disable-ldap \
	--disable-ldaps \
	--disable-rtsp \
	--disable-dict \
	--disable-telnet \
	--disable-tftp \
	--disable-pop3 \
	--disable-imap \
	--disable-smtp \
	--disable-gopher \
	--disable-file \
	--disable-ftp \
	--disable-smb \
	--disable-debug \
	--disable-manual \
	--disable-verbose

define Build/Compile
	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		CC="$(TARGET_CC)" \
		install
endef

define Build/InstallDev
	$(INSTALL_DIR) $(2)/bin $(1)/usr/bin $(1)/usr/include/gnurl $(1)/usr/lib $(1)/usr/lib/pkgconfig
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gnurl-config $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/gnurl/*.h $(1)/usr/include/gnurl
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgnurl.{a,so*} $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/libgnurl.pc $(1)/usr/lib/pkgconfig/
	$(SED) 's,-L$$$${exec_prefix}/lib,,g' $(1)/usr/bin/gnurl-config
	[ -n "$(TARGET_LDFLAGS)" ] && $(SED) 's#$(TARGET_LDFLAGS)##g' $(1)/usr/lib/pkgconfig/libgnurl.pc || true
	$(LN) $(STAGING_DIR)/usr/bin/gnurl-config $(2)/bin/
endef

define Package/gnurl/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gnurl $(1)/usr/bin/
endef

define Package/libgnurl/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgnurl.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,gnurl))
$(eval $(call BuildPackage,libgnurl))
