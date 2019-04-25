#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=youtube-dl
PKG_VERSION:=2019.4.24
PKG_RELEASE:=1

PKG_SOURCE:=youtube_dl-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/y/youtube_dl/
PKG_HASH:=b20d110e1bed8d16f5771bb938ab6e5da67f08af62b599af65301cca290f2e15

PKG_BUILD_DIR:=$(BUILD_DIR)/youtube_dl-$(PKG_VERSION)

PKG_LICENSE:=Unlicense
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Adrian Panella <ianchi74@outlook.com>, Josef Schlehofer <pepe.schlehofer@gmail.com>

include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python3-package.mk

define Package/youtube-dl/Default
  SECTION:=multimedia
  CATEGORY:=Multimedia
  TITLE:=Utility to download videos from YouTube.com
  DEPENDS:=+ca-certificates
  URL:=https://yt-dl.org
endef

define Package/youtube-dl/description
  youtube-dl is a small command-line program to download videos
  from YouTube.com and other video sites.
  It requires the Python3 interpreter.
endef

define Package/youtube-dl
$(call Package/youtube-dl/Default)
  DEPENDS+= \
	+python3 \
	+python3-email \
	+python3-xml \
	+python3-codecs \
	+python3-ctypes
  VARIANT:=python3
endef

$(eval $(call Py3Package,youtube-dl))
$(eval $(call BuildPackage,youtube-dl))
$(eval $(call BuildPackage,youtube-dl-src))
