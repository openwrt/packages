#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=youtube-dl
PKG_VERSION:=2020.3.24
PKG_RELEASE:=1

PKG_SOURCE:=youtube_dl-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/y/youtube_dl/
PKG_HASH:=4b03efe439f7cae26eba909821d1df00a9a4eb82741cb2e8b78fe29702bd4633

PKG_BUILD_DIR:=$(BUILD_DIR)/youtube_dl-$(PKG_VERSION)

PKG_LICENSE:=Unlicense
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Adrian Panella <ianchi74@outlook.com>, Josef Schlehofer <pepe.schlehofer@gmail.com>

include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python-package.mk

define Package/youtube-dl
  SECTION:=multimedia
  CATEGORY:=Multimedia
  TITLE:=Utility to download videos from YouTube.com
  URL:=https://yt-dl.org
  DEPENDS:= \
    +ca-certificates \
    +python \
    +python-email \
    +python-xml \
    +python-codecs \
    +python-ctypes \
    +python-setuptools
  VARIANT:=python
endef

define Package/youtube-dl/description
  youtube-dl is a small command-line program to download videos
  from YouTube.com and other video sites.
  It requires the Python interpreter.
endef

define PyPackage/youtube-dl/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin
endef

$(eval $(call PyPackage,youtube-dl))
$(eval $(call BuildPackage,youtube-dl))
$(eval $(call BuildPackage,youtube-dl-src))
