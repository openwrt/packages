#
# Copyright (C) 2006-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=icecast
PKG_VERSION:=2.4.2
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=André Gaul <andre@gaul.io>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://downloads.xiph.org/releases/icecast/
PKG_MD5SUM:=55947c83d31dfcbbede58c9521c676f4

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

TREMOR_BUILD_DIR=$(PKG_BUILD_DIR)/libvorbisidec-1.2.0-dave
TREMOR_DIR=$(TREMOR_BUILD_DIR)/ipkg-install/usr

define Package/icecast
  SECTION:=multimedia
  CATEGORY:=Multimedia
  DEPENDS:=+libcurl +libxml2 +libxslt +libogg +libopenssl
  TITLE:=A streaming media server for Ogg/Vorbis and MP3 audio streams
  URL:=http://www.icecast.org/
endef

define Package/icecast/description
	Icecast is a streaming media server which currently supports Ogg
	Vorbis and MP3 audio streams. It can be used to create an Internet
	radio station or a privately running jukebox and many things in
	between. It is very versatile in that new formats can be added
	relatively easily and supports open standards for commuincation and
	interaction.
endef

define Build/Prepare
	$(Build/Prepare/Default)
	$(SUBMAKE) -f libvorbisidec.mk \
		BUILD_DIR="$(PKG_BUILD_DIR)" \
		V=99 \
		prepare
endef

define Build/Configure
	$(MAKE) -f libvorbisidec.mk \
		BUILD_DIR="$(PKG_BUILD_DIR)" \
		V=99 \
		compile
	$(SED) 's,-lvorbis ,$(TREMOR_DIR)/lib/libvorbisidec.a -logg ,g' $(PKG_BUILD_DIR)/configure
	$(call Build/Configure/Default, \
		--enable-yp \
		--with-curl="yes" \
		--with-curl-config="$(STAGING_DIR)/usr/bin/curl-config" \
		--with-ogg="$(STAGING_DIR)/usr" \
		--with-speex="no" \
		--with-theora="no" \
		--with-vorbis="$(TREMOR_DIR)" \
		--with-xslt-config="$(STAGING_DIR)/usr/bin/xslt-config" \
		, \
		CPPFLAGS="-I$(TREMOR_DIR)/include -I$(STAGING_DIR)/usr/include/libxml2 $(TARGET_CPPFLAGS)" \
	)
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		INCLUDES="-I$(PKG_BUILD_DIR)/src -I$(TREMOR_DIR)/include" \
		all install
endef

define Package/icecast/install
	$(INSTALL_DIR) $(1)/etc
	$(CP) $(PKG_INSTALL_DIR)/etc/icecast.xml $(1)/etc/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/icecast.init $(1)/etc/init.d/icecast
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/icecast $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/share/icecast
	$(CP) $(PKG_INSTALL_DIR)/usr/share/icecast/admin $(1)/usr/share/icecast/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/icecast/web $(1)/usr/share/icecast/
endef

define Package/icecast/conffiles
/etc/icecast.xml
endef

$(eval $(call BuildPackage,icecast))
