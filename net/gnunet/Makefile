#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gnunet
PKG_SOURCE_VERSION:=35845
PKG_VERSION:=0.10.1-svn$(PKG_SOURCE_VERSION)
PKG_RELEASE:=1

# ToDo:
#  - split into small packages
#  - create meta-packages for common setups
#  - allow building with mysql or postgresql

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://gnunet.org/svn/gnunet/
PKG_SOURCE_PROTO:=svn

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS+= \
	--disable-rpath \
	--with-extractor=$(STAGING_DIR)/usr \
	--with-gnutls=$(STAGING_DIR)/usr \
	--with-libgnurl=$(STAGING_DIR)/usr \
	--with-libunistring-prefix=$(STAGING_DIR)/usr \
	--with-ltdl \
	--with-microhttpd=$(STAGING_DIR)/usr \
	--without-mysql \
	--without-postgresql

TARGET_LDFLAGS+= -Wl,-rpath-link=$(STAGING_DIR)/usr/lib/pulseaudio

define Package/gnunet
  SECTION:=net
  CATEGORY:=Network
  TITLE:=GNUnet peer-to-peer framework focusing on security
  DEPENDS:=+bluez-libs +ca-certificates +certtool +libextractor +libgst1app  \
           +libgst1audio +glib2 +kmod-tun +libglpk +libgnurl +libgnutls      \
           +libgstreamer1 +libidn +libmicrohttpd +libopus +libogg            \
           +libunistring +libsqlite3 +pulseaudio-daemon +openssl-util
  URL:=https://www.gnunet.org/
  USERID:=gnunet=400:gnunet=400
endef

define Package/gnunet/description
 GNUnet is peer-to-peer framework focusing on security.  The first and
 primary application for GNUnet is anonymous file-sharing.  GNUnet is
 currently developed by a worldwide group of independent free software
 developers.  GNUnet is a GNU package (http://www.gnu.org/).

 This is an ALPHA release.  There are known and significant bugs as
 well as many missing features in this release.
endef

define Package/gnunet/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/lib/gnunet/libexec
	$(INSTALL_DIR) $(1)/usr/share/gnunet/config.d $(1)/usr/share/gnunet/hellos
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/gnunet/*.so $(1)/usr/lib/gnunet
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/gnunet/libexec/* $(1)/usr/lib/gnunet/libexec
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/gnunet/*.html $(1)/usr/share/gnunet
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/gnunet/*.png $(1)/usr/share/gnunet
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/gnunet/hellos/* $(1)/usr/share/gnunet/hellos
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/gnunet/config.d/* $(1)/usr/share/gnunet/config.d
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/gnunet.init $(1)/etc/init.d/gnunet
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/gnunet $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.{la,so}* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/*.pc $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/include/gnunet/*.h $(1)/usr/include/gnunet
endef

$(eval $(call BuildPackage,gnunet))
