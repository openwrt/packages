#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=audiofile
PKG_VERSION:=0.3.6
PKG_RELEASE:=5

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@GNOME/$(PKG_NAME)/0.3
PKG_HASH:=ea2449ad3f201ec590d811db9da6d02ffc5e87a677d06b92ab15363d8cb59782

PKG_MAINTAINER:=Ted Hess <thess@kitschensync.net>
PKG_CPE_ID:=cpe:/a:audiofile:audiofile

PKG_FIXUP:=autoreconf
PKG_INSTALL=1

include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/package.mk

define Package/libaudiofile
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Audio File library
  URL:=http://audiofile.68k.org/
  DEPENDS:=$(CXX_DEPENDS) +libflac
endef

define Package/libaudiofile/description
 The audiofile library allows the processing of audio data to and from audio
 files of many common formats (currently AIFF, AIFF-C, WAVE, NeXT/Sun, BICS,
 FLAC, ALAC, and raw data).
endef

CONFIGURE_ARGS+= \
	--enable-shared \
	--enable-static \
	--disable-docs \
	--disable-coverage \
	--disable-examples


TARGET_CFLAGS+= $(FPIC)

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/{af_vfs,audiofile,aupvlist}.h \
		$(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libaudiofile.{la,a,so*} \
		$(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/audiofile.pc \
		$(1)/usr/lib/pkgconfig/
endef

define Package/libaudiofile/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libaudiofile.so.* \
		$(1)/usr/lib/
endef

$(eval $(call BuildPackage,libaudiofile))
