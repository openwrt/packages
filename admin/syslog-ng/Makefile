include $(TOPDIR)/rules.mk

PKG_NAME:=syslog-ng
PKG_VERSION:=4.10.1
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/syslog-ng/syslog-ng/releases/download/$(PKG_NAME)-$(PKG_VERSION)/
PKG_HASH:=dea90cf1dc4b8674ff191e0032f9dabc24b291abfd7f110fd092ae5f21cde5d7

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>
PKG_LICENSE:=LGPL-2.1-or-later GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING LGPL.txt GPL.txt
PKG_CPE_ID:=cpe:/a:oneidentity:syslog-ng

PKG_CONFIG_DEPENDS:= \
	CONFIG_IPV6 \
	CONFIG_LIBCURL_ZLIB

PKG_BUILD_DEPENDS:=gperf/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk
include $(INCLUDE_DIR)/nls.mk

define Package/syslog-ng
  SECTION:=admin
  CATEGORY:=Administration
  TITLE:=A powerful syslog daemon
  URL:=https://www.syslog-ng.com/products/open-source-log-management/
  DEPENDS:=+libpcre2 +glib2 +libopenssl +libdbi +libjson-c +libcurl +libuuid +SYSLOGNG_LOGROTATE:logrotate +LIBCURL_ZLIB:zlib +ivykis
  ALTERNATIVES:=300:/sbin/logread:/usr/libexec/logread.sh
endef

define Package/syslog-ng/description
  syslog-ng reads and logs messages to the system console, log
  files, other machines and/or users as specified by its
  configuration file.
endef

define Package/syslog-ng/conffiles
/etc/syslog-ng.conf
/etc/syslog-ng.d/
/etc/scl.conf
endef

define Package/syslog-ng/config
config SYSLOGNG_LOGROTATE
	bool "Logrotate support"
	depends on PACKAGE_syslog-ng
	default n
	help
	  It adds support for logrotate functionality.

config SYSLOGNG_LOGROTATE_MAXSIZE
	string "Maximum size of /var/log/messages log file"
	depends on SYSLOGNG_LOGROTATE
	default "1M"
	help
	  Log files are rotated when they grow bigger than defined size bytes.

config SYSLOGNG_LOGROTATE_ROTATE_COUNT
	int "Maximum rotation count for /var/log/messages log file"
	depends on SYSLOGNG_LOGROTATE
	default 1
	help
	  Log files are rotated count times before being removed or mailed to
	  the address specified in a mail directive. If count is 0, old
	  versions are removed rather than rotated.
endef

LOGROTATE_MAXSIZE:=$(call qstrip,$(CONFIG_SYSLOGNG_LOGROTATE_MAXSIZE))
LOGROTATE_ROTATE:=$(call qstrip,$(CONFIG_SYSLOGNG_LOGROTATE_ROTATE_COUNT))

CMAKE_OPTIONS += \
	-DBUILD_TESTING=OFF \
	-DENABLE_IPV6=$(if $(CONFIG_IPV6),ON,OFF) \
	-DENABLE_TCP_WRAPPER=OFF \
	-DENABLE_SPOOF_SOURCE=OFF \
	-DENABLE_LINUX_CAPS=OFF \
	-DENABLE_JSON=ON \
	-DENABLE_CPP=OFF \
	-DENABLE_AFSNMP=OFF \
	-DENABLE_AFUSER=ON \
	-DENABLE_EXAMPLE_MODULES=OFF \
	-DENABLE_EBPF=OFF \
	-DENABLE_HTTP=$(if $(CONFIG_LIBCURL_ZLIB),ON,OFF) \
	-DENABLE_SMTP=OFF \
	-DENABLE_REDIS=OFF \
	-DENABLE_STACKDUMP=OFF \
	-DENABLE_PYTHON=OFF \
	-DENABLE_GEOIP2=OFF \
	-DENABLE_JAVA=OFF \
	-DENABLE_JAVA_MODULES=OFF \
	-DENABLE_GRPC=OFF \
	-DENABLE_AFAMQP=OFF \
	-DENABLE_APPMODEL=OFF \
	-DENABLE_AZURE_AUTH_HEADER=OFF \
	-DENABLE_GETENT=OFF \
	-DENABLE_HOOK_COMMANDS=OFF \
	-DENABLE_MAP_VALUE_PAIRS=OFF \
	-DENABLE_NATIVE=OFF \
	-DENABLE_PACCT=OFF \
	-DENABLE_STARDATE=OFF \
	-DENABLE_STOMP=OFF \
	-DENABLE_XML=OFF \
	-DENABLE_MANPAGES=OFF \
	-DENABLE_MANPAGES_INSTALL=OFF \
	-DENABLE_TOOLS=ON \
	-DENABLE_KAFKA=OFF \
	-DENABLE_MQTT=OFF \
	-DNEABLE_SQL=OFF \
	-DENABLE_IO_URING=OFF \
	-DWITH_JSONC=system \
	-DWITH_SYSTEMD_JOURNAL=OFF \
	-DIVYKIS_SOURCE=system

define Package/syslog-ng/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/* $(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
	
	$(INSTALL_DIR) $(1)/usr/lib/syslog-ng
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/syslog-ng/* $(1)/usr/lib/syslog-ng/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/syslog-ng.init $(1)/etc/init.d/syslog-ng

	$(INSTALL_DIR) $(1)/etc/syslog-ng.d
	$(INSTALL_CONF) ./files/syslog-ng.conf $(1)/etc
	touch $(1)/etc/syslog-ng.d/.keep

	$(INSTALL_DIR) $(1)/usr/libexec
	$(INSTALL_BIN) ./files/logread.sh $(1)/usr/libexec/logread.sh

	$(INSTALL_DIR) $(1)/usr/share/syslog-ng/include/
	$(CP) -r ./files/scl $(1)/usr/share/syslog-ng/include/

ifneq ($(strip $(CONFIG_SYSLOGNG_LOGROTATE)),)
	$(INSTALL_DIR) $(1)/etc/logrotate.d
	sed \
		-e 's#@MAXSIZE@#$(LOGROTATE_MAXSIZE)#g' \
		-e 's#@ROTATE@#$(LOGROTATE_ROTATE)#g' \
		./files/syslog-ng.logrotate > $(1)/etc/logrotate.d/syslog-ng.conf
endif
endef

define Package/syslog-ng/postinst
#!/bin/sh

[ -n "$$IPKG_INSTROOT" ] || {
/etc/init.d/syslog-ng enable
/etc/init.d/syslog-ng restart
}
endef

define Package/syslog-ng/prerm
#!/bin/sh

[ -n "$$IPKG_INSTROOT" ] || {
/etc/init.d/syslog-ng disable
/etc/init.d/syslog-ng stop
}
endef

$(eval $(call BuildPackage,syslog-ng))
