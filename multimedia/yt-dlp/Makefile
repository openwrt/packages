include $(TOPDIR)/rules.mk

PKG_NAME:=yt-dlp
PKG_VERSION:=2025.3.31
PKG_RELEASE:=2

PYPI_NAME:=yt-dlp
PKG_HASH:=1bfe0e660d1a70a09e27b2d58f92e30b1e2e362cc487829f2f824346ae49fb91
PYPI_SOURCE_NAME:=yt_dlp

PKG_MAINTAINER:=George Sapkin <george@sapk.in>
PKG_LICENSE:=Unlicense
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:yt-dlp_project:yt-dlp

PKG_BUILD_DEPENDS:=python-hatchling/host

include ../../lang/python/pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python3-package.mk

define Package/yt-dlp
  SECTION:=multimedia
  CATEGORY:=Multimedia
  TITLE:=Utility to download videos from YouTube.com
  URL:=https://github.com/yt-dlp/yt-dlp
  PROVIDES:=youtube-dl
  DEPENDS:= \
    +ca-certificates \
    +python3-asyncio \
    +python3-codecs \
    +python3-ctypes \
    +python3-email \
    +python3-logging \
    +python3-openssl \
    +python3-sqlite3 \
    +python3-urllib \
    +python3-uuid \
    +python3-xml
endef

define Package/yt-dlp/description
  yt-dlp is a small command-line program to download videos
  from YouTube.com and other video sites.
  It requires the Python3 interpreter.
endef

$(eval $(call Py3Package,yt-dlp))
$(eval $(call BuildPackage,yt-dlp))
$(eval $(call BuildPackage,yt-dlp-src))
