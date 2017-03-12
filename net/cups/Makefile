#
# Copyright (C) 2006-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=cups
PKG_VERSION:=1.5.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-source.tar.bz2
PKG_SOURCE_URL:= http://www.cups.org/software/$(PKG_VERSION)
PKG_MD5SUM:=de3006e5cf1ee78a9c6145ce62c4e982

TARGET_LDFLAGS+=-Wl,-rpath-link=$(STAGING_DIR)/usr/lib

include $(INCLUDE_DIR)/package.mk

define Package/cups/Default
  URL:=http://www.cups.org/
  SUBMENU:=Printing
endef

define Package/cups
$(call Package/cups/Default)
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libcups +libcupsmime +libcupscgi +libcupsppdc +libusb-1.0
  TITLE:=Common UNIX Printing System (daemon)
endef

define Package/cups/description
	Common UNIX Printing System (daemon)
endef

define Package/cups/conffiles
/etc/cups/classes.conf
/etc/cups/cupsd.conf
/etc/cups/printers.conf
endef

define Package/cups-bsd
$(call Package/cups/Default)
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libcups
  TITLE:=Common UNIX Printing System - BSD commands (old)
endef

define Package/cups-bsd/description
	Common UNIX Printing System - BSD commands (old)
endef

define Package/cups-client
$(call Package/cups/Default)
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libcups +libcupsimage +libcupsmime
  TITLE:=Common UNIX Printing System - Client commands
endef

define Package/cups-client/conffiles
/etc/cups/client.conf
endef

define Package/cups-client/description
	Common UNIX Printing System - Client commands
endef

define Package/cups-filters
$(call Package/cups/Default)
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libcupsimage +libcupsdriver
  TITLE:=Common UNIX Printing System - Filter
endef

define Package/cups-filters/description
	Common UNIX Printing System - Filter
endef

define Package/cups-ppdc
$(call Package/cups/Default)
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libcupsppdc
  TITLE:=Common UNIX Printing System - PPDC utils
endef

define Package/cups-ppdc/description
	Common UNIX Printing System - PPDC utils
endef

