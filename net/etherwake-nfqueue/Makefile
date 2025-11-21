#
# Copyright (C) 2019 Mister Benjamin <144dbspl@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=etherwake-nfqueue
PKG_RELEASE:=3

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/mister-benjamin/etherwake-nfqueue.git
PKG_SOURCE_DATE:=2019-09-28
PKG_SOURCE_VERSION:=f71c269b58585e93575fa3e9fcc1793806fb3080
PKG_MIRROR_HASH:=91e5247608a6e6d925345f9827aeea167ea6ee22ae453b4779cce6f718a061dd

PKG_MAINTAINER:=Mister Benjamin <144dbspl@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/etherwake-nfqueue
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libnetfilter-queue +nftables +kmod-nft-queue
  TITLE:=Wake up computers on netfilter match
  URL:=https://github.com/mister-benjamin/etherwake-nfqueue
endef

define Package/etherwake-nfqueue/description
 Fork of etherwake with additional support for sending WOL packets
 when a router added a filtered packet to an NFQUEUE.
endef

define Package/etherwake-nfqueue/conffiles
/etc/config/etherwake-nfqueue
endef

define Package/etherwake-nfqueue/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/etherwake-nfqueue $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) files/$(PKG_NAME).config $(1)/etc/config/$(PKG_NAME)
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) files/$(PKG_NAME).init $(1)/etc/init.d/$(PKG_NAME)
endef

$(eval $(call BuildPackage,etherwake-nfqueue))
