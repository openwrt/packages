#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=l7-protocols
PKG_VERSION:=2009-05-28
PKG_RELEASE:=2
PKG_LICENSE:=GPL-2.0

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/l7-filter
PKG_MD5SUM:=91be154d12134dcdbc560cc7aa7fe4ce

include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/package.mk

define Package/l7-protocols
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Protocols for layer7 filtering
  URL:=http://l7-filter.sourceforge.net/
  SUBMENU:=Firewall
  MAINTAINER:=Lim Guo Wei <limguowei@gmail.com>
  DEPENDS:=iptables-mod-filter
endef

define Package/l7-protocols/description
       l7-filter classifies packets based on patterns in application
       layer data. This allows correct classification of P2P traffic that
       uses unpredictable ports as well as standard protocols running on
       non-standard ports.
endef

define Package/l7-protocols-testing
	$(call Package/l7-protocols)
	TITLE:=testing utilities for layer7
	DEPENDS+=l7-protocols $(CXX_DEPENDS)
endef

define Package/l7-protocols-testing/description
	testing utilities for layer 7 patterns
endef

define Build/Configure
endef

ifneq ($(SDK)$(CONFIG_PACKAGE_l7-protocols-testing),)
  define Build/Compile
	cd $(PKG_BUILD_DIR)/testing && $(MAKE) $(CONFIGURE_VARS)
  endef
else
  define Build/Compile
  endef
endif

define Package/l7-protocols/install
	find $(PKG_BUILD_DIR) -name "README" -delete
	$(INSTALL_DIR) $(1)/etc/l7-protocols
	$(CP) $(PKG_BUILD_DIR)/extra \
		$(PKG_BUILD_DIR)/file_types \
		$(PKG_BUILD_DIR)/groups.sh \
		$(PKG_BUILD_DIR)/malware \
		$(PKG_BUILD_DIR)/protocols \
		$(1)/etc/l7-protocols
endef

define Package/l7-protocols-testing/install
	$(INSTALL_DIR) $(1)/etc/l7-protocols/testing
	$(CP) $(PKG_BUILD_DIR)/testing/data \
		$(1)/etc/l7-protocols/testing
	$(INSTALL_BIN) \
		$(PKG_BUILD_DIR)/testing/rand{chars,printable} \
		$(PKG_BUILD_DIR)/testing/test_speed-{kernel,userspace} \
		$(PKG_BUILD_DIR)/testing/match_kernel \
		$(PKG_BUILD_DIR)/testing/doallspeeds.sh \
		$(PKG_BUILD_DIR)/testing/test_match.sh \
		$(PKG_BUILD_DIR)/testing/timeit.sh \
		$(1)/etc/l7-protocols/testing
endef

$(eval $(call BuildPackage,l7-protocols))
$(eval $(call BuildPackage,l7-protocols-testing))
