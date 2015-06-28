#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=clamav
PKG_VERSION:=0.98.7
PKG_RELEASE:=1

PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Marko Ratkaj <marko.ratkaj@sartura.hr>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://sourceforge.net/projects/clamav/files/clamav/$(PKG_VERSION)/
PKG_MD5SUM:=157c601161da1c2d5a0e48ea1b49e067

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/package.mk

define Package/clamav/Default
  SECTION:=net
  DEPENDS:=+libpthread +uclibcxx +zlib +libcurl +libopenssl
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=ClamAV
  URL:=http://www.clamav.net/
endef

define Package/clamav
    $(call Package/clamav/Default)
endef

define Package/freshclam
    $(call Package/clamav/Default)
    DEPENDS+= +clamav
    TITLE+=database updater
endef

define Package/clamav/description
 ClamAV is an open source antivirus engine for detecting trojans,
 viruses, malware & other malicious threats.
endef

define Package/freshclam/description
 Database updater for ClamAV
endef

define Package/clamav/conffiles
endef

CONFIGURE_VARS += \
	INCLUDES="" \
	CXXFLAGS="$$$$CXXFLAGS -fno-rtti" \
	LIBS="-lpthread" \

define Build/Configure
	$(call Build/Configure/Default, \
		--sysconfdir=/etc/clamav/ \
		--prefix=/usr/ \
		--exec-prefix=/usr/ \
		--disable-xml \
		--disable-bzip2 \
		--enable-ltdl-install \
		--with-user nobody \
		--with-group nogroup \
	)
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		all install
endef

define Package/clamav/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/clamd $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/clamav-config $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/clambc $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/clamconf $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/clamdscan $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/clamscan $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/sigtool $(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/clamav.h $(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib*/* $(1)/usr/lib/

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/clamav.config $(1)/etc/config/clamav

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/clamav.init $(1)/etc/init.d/clamav

	$(INSTALL_DIR) $(1)/usr/share/clamav
	$(CP) ./files/bytecode.cvd $(1)/usr/share/clamav/
endef

define Package/freshclam/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/freshclam $(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/freshclam.config $(1)/etc/config/freshclam

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/freshclam.init $(1)/etc/init.d/freshclam
endef

$(eval $(call BuildPackage,clamav))
$(eval $(call BuildPackage,freshclam))
