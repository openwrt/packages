# 2017 - 2021 Cezary Jackiewicz <cezary@eko.one.pl>
# 2014 lovewilliam <ztong@vt.edu>
# SMS tool for 3G/4G/5G modems
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sms-tool
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/obsy/sms_tool
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2026-11-13
PKG_SOURCE_VERSION:=6d84013450b17ed6567eab42c55d820b17e52e7e
PKG_MIRROR_HASH:=8301657409f3155e3cbf25013a09d83f8773797beb1caa0a6d2396ef0116ef71

PKG_MAINTAINER:=Andrey Butirsky <butirsky@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE-2.0.txt

include $(INCLUDE_DIR)/package.mk

define Package/sms-tool
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=SMS tool for 3G/4G/5G modems
  URL:=https://github.com/obsy/sms_tool
endef

define Package/sms-tool/description
  SMS tool for 3G/4G/5G modems
endef

define Package/sms-tool/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sms_tool $(1)/usr/bin/
endef

$(eval $(call BuildPackage,sms-tool))
