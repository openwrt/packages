#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=alsa-utils
PKG_VERSION:=1.0.28
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=ftp://ftp.alsa-project.org/pub/utils/ \
		http://alsa.cybermirror.org/utils/
PKG_MD5SUM:=361552d5b1cacd0a1e7ba09e69990211
PKG_INSTALL:=1
PKG_MAINTAINER:=Ted Hess <thess@kitschensync.net>

include $(INCLUDE_DIR)/package.mk

define Package/alsa-utils
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+alsa-lib +libncurses +libpthread
  TITLE:=ALSA (Advanced Linux Sound Architecture) utilities
  URL:=http://www.alsa-project.org/
endef

define Package/alsa-utils-seq
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+alsa-lib +libpthread
  TITLE:=ALSA sequencer utilities
  URL:=http://www.alsa-project.org/
endef

define Package/alsa-utils-tests
  $(call Package/alsa-utils/Default)
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=ALSA utilities test data (adds ~1.3M to image)
  DEPENDS:=+alsa-lib +libpthread
endef

define Build/Configure
	$(call Build/Configure/Default, \
		--disable-rpath \
		--disable-alsatest \
		--disable-xmlto \
		, \
		ac_cv_prog_ncurses5_config=no \
		ac_cv_prog_ncursesw5_config=no \
	)
endef

define Package/alsa-utils/install
	$(INSTALL_DIR) $(1)/usr/{s,}bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/amixer $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/alsamixer $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/aplay $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/arecord $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/alsactl $(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/usr/share/alsa/init
	$(INSTALL_DATA) \
	    $(PKG_INSTALL_DIR)/usr/share/alsa/init/* \
	    $(1)/usr/share/alsa/init/
endef

define Package/alsa-utils-seq/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/aconnect $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/amidi $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/aplaymidi $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/arecordmidi $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/aseqdump $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/aseqnet $(1)/usr/bin/
endef

define Package/alsa-utils-tests/install
	$(INSTALL_DIR) $(1)/usr/{s,}bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/speaker-test $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/share/sounds/alsa
	$(INSTALL_DATA) \
	    $(PKG_INSTALL_DIR)/usr/share/sounds/alsa/* \
	    $(1)/usr/share/sounds/alsa/
endef

$(eval $(call BuildPackage,alsa-utils))
$(eval $(call BuildPackage,alsa-utils-seq))
$(eval $(call BuildPackage,alsa-utils-tests))
