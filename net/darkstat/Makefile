#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=darkstat
PKG_VERSION:=3.0.722
PKG_RELEASE:=1

PKG_MAINTAINER:=Paul Doran <RuralRoots@gmail.com>

PKG_LICENSE:=GPL-2.0 BSD-ISC

PKG_LICENSE_FILES:=COPYING.GPL LICENSE

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/emikulic/darkstat/archive/refs/tags/$(PKG_VERSION).tar.gz?
PKG_HASH:=5c8e66d4c478b6d7e58f4c842823a09125509bf6851017ff70e32b32ce95b01b

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/darkstat
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libpcap +zlib
  TITLE:=Network bandwidth monitor
  URL:=https://unix4lyfe.org/darkstat/
endef

define Package/darkstat/description
darkstat is a packet sniffer that runs as a background process on an OpenWrt 
router. It captures multiple statistics about network usage, and serves them
over HTTP.
endef

define Package/darkstat/conffiles
/etc/config/darkstat
endef

CONFIGURE_ARGS += \
	--disable-debug \
	--with-chroot-dir=/var/empty

CONFIGURE_VARS += \
	ac_cv_search_setproctitle=no \
	ac_cv_search_strlcpy=no \
	ac_cv_search_strlcat=no

define Build/Configure
	( cd $(PKG_BUILD_DIR) && autoreconf -fi )
	$(call Build/Configure/Default)
endef

define Build/Compile
	$(HOSTCC) $(HOST_CFLAGS) $(PKG_BUILD_DIR)/static/c-ify.c \
	   -o $(PKG_BUILD_DIR)/c-ify $(HOST_LDFLAGS)
	$(HOSTCC) $(HOST_CFLAGS) $(PKG_BUILD_DIR)/static/hex-ify.c \
	   -o $(PKG_BUILD_DIR)/hex-ify $(HOST_LDFLAGS)
	( cd $(PKG_BUILD_DIR) && \
	    ./c-ify style_css <static/style.css >stylecss.h && \
	    ./c-ify graph_js <static/graph.js >graphjs.h && \
	    ./hex-ify favicon_png <static/favicon.png >favicon.h )
	$(call Build/Compile/Default)
endef

define Package/darkstat/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/darkstat $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/darkstat.init $(1)/etc/init.d/darkstat
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/darkstat.config $(1)/etc/config/darkstat
endef

$(eval $(call BuildPackage,darkstat))
