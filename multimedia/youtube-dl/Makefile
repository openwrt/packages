#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=youtube-dl
PKG_VERSION:=2018.03.10
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://yt-dl.org/downloads/$(PKG_VERSION)/
PKG_HASH:=4bfadccb19e379ce38f5601c72dacf0ac5e03881230afee6df2152ab42fa75c5
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

PKG_LICENSE:=Unlicense
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Adrian Panella <ianchi74@outlook.com>

PKG_BUILD_DEPENDS:=python/host zip/host

include $(INCLUDE_DIR)/package.mk

define Package/youtube-dl
  SECTION:=multimedia
  CATEGORY:=Multimedia
  TITLE:=utility to download videos from YouTube.com
  DEPENDS:=+python-openssl +python-email +python-xml +python-codecs +python-ctypes +ca-certificates
  URL:=https://youtube-dl.org
endef

define Package/youtube-dl/description
  youtube-dl is a small command-line program to download videos 
  from YouTube.com and a few more sites. 
  It requires the Python interpreter.
endef

define Package/youtube-dl/install
	$(INSTALL_DIR) $(1)/usr/bin
	
	python -m compileall $(PKG_BUILD_DIR)/youtube_dl/
	cd $(PKG_BUILD_DIR) && zip --quiet youtube-dl-c.zip youtube_dl/*.pyc youtube_dl/*/*.pyc
	cd $(PKG_BUILD_DIR) && zip --quiet --junk-paths youtube-dl-c.zip youtube_dl/__main__.pyc
	echo '#!/usr/bin/env python' > $(PKG_BUILD_DIR)/youtube-dl-c
	cat $(PKG_BUILD_DIR)/youtube-dl-c.zip >> $(PKG_BUILD_DIR)/youtube-dl-c
	
	$(INSTALL_BIN) -T $(PKG_BUILD_DIR)/youtube-dl-c $(1)/usr/bin/youtube-dl
endef

$(eval $(call BuildPackage,youtube-dl))
