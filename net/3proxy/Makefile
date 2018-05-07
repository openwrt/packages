#
# Copyright (C) 2018 Daniel Engberg <daniel.engberg.lists@pyret.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=3proxy
PKG_VERSION:=0.9-devel
PKG_RELEASE:=1
PKG_MAINTAINER:=
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE_URL:=https://codeload.github.com/z3APA3A/$(PKG_NAME)/tar.gz/68823c2?dummy=/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-68823c2.tar.gz
PKG_HASH:=c8f6e8bdf8fc71e02a8cb2512009966d6148d7f82f9fe40ed710624390e3ab7a
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-68823c2

include $(INCLUDE_DIR)/package.mk

3PROXY_APPLETS := \
		3proxy ftppr mycrypt pop3p proxy smtpp socks tcppm udppm

define Package/3proxy/Default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=3proxy
  URL:=https://3proxy.ru/
endef

define Package/3proxy
  $(call Package/3proxy/Default)
  TITLE:=3proxy software distribution
  MENU:=1
endef

define Package/3proxy/description
  Software from the 3proxy software distribution
endef

3proxy_SUBPACKAGETITLE_3proxy:=Includes all proxy servers
3proxy_SUBPACKAGETITLE_ftppr:=FTP proxy server
3proxy_SUBPACKAGETITLE_mycrypt:=Generate encrypted passwords (MD5/crypt and NT password)
3proxy_SUBPACKAGETITLE_pop3p:=POP3 proxy server
3proxy_SUBPACKAGETITLE_proxy:=HTTP proxy server
3proxy_SUBPACKAGETITLE_smtpp:=SMTP proxy server
3proxy_SUBPACKAGETITLE_socks:=SOCKS 4/5 proxy server
3proxy_SUBPACKAGETITLE_tcppm:=TCP port mapping
3proxy_SUBPACKAGETITLE_udppm:=UDP port mapping

define GenPlugin
 define Package/$(1)
   $(call Package/3proxy/Default)
   DEPENDS:=3proxy
   TITLE:=$(3proxy_SUBPACKAGETITLE_$(2))
 endef

 define Package/$(1)/description
  $(2) utility
 endef
endef

define Package/3proxy/conffiles
/etc/3proxy.cfg
endef

$(foreach a,$(3PROXY_APPLETS),$(eval $(call GenPlugin,3proxy-$(a),$(a))))

TARGET_CFLAGS+= -fno-strict-aliasing -c -pthread -DWITHSPLICE \
		-DGETHOSTBYNAME_R -D_THREAD_SAFE -D_REENTRANT \
		-DNOODBC -DWITH_STD_MALLOC -DFD_SETSIZE=4096 \
		-DWITH_POLL -DWITH_NETFILTER -D_GNU_SOURCE \
		-ffunction-sections -fdata-sections $(FPIC)

TARGET_LDFLAGS+= -pthread -Wl,--gc-sections

define Package/3proxy/install
	true
endef

define BuildPlugin
  define Package/$(1)/install
	$(INSTALL_DIR) $$(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/$(2) $$(1)/usr/bin/
 endef

  $$(eval $$(call BuildPackage,$(1)))
endef

$(eval $(call BuildPackage,3proxy))

$(foreach a,$(3PROXY_APPLETS),$(eval $(call BuildPlugin,3proxy-$(a),$(a))))
