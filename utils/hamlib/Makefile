#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=hamlib
PKG_VERSION:=1.2.15.3
PKG_RELEASE:=3
PKG_MD5SUM:=3cad8987e995a00e5e9d360e2be0eb43

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/hamlib
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=COPYING

PKG_MAINTAINER:=Vasilis Tsiligiannis <acinonyx@openwrt.gr>

include $(INCLUDE_DIR)/package.mk

define Package/hamlib/Default
  TITLE:=Ham Radio Control
  URL:=http://hamlib.sourceforge.net
endef

define Package/hamlib/Default/description
  Ham Radio Control Libraries is a development effort to provide a consistent
  interface for programmers wanting to incorporate radio control in their
  programs.
endef

define Package/hamlib
  $(call Package/hamlib/Default)
  TITLE+= utilities
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libpthread +libhamlib
endef

define Package/hamlib/description
  $(call Package/hamlib/Default/description)

  This package contains the utilities and daemons.
endef

define Package/libhamlib/Default
  $(call Package/hamlib/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE+= shared library
endef

define Package/libhamlib
  $(call Package/libhamlib/Default)
  DEPENDS:=+libusb-1.0 +libltdl
  MENU:=1
endef

define Package/libhamlib/description
  $(call Package/hamlib/Default/description)

  This package contains the hamlib shared library.
endef

define Package/hamlib-adat
  $(call Package/libhamlib/Default)
  TITLE:= for ADAT
  DEPENDS:=libhamlib
endef

define Package/hamlib-alinco
  $(call Package/libhamlib/Default)
  TITLE:= for Alinco
  DEPENDS:=libhamlib
endef

define Package/hamlib-amsat
  $(call Package/libhamlib/Default)
  TITLE:= for AMSAT
  DEPENDS:=libhamlib
endef

define Package/hamlib-aor
  $(call Package/libhamlib/Default)
  TITLE:= for AOR
  DEPENDS:=libhamlib
endef

define Package/hamlib-ars
  $(call Package/libhamlib/Default)
  TITLE:= for ARS
  DEPENDS:=libhamlib
endef

define Package/hamlib-celestron
  $(call Package/libhamlib/Default)
  TITLE:= for Celestron
  DEPENDS:=libhamlib
endef

define Package/hamlib-drake
  $(call Package/libhamlib/Default)
  TITLE:= for Drake
  DEPENDS:=libhamlib
endef

define Package/hamlib-dummy
  $(call Package/libhamlib/Default)
  TITLE:= for dummy
  DEPENDS:=libhamlib
endef

define Package/hamlib-easycomm
  $(call Package/libhamlib/Default)
  TITLE:= for EasyComm
  DEPENDS:=libhamlib
endef

define Package/hamlib-flexradio
  $(call Package/libhamlib/Default)
  TITLE:= for FlexRadio
  DEPENDS:=libhamlib
endef

define Package/hamlib-fodtrack
  $(call Package/libhamlib/Default)
  TITLE:= for FodTrack
  DEPENDS:=libhamlib
endef

define Package/hamlib-gs232a
  $(call Package/libhamlib/Default)
  TITLE:= for GS-232A
  DEPENDS:=libhamlib
endef

define Package/hamlib-heathkit
  $(call Package/libhamlib/Default)
  TITLE:= for Heathkit
  DEPENDS:=libhamlib
endef

define Package/hamlib-icom
  $(call Package/libhamlib/Default)
  TITLE:= for ICOM
  DEPENDS:=libhamlib
endef

define Package/hamlib-jrc
  $(call Package/libhamlib/Default)
  TITLE:= for JRC
  DEPENDS:=libhamlib
endef

define Package/hamlib-kachina
  $(call Package/libhamlib/Default)
  TITLE:= for Kachina
  DEPENDS:=libhamlib
endef

define Package/hamlib-kenwood
  $(call Package/libhamlib/Default)
  TITLE:= for Kenwood
  DEPENDS:=libhamlib
endef

define Package/hamlib-kit
  $(call Package/libhamlib/Default)
  TITLE:= for kits
  DEPENDS:=libhamlib
endef

define Package/hamlib-lowe
  $(call Package/libhamlib/Default)
  TITLE:= for Lowe
  DEPENDS:=libhamlib
endef

define Package/hamlib-m2
  $(call Package/libhamlib/Default)
  TITLE:= for M2
  DEPENDS:=libhamlib
endef

define Package/hamlib-pcr
  $(call Package/libhamlib/Default)
  TITLE:= for PCR
  DEPENDS:=libhamlib
endef

define Package/hamlib-prm80
  $(call Package/libhamlib/Default)
  TITLE:= for PRM80
  DEPENDS:=libhamlib
endef

define Package/hamlib-racal
  $(call Package/libhamlib/Default)
  TITLE:= for Racal
  DEPENDS:=libhamlib
endef

define Package/hamlib-rft
  $(call Package/libhamlib/Default)
  TITLE:= for RFT
  DEPENDS:=libhamlib
endef

define Package/hamlib-rotorez
  $(call Package/libhamlib/Default)
  TITLE:= for Rotor-EZ
  DEPENDS:=libhamlib
endef

define Package/hamlib-rs
  $(call Package/libhamlib/Default)
  TITLE:= for R&S
  DEPENDS:=libhamlib
endef

define Package/hamlib-sartek
  $(call Package/libhamlib/Default)
  TITLE:= for SARtek
  DEPENDS:=libhamlib
endef

define Package/hamlib-skanti
  $(call Package/libhamlib/Default)
  TITLE:= for Skanti
  DEPENDS:=libhamlib
endef

define Package/hamlib-spid
  $(call Package/libhamlib/Default)
  TITLE:= for SPID
  DEPENDS:=libhamlib
endef

define Package/hamlib-tapr
  $(call Package/libhamlib/Default)
  TITLE:= for TAPR
  DEPENDS:=libhamlib
endef

define Package/hamlib-tentec
  $(call Package/libhamlib/Default)
  TITLE:= for TenTec
  DEPENDS:=libhamlib
endef

define Package/hamlib-ts7400
  $(call Package/libhamlib/Default)
  TITLE:= for TS-7400
  DEPENDS:=libhamlib
endef

define Package/hamlib-tuner
  $(call Package/libhamlib/Default)
  TITLE:= for Video for Linux tuner
  DEPENDS:=libhamlib
endef

define Package/hamlib-uniden
  $(call Package/libhamlib/Default)
  TITLE:= for Uniden
  DEPENDS:=libhamlib
endef

define Package/hamlib-wj
  $(call Package/libhamlib/Default)
  TITLE:= for Watkins - Johnson
  DEPENDS:=libhamlib
endef

define Package/hamlib-yaesu
  $(call Package/libhamlib/Default)
  TITLE:= for Yaesu
  DEPENDS:=libhamlib
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/include/hamlib/*.h $(1)/usr/include/hamlib
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libhamlib.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/hamlib.pc $(1)/usr/lib/pkgconfig/
endef

CONFIGURE_ARGS+= \
	--without-cxx-binding \
	--without-winradio \
	--without-rpc-backends \
	--with-pic \

define Package/hamlib/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/{rig,rot}* $(1)/usr/bin/
endef

define Package/libhamlib/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libhamlib.so* $(1)/usr/lib/
endef

define Package/hamlib-adat/install
	$(INSTALL_DIR) $(1)/usr/lib/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/hamlib/hamlib-adat.so* $(1)/usr/lib/hamlib
endef

define Package/hamlib-alinco/install
	$(INSTALL_DIR) $(1)/usr/lib/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/hamlib/hamlib-alinco.so* $(1)/usr/lib/hamlib
endef

define Package/hamlib-amsat/install
	$(INSTALL_DIR) $(1)/usr/lib/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/hamlib/hamlib-amsat.so* $(1)/usr/lib/hamlib
endef

define Package/hamlib-aor/install
	$(INSTALL_DIR) $(1)/usr/lib/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/hamlib/hamlib-aor.so* $(1)/usr/lib/hamlib
endef

define Package/hamlib-ars/install
	$(INSTALL_DIR) $(1)/usr/lib/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/hamlib/hamlib-ars.so* $(1)/usr/lib/hamlib
endef

define Package/hamlib-celestron/install
	$(INSTALL_DIR) $(1)/usr/lib/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/hamlib/hamlib-celestron.so* $(1)/usr/lib/hamlib
endef

define Package/hamlib-drake/install
	$(INSTALL_DIR) $(1)/usr/lib/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/hamlib/hamlib-drake.so* $(1)/usr/lib/hamlib
endef

define Package/hamlib-dummy/install
	$(INSTALL_DIR) $(1)/usr/lib/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/hamlib/hamlib-dummy.so* $(1)/usr/lib/hamlib
endef

define Package/hamlib-easycomm/install
	$(INSTALL_DIR) $(1)/usr/lib/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/hamlib/hamlib-easycomm.so* $(1)/usr/lib/hamlib
endef

define Package/hamlib-flexradio/install
	$(INSTALL_DIR) $(1)/usr/lib/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/hamlib/hamlib-flexradio.so* $(1)/usr/lib/hamlib
endef

define Package/hamlib-fodtrack/install
	$(INSTALL_DIR) $(1)/usr/lib/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/hamlib/hamlib-fodtrack.so* $(1)/usr/lib/hamlib
endef

define Package/hamlib-gs232a/install
	$(INSTALL_DIR) $(1)/usr/lib/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/hamlib/hamlib-gs232a.so* $(1)/usr/lib/hamlib
endef

define Package/hamlib-heathkit/install
	$(INSTALL_DIR) $(1)/usr/lib/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/hamlib/hamlib-heathkit.so* $(1)/usr/lib/hamlib
endef

define Package/hamlib-icom/install
	$(INSTALL_DIR) $(1)/usr/lib/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/hamlib/hamlib-icom.so* $(1)/usr/lib/hamlib
endef

define Package/hamlib-jrc/install
	$(INSTALL_DIR) $(1)/usr/lib/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/hamlib/hamlib-jrc.so* $(1)/usr/lib/hamlib
endef

define Package/hamlib-kachina/install
	$(INSTALL_DIR) $(1)/usr/lib/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/hamlib/hamlib-kachina.so* $(1)/usr/lib/hamlib
endef

define Package/hamlib-kenwood/install
	$(INSTALL_DIR) $(1)/usr/lib/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/hamlib/hamlib-kenwood.so* $(1)/usr/lib/hamlib
endef

define Package/hamlib-kit/install
	$(INSTALL_DIR) $(1)/usr/lib/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/hamlib/hamlib-kit.so* $(1)/usr/lib/hamlib
endef

define Package/hamlib-lowe/install
	$(INSTALL_DIR) $(1)/usr/lib/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/hamlib/hamlib-lowe.so* $(1)/usr/lib/hamlib
endef

define Package/hamlib-m2/install
	$(INSTALL_DIR) $(1)/usr/lib/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/hamlib/hamlib-m2.so* $(1)/usr/lib/hamlib
endef

define Package/hamlib-pcr/install
	$(INSTALL_DIR) $(1)/usr/lib/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/hamlib/hamlib-pcr.so* $(1)/usr/lib/hamlib
endef

define Package/hamlib-prm80/install
	$(INSTALL_DIR) $(1)/usr/lib/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/hamlib/hamlib-prm80.so* $(1)/usr/lib/hamlib
endef

define Package/hamlib-racal/install
	$(INSTALL_DIR) $(1)/usr/lib/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/hamlib/hamlib-racal.so* $(1)/usr/lib/hamlib
endef

define Package/hamlib-rft/install
	$(INSTALL_DIR) $(1)/usr/lib/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/hamlib/hamlib-rft.so* $(1)/usr/lib/hamlib
endef

define Package/hamlib-rotorez/install
	$(INSTALL_DIR) $(1)/usr/lib/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/hamlib/hamlib-rotorez.so* $(1)/usr/lib/hamlib
endef

define Package/hamlib-rs/install
	$(INSTALL_DIR) $(1)/usr/lib/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/hamlib/hamlib-rs.so* $(1)/usr/lib/hamlib
endef

define Package/hamlib-sartek/install
	$(INSTALL_DIR) $(1)/usr/lib/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/hamlib/hamlib-sartek.so* $(1)/usr/lib/hamlib
endef

define Package/hamlib-skanti/install
	$(INSTALL_DIR) $(1)/usr/lib/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/hamlib/hamlib-skanti.so* $(1)/usr/lib/hamlib
endef

define Package/hamlib-spid/install
	$(INSTALL_DIR) $(1)/usr/lib/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/hamlib/hamlib-spid.so* $(1)/usr/lib/hamlib
endef

define Package/hamlib-tapr/install
	$(INSTALL_DIR) $(1)/usr/lib/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/hamlib/hamlib-tapr.so* $(1)/usr/lib/hamlib
endef

define Package/hamlib-tentec/install
	$(INSTALL_DIR) $(1)/usr/lib/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/hamlib/hamlib-tentec.so* $(1)/usr/lib/hamlib
endef

define Package/hamlib-ts7400/install
	$(INSTALL_DIR) $(1)/usr/lib/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/hamlib/hamlib-ts7400.so* $(1)/usr/lib/hamlib
endef

define Package/hamlib-tuner/install
	$(INSTALL_DIR) $(1)/usr/lib/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/hamlib/hamlib-tuner.so* $(1)/usr/lib/hamlib
endef

define Package/hamlib-uniden/install
	$(INSTALL_DIR) $(1)/usr/lib/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/hamlib/hamlib-uniden.so* $(1)/usr/lib/hamlib
endef

define Package/hamlib-wj/install
	$(INSTALL_DIR) $(1)/usr/lib/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/hamlib/hamlib-wj.so* $(1)/usr/lib/hamlib
endef

define Package/hamlib-yaesu/install
	$(INSTALL_DIR) $(1)/usr/lib/hamlib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/hamlib/hamlib-yaesu.so* $(1)/usr/lib/hamlib
endef

$(eval $(call BuildPackage,hamlib))
$(eval $(call BuildPackage,libhamlib))
$(eval $(call BuildPackage,hamlib-adat))
$(eval $(call BuildPackage,hamlib-alinco))
$(eval $(call BuildPackage,hamlib-amsat))
$(eval $(call BuildPackage,hamlib-aor))
$(eval $(call BuildPackage,hamlib-ars))
$(eval $(call BuildPackage,hamlib-celestron))
$(eval $(call BuildPackage,hamlib-drake))
$(eval $(call BuildPackage,hamlib-dummy))
$(eval $(call BuildPackage,hamlib-easycomm))
$(eval $(call BuildPackage,hamlib-flexradio))
$(eval $(call BuildPackage,hamlib-fodtrack))
$(eval $(call BuildPackage,hamlib-gs232a))
$(eval $(call BuildPackage,hamlib-heathkit))
$(eval $(call BuildPackage,hamlib-icom))
$(eval $(call BuildPackage,hamlib-jrc))
$(eval $(call BuildPackage,hamlib-kachina))
$(eval $(call BuildPackage,hamlib-kenwood))
$(eval $(call BuildPackage,hamlib-kit))
$(eval $(call BuildPackage,hamlib-lowe))
$(eval $(call BuildPackage,hamlib-m2))
$(eval $(call BuildPackage,hamlib-pcr))
$(eval $(call BuildPackage,hamlib-prm80))
$(eval $(call BuildPackage,hamlib-racal))
$(eval $(call BuildPackage,hamlib-rft))
$(eval $(call BuildPackage,hamlib-rotorez))
$(eval $(call BuildPackage,hamlib-rs))
$(eval $(call BuildPackage,hamlib-sartek))
$(eval $(call BuildPackage,hamlib-skanti))
$(eval $(call BuildPackage,hamlib-spid))
$(eval $(call BuildPackage,hamlib-tapr))
$(eval $(call BuildPackage,hamlib-tentec))
$(eval $(call BuildPackage,hamlib-ts7400))
$(eval $(call BuildPackage,hamlib-tuner))
$(eval $(call BuildPackage,hamlib-uniden))
$(eval $(call BuildPackage,hamlib-wj))
$(eval $(call BuildPackage,hamlib-yaesu))

