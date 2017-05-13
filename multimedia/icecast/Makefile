#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=icecast
PKG_VERSION:=2.4.3
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://downloads.xiph.org/releases/icecast/
PKG_MD5SUM:=83d7d34dbe22f0f8fc119d2c9839efc0
PKG_HASH:=c85ca48c765d61007573ee1406a797ae6cb31fb5961a42e7f1c87adb45ddc592

PKG_MAINTAINER:=André Gaul <andre@gaul.io>, \
		Ted Hess <thess@kitschensync.net>

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_INSTALL:= 1

include $(INCLUDE_DIR)/package.mk

define Package/icecast
  SECTION:=multimedia
  CATEGORY:=Multimedia
  DEPENDS:=+libcurl +libxml2 +libxslt +libogg +libvorbisidec
  TITLE:=A streaming media server for Ogg/Vorbis and MP3 audio streams
  USERID:=icecast=87:icecast=87
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

CONFIGURE_ARGS+= \
	--enable-yp \
	--with-openssl="no" \
	--with-curl="yes" \
	--with-curl-config="$(STAGING_DIR)/usr/bin/curl-config" \
	--with-ogg="$(STAGING_DIR)/usr" \
	--with-speex="no" \
	--with-theora="no" \
	--with-vorbis="$(STAGING_DIR)/usr" \
	--with-xslt-config="$(STAGING_DIR)/usr/bin/xslt-config"


# Manually edit configure in case both vorbis and tremor host packages are installed
define Build/Configure
	$(SED) 's,-lvorbis -lm,-lvorbisidec -logg ,g' $(PKG_BUILD_DIR)/configure
	$(call Build/Configure/Default)
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
