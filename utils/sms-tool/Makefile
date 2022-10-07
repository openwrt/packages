# 2017 - 2021 Cezary Jackiewicz <cezary@eko.one.pl>
# 2014 lovewilliam <ztong@vt.edu>
# sms tool for various of 3g/4g modem
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sms-tool
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_URL:=https://github.com/obsy/sms_tool
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2022-03-21
PKG_SOURCE_VERSION:=f07699ab5189656f595ffa75872c8938bf4b40ac
PKG_MIRROR_HASH:=0d114a97eb7aeadd95b49281d29371ba0570382125c34f3f8668d34fd0290f46

PKG_MAINTAINER:=Andrey Butirsky <butirsky@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE-2.0.txt

include $(INCLUDE_DIR)/package.mk

define Package/sms-tool
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=SMS tool for 3G/4G modems
  URL:=https://github.com/obsy/sms_tool
endef

define Package/sms-tool/description
  SMS Tool for 3G/4G modem
endef

define Package/sms-tool/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sms_tool $(1)/usr/bin/
endef

$(eval $(call BuildPackage,sms-tool))
