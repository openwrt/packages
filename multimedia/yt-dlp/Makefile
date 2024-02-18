include $(TOPDIR)/rules.mk

PKG_NAME:=yt-dlp
PKG_VERSION:=2023.12.30
PKG_RELEASE:=1

PYPI_NAME:=yt-dlp
PKG_HASH:=a11862e57721b0a0f0883dfeb5a4d79ba213a2d4c45e1880e9fd70f8e6570c38

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
