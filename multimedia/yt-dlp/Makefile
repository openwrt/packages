include $(TOPDIR)/rules.mk

PKG_NAME:=yt-dlp
PKG_VERSION:=2025.9.5
PKG_RELEASE:=1

PYPI_NAME:=yt-dlp
PKG_HASH:=9ce080f80b2258e872fe8a75f4707ea2c644e697477186e20b9a04d9a9ea37cf
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
  TITLE:=A feature-rich command-line audio/video downloader
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
  yt-dlp is a feature-rich command-line audio/video downloader with support for
  thousands of sites.
endef

$(eval $(call Py3Package,yt-dlp))
$(eval $(call BuildPackage,yt-dlp))
$(eval $(call BuildPackage,yt-dlp-src))
