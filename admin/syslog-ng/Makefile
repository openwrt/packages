include  $(TOPDIR)/rules.mk

PKG_NAME:=syslog-ng
PKG_VERSION:=3.8.1
PKG_RELEASE:=1

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/balabit/syslog-ng/releases/download/$(PKG_NAME)-$(PKG_VERSION)/
PKG_MD5SUM:=acf14563cf5ce435db8db35486ce66af

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/syslog-ng
  SECTION:=admin
  CATEGORY:=Administration
  DEPENDS:=+libpcre +glib2 +libeventlog +libopenssl +libuuid
  TITLE:=A powerful syslog daemon
  URL:=http://www.balabit.com/network-security/syslog-ng/opensource-logging-system/
endef

define Package/syslog-ng/description
  syslog-ng reads and logs messages to the system console, log
  files, other machines and/or users as specified by its
  configuration file.
endef

define Package/syslog-ng/conffiles
  /etc/syslog-ng.conf
endef

define Build/Configure
	$(SED) 's,-I/usr/include,,' $(PKG_BUILD_DIR)/configure
	$(Build/Configure/Default)
endef

CONFIGURE_ARGS += \
  $(call autoconf_bool,CONFIG_IPV6,ipv6) \
         --disable-dependency-tracking \
         --disable-tcp-wrapper \
         --disable-glibtest \
         --disable-mongodb \
         --disable-java \
         --disable-spoof-source \
         --disable-sql \
         --disable-linux-caps \
         --enable-prce \

TARGET_CPPFLAGS += \
  -I$(STAGING_DIR)/usr/include/eventlog

CONFIGURE_VARS += \
  LIBDBI_CFLAGS="-I$(STAGING_DIR)/usr/include"

define Package/syslog-ng/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libsyslog-ng-3.8.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/syslog-ng $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/syslog-ng.init $(1)/etc/init.d/syslog-ng
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DATA) ./files/syslog-ng.conf $(1)/etc
endef

$(eval $(call BuildPackage,syslog-ng))