define Package/libcups
$(call Package/cups/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+zlib +libpthread +libpng +libjpeg
  TITLE:=Common UNIX Printing System - Core library
endef

define Package/libcups/description
	Common UNIX Printing System - Core library
endef

define Package/libcupscgi
$(call Package/cups/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libcups
  TITLE:=Common UNIX Printing System - CGI library
endef

define Package/libcupscgi/description
	Common UNIX Printing System - CGI library
endef

define Package/libcupsdriver
$(call Package/cups/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libcups
  TITLE:=Common UNIX Printing System - Driver library
endef

define Package/libcupsdriver/description
	Common UNIX Printing System - Driver library
endef

define Package/libcupsimage
$(call Package/cups/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libcups +libpng +libjpeg
  TITLE:=Common UNIX Printing System - Image library
endef

define Package/libcupsimage/description
	Common UNIX Printing System - Image library
endef

define Package/libcupsmime
$(call Package/cups/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libcups
  TITLE:=Common UNIX Printing System - MIME library
endef

define Package/libcupsmime/description
	Common UNIX Printing System - MIME library
endef

define Package/libcupsppdc
$(call Package/cups/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libcups +libstdcpp
  TITLE:=Common UNIX Printing System - PPDC library
endef

define Package/libcupsppdc/description
	Common UNIX Printing System - PPDC library
endef

define Package/cups-locale-de
$(call Package/cups/Default)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Common UNIX Printing System - Locale de
endef

define Package/cups-locale-de/description
	Common UNIX Printing System - Locale de
endef

define Package/cups-locale-nl
$(call Package/cups/Default)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Common UNIX Printing System - Locale nl
endef

define Package/cups-locale-nl/description
	Common UNIX Printing System - Locale nl
endef

define Package/cups-locale-hu
$(call Package/cups/Default)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Common UNIX Printing System - Locale hu
endef

define Package/cups-locale-hu/description
	Common UNIX Printing System - Locale hu
endef

define Package/cups-locale-pt
$(call Package/cups/Default)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Common UNIX Printing System - Locale pt
endef

define Package/cups-locale-pt/description
	Common UNIX Printing System - Locale pt
endef

define Package/cups-locale-pt_BR
$(call Package/cups/Default)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Common UNIX Printing System - Locale pt_BR
endef

define Package/cups-locale-pt_BR/description
	Common UNIX Printing System - Locale pt_BR
endef

define Package/cups-locale-fi
$(call Package/cups/Default)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Common UNIX Printing System - Locale fi
endef

define Package/cups-locale-fi/description
	Common UNIX Printing System - Locale fi
endef

define Package/cups-locale-sv
$(call Package/cups/Default)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Common UNIX Printing System - Locale sv
endef

define Package/cups-locale-sv/description
	Common UNIX Printing System - Locale sv
endef

define Package/cups-locale-da
$(call Package/cups/Default)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Common UNIX Printing System - Locale da
endef

define Package/cups-locale-da/description
	Common UNIX Printing System - Locale da
endef

define Package/cups-locale-ko
$(call Package/cups/Default)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Common UNIX Printing System - Locale ko
endef

define Package/cups-locale-ko/description
	Common UNIX Printing System - Locale ko
endef

define Package/cups-locale-zh
$(call Package/cups/Default)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Common UNIX Printing System - Locale zh
endef

define Package/cups-locale-zh/description
	Common UNIX Printing System - Locale zh
endef

define Package/cups-locale-ja
$(call Package/cups/Default)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Common UNIX Printing System - Locale ja
endef

define Package/cups-locale-ja/description
	Common UNIX Printing System - Locale ja
endef

define Package/cups-locale-es
$(call Package/cups/Default)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Common UNIX Printing System - Locale es
endef

define Package/cups-locale-es/description
	Common UNIX Printing System - Locale es
endef

define Package/cups-locale-zh_TW
$(call Package/cups/Default)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Common UNIX Printing System - Locale zh_TW
endef

define Package/cups-locale-zh_TW/description
	Common UNIX Printing System - Locale zh_TW
endef

define Package/cups-locale-pl
$(call Package/cups/Default)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Common UNIX Printing System - Locale pl
endef

define Package/cups-locale-pl/description
	Common UNIX Printing System - Locale pl
endef

define Package/cups-locale-no
$(call Package/cups/Default)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Common UNIX Printing System - Locale no
endef

define Package/cups-locale-no/description
	Common UNIX Printing System - Locale no
endef

define Package/cups-locale-ru
$(call Package/cups/Default)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Common UNIX Printing System - Locale ru
endef

define Package/cups-locale-ru/description
	Common UNIX Printing System - Locale ru
endef

define Package/cups-locale-eu
$(call Package/cups/Default)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Common UNIX Printing System - Locale eu
endef

define Package/cups-locale-eu/description
	Common UNIX Printing System - Locale eu
endef

define Package/cups-locale-fr
$(call Package/cups/Default)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Common UNIX Printing System - Locale fr
endef

define Package/cups-locale-fr/description
	Common UNIX Printing System - Locale fr
endef

define Package/cups-locale-it
$(call Package/cups/Default)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Common UNIX Printing System - Locale it
endef

define Package/cups-locale-it/description
	Common UNIX Printing System - Locale it
endef

define Package/cups-locale-id
$(call Package/cups/Default)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Common UNIX Printing System - Locale id
endef

define Package/cups-locale-id/description
	Common UNIX Printing System - Locale id
endef

define Build/Configure
	$(call Build/Configure/Default, \
		--with-cups-user="nobody" \
		--with-cups-group="nogroup" \
		--with-components="embedded" \
		--with-pdftops="none" \
		--without-perl \
		--without-python \
		--without-php \
		--enable-shared \
		--enable-image \
		--enable-libusb \
		--disable-acl \
		--disable-dbus \
		--disable-dnssd \
		--disable-launchd \
		--disable-ldap \
		--disable-pam \
		--disable-slp \
		--disable-gnutls \
		--disable-openssl \
		--disable-cdsassl \
		--disable-ssl \
		--disable-gssapi \
		--disable-tiff, \
		UNAME="Linux" \
		LIBS="$(TARGET_LDFLAGS) -lz -lpng -ljpeg" \
	)
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		DSTROOT="$(PKG_INSTALL_DIR)" \
		STRIP="/bin/true" \
		all install
endef

define Package/cups/install
	rm -rf $(1)/etc/cups
	$(INSTALL_DIR) $(1)/etc/cups
	$(CP) $(PKG_INSTALL_DIR)/etc/cups/* $(1)/etc/cups/
	rm -rf $(1)/etc/cups/certs
	ln -sf /tmp $(1)/etc/cups/certs
	rm -f $(1)/usr/bin/cups-config
	$(INSTALL_DIR) $(1)/usr/lib/cups
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/cups/backend $(1)/usr/lib/cups
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/cups/cgi-bin $(1)/usr/lib/cups
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/cups/daemon $(1)/usr/lib/cups
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/cups/driver $(1)/usr/lib/cups
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/cups/monitor $(1)/usr/lib/cups
	$(INSTALL_DIR) $(1)/usr/lib/cups/filter
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/cups/filter/{commandtops,pstops} \
		$(PKG_INSTALL_DIR)/usr/lib/cups/filter/gziptoany \
		$(1)/usr/lib/cups/filter
	$(INSTALL_DIR) $(1)/usr/share/cups/templates
	$(CP) $(PKG_INSTALL_DIR)/usr/share/cups/templates/*.tmpl \
		$(1)/usr/share/cups/templates/
	$(INSTALL_DIR) $(1)/usr/share/cups/mime
	$(CP) $(PKG_INSTALL_DIR)/usr/share/cups/mime/* $(1)/usr/share/cups/mime/
	$(INSTALL_DIR) $(1)/usr/share/doc/cups
	$(CP) $(PKG_INSTALL_DIR)/usr/share/doc/cups/index.html \
		$(1)/usr/share/doc/cups/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/doc/cups/*.css \
		$(1)/usr/share/doc/cups/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/doc/cups/images \
		$(1)/usr/share/doc/cups/
	$(INSTALL_DIR) $(1)/usr/sbin
	# overwrite default config with our own
	$(CP) ./files/etc/cups/* $(1)/etc/cups/
	# install initscript with priority 60
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/cupsd.init $(1)/etc/init.d/cupsd
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/sbin/{cupsctl,cupsd} \
		$(1)/usr/sbin/
endef

define Package/cups-bsd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/{lprm,lpq,lpr} $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/lpc $(1)/usr/sbin/
endef

define Package/cups-client/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/{lp,cancel,cupstestppd,cupstestdsc} \
		$(PKG_INSTALL_DIR)/usr/bin/{ipptool,lpoptions,lpstat,lppasswd} \
		$(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/sbin/{cupsaccept,cupsaddsmb,cupsfilter} \
		$(PKG_INSTALL_DIR)/usr/sbin/{lpadmin,lpinfo,lpmove} \
		$(1)/usr/sbin/
	(cd $(1)/usr/sbin; ln -sf cupsaccept accept; ln -sf cupsaccept cupsenable; ln -sf cupsaccept cupsdisable; ln -sf cupsaccept reject; ln -sf cupsaccept cupsreject;)
endef

define Package/cups-filters/install
	$(INSTALL_DIR) $(1)/usr/lib/cups/filter
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/cups/filter/{bannertops,commandtoescpx,commandtopclx,imagetops,imagetoraster,rastertoepson,rastertopwg,rastertohp,rastertoescpx,rastertopclx,rastertolabel,texttops} \
		$(1)/usr/lib/cups/filter
	(cd $(1)/usr/lib/cups/filter; ln -sf rastertolabel rastertodymo;)
endef

define Package/cups-ppdc/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/{ppdc,ppdhtml,ppdi,ppdmerge,ppdpo} \
		$(1)/usr/bin/
endef

define Package/libcups/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libcups.so* $(1)/usr/lib/
endef

define Package/libcupscgi/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libcupscgi.so* $(1)/usr/lib/
endef

define Package/libcupsdriver/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libcupsdriver.so* $(1)/usr/lib/
endef

define Package/libcupsimage/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libcupsimage.so* $(1)/usr/lib/
endef

define Package/libcupsmime/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libcupsmime.so* $(1)/usr/lib/
endef

define Package/libcupsppdc/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libcupsppdc.so* $(1)/usr/lib/
endef

define Package/cups-locale-de/install
	$(INSTALL_DIR) $(1)/usr/share/locale
	$(INSTALL_DIR) $(1)/usr/share/cups/templates
	$(CP) $(PKG_INSTALL_DIR)/usr/share/locale/de $(1)/usr/share/locale/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/cups/templates/de \
		$(1)/usr/share/cups/templates/
endef

define Package/cups-locale-nl/install
	$(INSTALL_DIR) $(1)/usr/share/locale
	$(CP) $(PKG_INSTALL_DIR)/usr/share/locale/nl $(1)/usr/share/locale/
endef

define Package/cups-locale-hu/install
	$(INSTALL_DIR) $(1)/usr/share/locale
	$(INSTALL_DIR) $(1)/usr/share/cups/templates
	$(CP) $(PKG_INSTALL_DIR)/usr/share/locale/hu $(1)/usr/share/locale/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/cups/templates/hu \
		$(1)/usr/share/cups/templates/
endef

define Package/cups-locale-pt/install
	$(INSTALL_DIR) $(1)/usr/share/locale
	$(CP) $(PKG_INSTALL_DIR)/usr/share/locale/pt $(1)/usr/share/locale/
endef

define Package/cups-locale-pt_BR/install
	$(INSTALL_DIR) $(1)/usr/share/locale
	$(CP) $(PKG_INSTALL_DIR)/usr/share/locale/pt_BR $(1)/usr/share/locale/
endef

define Package/cups-locale-fi/install
	$(INSTALL_DIR) $(1)/usr/share/locale
	$(CP) $(PKG_INSTALL_DIR)/usr/share/locale/fi $(1)/usr/share/locale/
endef

define Package/cups-locale-sv/install
	$(INSTALL_DIR) $(1)/usr/share/locale
	$(CP) $(PKG_INSTALL_DIR)/usr/share/locale/sv $(1)/usr/share/locale/
endef

define Package/cups-locale-da/install
	$(INSTALL_DIR) $(1)/usr/share/locale
	$(CP) $(PKG_INSTALL_DIR)/usr/share/locale/da $(1)/usr/share/locale/
endef

define Package/cups-locale-ko/install
	$(INSTALL_DIR) $(1)/usr/share/locale
	$(CP) $(PKG_INSTALL_DIR)/usr/share/locale/ko $(1)/usr/share/locale/
endef

define Package/cups-locale-zh/install
	$(INSTALL_DIR) $(1)/usr/share/locale
	$(CP) $(PKG_INSTALL_DIR)/usr/share/locale/zh $(1)/usr/share/locale/
endef

define Package/cups-locale-ja/install
	$(INSTALL_DIR) $(1)/usr/share/locale
	$(INSTALL_DIR) $(1)/usr/share/cups/templates
	$(CP) $(PKG_INSTALL_DIR)/usr/share/locale/ja $(1)/usr/share/locale/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/cups/templates/ja \
		$(1)/usr/share/cups/templates/
endef

define Package/cups-locale-es/install
	$(INSTALL_DIR) $(1)/usr/share/locale
	$(INSTALL_DIR) $(1)/usr/share/cups/templates
	$(CP) $(PKG_INSTALL_DIR)/usr/share/locale/es $(1)/usr/share/locale/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/cups/templates/es \
		$(1)/usr/share/cups/templates/
endef

define Package/cups-locale-zh_TW/install
	$(INSTALL_DIR) $(1)/usr/share/locale
	$(CP) $(PKG_INSTALL_DIR)/usr/share/locale/zh_TW $(1)/usr/share/locale/
endef

define Package/cups-locale-pl/install
	$(INSTALL_DIR) $(1)/usr/share/locale
	$(INSTALL_DIR) $(1)/usr/share/cups/templates
	$(CP) $(PKG_INSTALL_DIR)/usr/share/locale/pl $(1)/usr/share/locale/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/cups/templates/pl \
		$(1)/usr/share/cups/templates/
endef

define Package/cups-locale-no/install
	$(INSTALL_DIR) $(1)/usr/share/locale
	$(CP) $(PKG_INSTALL_DIR)/usr/share/locale/no $(1)/usr/share/locale/
endef

define Package/cups-locale-ru/install
	$(INSTALL_DIR) $(1)/usr/share/locale
	$(INSTALL_DIR) $(1)/usr/share/cups/templates
	$(CP) $(PKG_INSTALL_DIR)/usr/share/locale/ru $(1)/usr/share/locale/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/cups/templates/ru \
		$(1)/usr/share/cups/templates/
endef

define Package/cups-locale-eu/install
	$(INSTALL_DIR) $(1)/usr/share/locale
	$(INSTALL_DIR) $(1)/usr/share/cups/templates
	$(CP) $(PKG_INSTALL_DIR)/usr/share/locale/eu $(1)/usr/share/locale/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/cups/templates/eu \
		$(1)/usr/share/cups/templates/
endef

define Package/cups-locale-fr/install
	$(INSTALL_DIR) $(1)/usr/share/locale
	$(INSTALL_DIR) $(1)/usr/share/cups/templates
	$(CP) $(PKG_INSTALL_DIR)/usr/share/locale/fr $(1)/usr/share/locale/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/cups/templates/fr \
		$(1)/usr/share/cups/templates/
endef

define Package/cups-locale-it/install
	$(INSTALL_DIR) $(1)/usr/share/locale
	$(INSTALL_DIR) $(1)/usr/share/cups/templates
	$(CP) $(PKG_INSTALL_DIR)/usr/share/locale/it $(1)/usr/share/locale/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/cups/templates/it \
		$(1)/usr/share/cups/templates/
endef

define Package/cups-locale-id/install
	$(INSTALL_DIR) $(1)/usr/share/locale
	$(INSTALL_DIR) $(1)/usr/share/cups/templates
	$(CP) $(PKG_INSTALL_DIR)/usr/share/locale/id $(1)/usr/share/locale/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/cups/templates/id \
		$(1)/usr/share/cups/templates/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(2)/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/cups-config $(2)/bin/
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/cups $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libcups*.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,cups))
$(eval $(call BuildPackage,libcups))
$(eval $(call BuildPackage,libcupscgi))
$(eval $(call BuildPackage,libcupsdriver))
$(eval $(call BuildPackage,libcupsimage))
$(eval $(call BuildPackage,libcupsmime))
$(eval $(call BuildPackage,libcupsppdc))
$(eval $(call BuildPackage,cups-bsd))
$(eval $(call BuildPackage,cups-client))
$(eval $(call BuildPackage,cups-filters))
$(eval $(call BuildPackage,cups-ppdc))
$(eval $(call BuildPackage,cups-locale-de))
$(eval $(call BuildPackage,cups-locale-nl))
$(eval $(call BuildPackage,cups-locale-hu))
$(eval $(call BuildPackage,cups-locale-pt))
$(eval $(call BuildPackage,cups-locale-pt_BR))
$(eval $(call BuildPackage,cups-locale-fi))
$(eval $(call BuildPackage,cups-locale-sv))
$(eval $(call BuildPackage,cups-locale-da))
$(eval $(call BuildPackage,cups-locale-ko))
$(eval $(call BuildPackage,cups-locale-zh))
$(eval $(call BuildPackage,cups-locale-ja))
$(eval $(call BuildPackage,cups-locale-es))
$(eval $(call BuildPackage,cups-locale-zh_TW))
$(eval $(call BuildPackage,cups-locale-pl))
$(eval $(call BuildPackage,cups-locale-no))
$(eval $(call BuildPackage,cups-locale-ru))
$(eval $(call BuildPackage,cups-locale-eu))
$(eval $(call BuildPackage,cups-locale-fr))
$(eval $(call BuildPackage,cups-locale-it))
$(eval $(call BuildPackage,cups-locale-id))
