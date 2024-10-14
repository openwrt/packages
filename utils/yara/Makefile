#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=yara
PKG_VERSION:=4.5.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/VirusTotal/yara
PKG_MIRROR_HASH:=1b549a5aa3320ed768398b0152cb194a7e30c24275fc054facdb4d41bf729cb4

PKG_MAINTAINER:=Marko Ratkaj <markoratkaj@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:virustotal:yara

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/yara
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Pattern matching swiss knife for malware researchers
  URL:=http://virustotal.github.io/yara/
  DEPENDS:= +libopenssl
  DEPENDS+= +YARA_module_magic:file
  DEPENDS+= +YARA_module_cuckoo:jansson
  MENU:=1
endef

define Package/yara/description
  YARA is a tool aimed at (but not limited to) helping malware researchers
  to identify and classify malware samples. With YARA you can create
  descriptions of malware families based on textual or binary patterns.
endef

CONFIGURE_ARGS += \
	$(if $(CONFIG_YARA_module_dotnet),--enable,--disable)-dotnet \
	$(if $(CONFIG_YARA_module_magic),--enable,--disable)-magic \
	$(if $(CONFIG_YARA_module_cuckoo),--enable,--disable)-cuckoo

TARGET_CFLAGS += -D_LARGEFILE64_SOURCE

define Package/yara/config
	source "$(SOURCE)/Config.in"
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/yara.h $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/include/yara
	$(CP) $(PKG_INSTALL_DIR)/usr/include/yara/* $(1)/usr/include/yara
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libyara.{a,la,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/yara.pc $(1)/usr/lib/pkgconfig
endef

define Package/yara/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/yara $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/yarac $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libyara.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,yara))
