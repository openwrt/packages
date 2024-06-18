include $(TOPDIR)/rules.mk

PKG_NAME:=yt-dlp
PKG_VERSION:=2024.5.27
PKG_RELEASE:=1

PYPI_NAME:=yt-dlp
PKG_HASH:=3566c0de240d0cd3d1c2285ce655f72ca38dfc618d634d46818b00d89d5288be
PYPI_SOURCE_NAME:=yt_dlp

PKG_MAINTAINER:=Michal Vasilek <michal.vasilek@nic.cz>
PKG_LICENSE:=Unlicense
PKG_LICENSE_FILES:=LICENSE

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
