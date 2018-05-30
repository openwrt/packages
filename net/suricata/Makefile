#
# Copyright (C) 2018 Ashkan Jazayeri <ashkan@jazayeri.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=suricata
PKG_VERSION:=4.0.4
PKG_RELEASE:=1
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=\
		https://github.com/OISF/suricata/releases/download/$(PKG_NAME)-$(PKG_VERSION)/ \
		https://www.openinfosecfoundation.org/download/

PKG_HASH:=617e83b6e20b03aa7d5e05a980d3cb6d2810ec18a6f15a36bf66c81c9c0a2abb
PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Ashkan Jazayeri <ashkan@jazayeri.net>

include $(INCLUDE_DIR)/package.mk

define Package/suricata
 SUBMENU:=Firewall
 SECTION:=net
 CATEGORY:=Network
 DEPENDS:=+jansson +libiconv-full +libpcap +libpcre +libpthread +libyaml 
 DEPENDS+=+zlib +SURICATA_LOGROTATE:logrotate +SURICATA_LUA:lua +SURICATA_MAGIC:file 
 DEPENDS+=+SURICATA_NFLOG:libnetfilter-log +SURICATA_NFQ:kmod-ipt-nfqueue +SURICATA_NFQ:libnetfilter-queue
 TITLE:=Network IDS, IPS and NSM engine
 URL:=https://github.com/OISF/suricata
endef

define Package/suricata/description
 Suricata is a network IDS, IPS and NSM engine.
endef

define Package/suricata/conffiles
/etc/config/suricata
/etc/logrotate.d/suricata.logrotate
/etc/suricata/
endef

define Package/suricata/config
	source "$(SOURCE)/Config.in"
endef

TARGET_CPPFLAGS += -I$(STAGING_DIR)/usr/lib/libiconv-full/include
TARGET_LDFLAGS += -L$(STAGING_DIR)/usr/lib/libiconv-full/lib

CONFIGURE_ARGS += \
	$(if $(CONFIG_SURICATA_DEBUG),--enable,--disable)-debug \
	--disable-gccmarch-native \
	$(if $(CONFIG_SURICATA_MAGIC),--enable-magic,--disable-libmagic) \
	--disable-python \
	--disable-static \
	$(if $(CONFIG_SURICATA_SOCKET),--enable,--disable)-unix-socket

ifeq ($(CONFIG_SURICATA_LUA),y)
CONFIGURE_ARGS += \
	--enable-lua
endif
ifeq ($(CONFIG_SURICATA_NFLOG),y)
CONFIGURE_ARGS += \
	--enable-nflog
endif
ifeq ($(CONFIG_SURICATA_NFQ),y)
CONFIGURE_ARGS += \
	--enable-nfqueue
endif
ifeq ($(CONFIG_SURICATA_PIE),y)
CONFIGURE_ARGS += \
	--enable-pie
endif

define Package/suricata/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/suricata.config $(1)/etc/config/suricata

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/suricata.init $(1)/etc/init.d/suricata

ifeq ($(CONFIG_SURICATA_LOGROTATE),y)
	$(INSTALL_DIR) $(1)/etc/logrotate.d
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/etc/suricata.logrotate $(1)/etc/logrotate.d
endif
	$(INSTALL_DIR) $(1)/etc/suricata
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/{classification,reference,threshold}.config $(1)/etc/suricata
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/suricata.yaml $(1)/etc/suricata

	$(INSTALL_DIR) $(1)/etc/suricata/rules
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/rules/*.rules $(1)/etc/suricata/rules

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/suricata $(1)/usr/bin

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libhtp.so* $(1)/usr/lib
endef

$(eval $(call BuildPackage,suricata))
