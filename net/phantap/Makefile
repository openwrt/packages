# Copyright (C) 2019 Diana Dragusin <diana.dragusin@nccgroup.com>
# Copyright (C) 2019 Etienne Champetier <champetier.etienne@gmail.com>
#
# This is free software, licensed under the GNU General Public License v3.
# See <http://www.gnu.org/licenses/> for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=phantap
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/nccgroup/phantap
PKG_MIRROR_HASH:=f57fac81fe7ee875456c2d7e841237f5f43058c681e26d7dd782463ff8e67779
PKG_SOURCE_DATE:=2021.08.22
PKG_SOURCE_VERSION:=26bd87685272906a59563a5c1e5eb3ea41bcfec3

PKG_MAINTAINER:=Diana Dragusin <diana.dragusin@nccgroup.com>, \
    Etienne Champetier <champetier.etienne@gmail.com>
PKG_LICENSE:=GPL-3.0-only

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_SOURCE_SUBDIR:=src

define Package/phantap/Default
  SECTION:=net
  CATEGORY:=Network
  URL:=https://github.com/nccgroup/phantap
endef

define Package/phantap
  $(call Package/phantap/Default)
  TITLE:=PhanTap
  PKGARCH:=all
  DEPENDS:=+ebtables +libpcap +libnl-tiny +ip-full +kmod-br-netfilter +kmod-ebtables-ipv4
endef

define Package/phantap/conffiles
/etc/config/phantap
endef

define Package/phantap/description
  PhanTap or Phantom tap is a small set of scripts and C code that allow you to setup a
  network tap that automatically impersonate a victim device, allowing you to access
  internet using the IP & MAC of the victim.
endef

define Package/phantap/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/files/etc/config/phantap $(1)/etc/config/
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/files/etc/hotplug.d/iface/00-phantap $(1)/etc/hotplug.d/iface/
	$(INSTALL_DIR) $(1)/etc/hotplug.d/net
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/files/etc/hotplug.d/net/00-phantap $(1)/etc/hotplug.d/net/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/etc/init.d/phantap $(1)/etc/init.d/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/etc/init.d/phantap-early $(1)/etc/init.d/
	$(INSTALL_DIR) $(1)/etc/sysctl.d
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/files/etc/sysctl.d/12-phantap.conf $(1)/etc/sysctl.d/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/phantap-learn $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,phantap))
