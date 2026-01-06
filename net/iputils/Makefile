#
# Copyright (C) 2006-2010 OpenWrt.org
# Copyright (C) 2019 Noah Meyerhans <frodo@morgul.net>
#
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=iputils
PKG_VERSION:=20250605
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/$(PKG_NAME)/$(PKG_NAME)/tar.gz/$(PKG_VERSION)?
PKG_HASH:=19e680c9eef8c079da4da37040b5f5453763205b4edfb1e2c114de77908927e4

PKG_MAINTAINER:=Noah Meyerhans <frodo@morgul.net>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:iputils:iputils

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk

MESON_ARGS += \
	-DBUILD_MANS=false \
	-DBUILD_HTML_MANS=false \
	-DUSE_CAP=false \
	-DUSE_IDN=false \
	-DUSE_GETTEXT=false \
	-DNO_SETCAP_OR_SUID=true \
	-DBUILD_PING=true \
	-DBUILD_ARPING=true \
	-DBUILD_CLOCKDIFF=true \
	-DBUILD_TRACEPATH=true \
	-DSKIP_TESTS=true

define Package/iputils/Default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=iputils
  URL:=https://github.com/iputils/iputils
endef

### ping

define Package/iputils-ping
  $(call Package/iputils/Default)
  TITLE:=iputils-ping
  DEPENDS:=+kmod-crypto-md5
  PROVIDES:=iputils-ping6
endef

define Package/iputils-ping/config
	source "$(SOURCE)/Config_ping.in"
endef

define Package/iputils-ping/description
  Send ICMP_ECHOREQUEST packets to IP hosts and report on replies
endef

define Package/iputils-ping/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_SUID) $(PKG_INSTALL_DIR)/usr/bin/ping $(1)/usr/bin/
ifdef CONFIG_PING_LEGACY_SYMLINKS
	ln -s ping $(1)/usr/bin/ping4
	ln -s ping $(1)/usr/bin/ping6
endif
endef

### arping

define Package/iputils-arping
  $(call Package/iputils/Default)
  TITLE:=iputils-arping
endef

define Package/iputils-arping/description
  Send ARP REQUEST packets to a neighbor host
endef

define Package/iputils-arping/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/arping $(1)/usr/bin/
endef

### clockdiff

define Package/iputils-clockdiff
  $(call Package/iputils/Default)
  TITLE:=iputils-clockdiff
endef

define Package/iputils-clockdiff/description
  Measure the clock difference between two hosts
endef

define Package/iputils-clockdiff/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/clockdiff $(1)/usr/bin/
endef

### tracepath

define Package/iputils-tracepath
  $(call Package/iputils/Default)
  TITLE:=iputils-tracepath
endef

define Package/iputils-tracepath/description
  trace network path to a host, discovering PMTU
endef

define Package/iputils-tracepath/config
	source "$(SOURCE)/Config_tracepath.in"
endef

define Package/iputils-tracepath/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/tracepath $(1)/usr/bin/
ifdef CONFIG_TRACEPATH_LEGACY_SYMLINKS
	ln -s tracepath $(1)/usr/bin/tracepath4
	ln -s tracepath $(1)/usr/bin/tracepath6
endif
endef

$(eval $(call BuildPackage,iputils-ping))
$(eval $(call BuildPackage,iputils-arping))
$(eval $(call BuildPackage,iputils-clockdiff))
$(eval $(call BuildPackage,iputils-tracepath))
