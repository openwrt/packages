#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gsm
PKG_VERSION:=1.0.13
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.quut.com/gsm
PKG_MD5SUM:=c1ba392ce61dc4aff1c29ea4e92f6df4

PKG_LICENSE:=FREE
PKG_LICENSE_FILES:=COPYRIGHT

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-1.0-pl13

include $(INCLUDE_DIR)/package.mk

define Package/gsm/Default
  TITLE:=GSM transcoding
  URL:=http://www.quut.com/gsm
endef

define Package/gsm/description/Default
 An implementation of the European GSM 06.10 provisional standard
 for full-rate speech transcoding, prI-ETS 300 036, which uses
 RPE/LTP (residual pulse excitation/long term prediction) coding
 at 13 kbit/s.
endef

define Package/libgsm
$(call Package/gsm/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE+= library
endef

define Package/libgsm/description
$(call Package/gsm/description/Default)
 This package contains a shared GSM transcoding library, used by other
 programs.
endef

define Package/gsm-utils
$(call Package/gsm/Default)
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libgsm
  TITLE+= utilities
endef

define Package/gsm-utils/description
$(call Package/gsm/description/Default)
 This package contains GSM transcoding utilities.
endef

define Build/Configure
endef

TARGET_CFLAGS += $(FPIC)

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		LD="$(TARGET_CC)" \
		COPTS="$(TARGET_CFLAGS)" \
		INSTALL_ROOT="$(PKG_INSTALL_DIR)" \
		all install
endef

define Package/libgsm/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgsm.so.* $(1)/usr/lib/
endef

define Package/gsm-utils/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/toast $(1)/usr/bin/
	(cd $(1)/usr/bin; ln -sf toast untoast; ln -sf toast tcat)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/gsm
	$(CP) $(PKG_INSTALL_DIR)/usr/include/gsm.h $(1)/usr/include/gsm/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgsm.{a,so*} $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libgsm))
$(eval $(call BuildPackage,gsm-utils))
