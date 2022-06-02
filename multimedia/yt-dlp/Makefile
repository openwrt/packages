include $(TOPDIR)/rules.mk

PKG_NAME:=yt-dlp
PKG_VERSION:=2022.5.18
PKG_RELEASE:=1

PYPI_NAME:=yt-dlp
PKG_HASH:=3a7b59d2fb4b39ce8ba8e0b9c5a37fe20e5624f46a2346b4ae66ab1320e35134

PKG_MAINTAINER:=Michal Vasilek <michal.vasilek@nic.cz>
PKG_LICENSE:=Unlicense
PKG_LICENSE_FILES:=LICENSE

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
    +python3-openssl \
    +python3-sqlite3 \
    +python3-urllib \
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
