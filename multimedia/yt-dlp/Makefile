# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=yt-dlp
PKG_VERSION:=2026.1.31
PKG_RELEASE:=1

PYPI_NAME:=yt-dlp
PKG_HASH:=16767a3172cbb7183199f4db19e34b77b19e030ab7101b8f26d6c9e6af6f42ae
PYPI_SOURCE_NAME:=yt_dlp

PKG_MAINTAINER:=George Sapkin <george@sapk.in>
PKG_LICENSE:=Unlicense
PKG_LICENSE_FILES:=LICENSE THIRD_PARTY_LICENSES.txt
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
    +python3-xml \
    +quickjs
endef

define Package/yt-dlp/description
  yt-dlp is a feature-rich command-line audio/video downloader with support for
  thousands of sites.
endef

define Package/yt-dlp/conffiles
/etc/yt-dlp.conf
endef

define Py3Package/yt-dlp/install
	if [ -d $(PKG_INSTALL_DIR)/usr/bin ]; then \
		$(INSTALL_DIR) $(1)/usr/bin ; \
		$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/ ; \
	fi

	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) ./files/yt-dlp.conf $(1)/etc/yt-dlp.conf
endef

$(eval $(call Py3Package,yt-dlp))
$(eval $(call BuildPackage,yt-dlp))
$(eval $(call BuildPackage,yt-dlp-src))
