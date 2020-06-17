#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=youtube-dl
PKG_VERSION:=2020.6.16.1
PKG_RELEASE:=1

PYPI_NAME:=youtube_dl
PKG_HASH:=9fc0389a1bbbeb609a5bb4ad5630dea107a9d1a24c73721c611a78c234309a75

PKG_MAINTAINER:=Adrian Panella <ianchi74@outlook.com>, Josef Schlehofer <pepe.schlehofer@gmail.com>
PKG_LICENSE:=Unlicense
PKG_LICENSE_FILES:=LICENSE

include ../../lang/python/pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python3-package.mk

define Package/youtube-dl
  SECTION:=multimedia
  CATEGORY:=Multimedia
  TITLE:=Utility to download videos from YouTube.com
  URL:=https://yt-dl.org
  DEPENDS:= \
    +ca-certificates \
    +python3 \
    +python3-email \
    +python3-xml \
    +python3-codecs \
    +python3-ctypes \
    +python3-setuptools
endef

define Package/youtube-dl/description
  youtube-dl is a small command-line program to download videos
  from YouTube.com and other video sites.
  It requires the Python3 interpreter.
endef

$(eval $(call Py3Package,youtube-dl))
$(eval $(call BuildPackage,youtube-dl))
$(eval $(call BuildPackage,youtube-dl-src))
