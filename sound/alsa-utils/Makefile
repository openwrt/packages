#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=alsa-utils
PKG_VERSION:=1.1.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=ftp://ftp.alsa-project.org/pub/utils/ \
		http://alsa.cybermirror.org/utils/
PKG_MD5SUM:=b9d6102fbbd0b68040bb77023ed30c0c
PKG_INSTALL:=1
PKG_MAINTAINER:=Ted Hess <thess@kitschensync.net>

include $(INCLUDE_DIR)/package.mk

define Package/alsa-utils
  SECTION:=sound
  CATEGORY:=Sound
  DEPENDS:=+alsa-lib +libncursesw +libpthread
  TITLE:=ALSA (Advanced Linux Sound Architecture) utilities
  URL:=http://www.alsa-project.org/
endef

define Package/alsa-utils-seq
  SECTION:=sound
  CATEGORY:=Sound
  DEPENDS:=+alsa-lib +libpthread
  TITLE:=ALSA sequencer utilities
  URL:=http://www.alsa-project.org/
endef

define Package/alsa-utils-tests
  SECTION:=sound
  CATEGORY:=Sound
  TITLE:=ALSA utilities test data (adds ~1.3M to image)
  DEPENDS:=+alsa-lib +libpthread
  URL:=http://www.alsa-project.org/
endef

CONFIGURE_ARGS+= \
		--disable-rpath \
		--disable-alsatest \
		--disable-bat \
		--disable-xmlto \
		--with-curses=ncursesw

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
