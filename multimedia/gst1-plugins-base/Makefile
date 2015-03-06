#
# Copyright (C) 2008-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gst1-plugins-base
PKG_VERSION:=1.4.5
PKG_RELEASE:=1

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>

PKG_LICENSE:=LGPLv2 GPLv2
PKG_LICENSE_FILES:=COPYING.LIB COPYING

PKG_BUILD_DIR:=$(BUILD_DIR)/gst-plugins-base-$(PKG_VERSION)
PKG_SOURCE:=gst-plugins-base-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=http://gstreamer.freedesktop.org/src/gst-plugins-base/
PKG_MD5SUM:=357165af625c0ca353ab47c5d843920e

PKG_BUILD_DEPENDS:= libgstreamer1
PKG_CONFIG_DEPENDS:= \
	CONFIG_PACKAGE_gst1-mod-alsa \
	CONFIG_PACKAGE_gst1-mod-app \
	CONFIG_PACKAGE_gst1-mod-audioconvert \
	CONFIG_PACKAGE_gst1-mod-audiorate \
	CONFIG_PACKAGE_gst1-mod-audioresample \
	CONFIG_PACKAGE_gst1-mod-audiotestsrc \
	CONFIG_PACKAGE_gst1-mod-gio \
	CONFIG_PACKAGE_gst1-mod-ogg \
	CONFIG_PACKAGE_gst1-mod-tcp \
	CONFIG_PACKAGE_gst1-mod-theora \
	CONFIG_PACKAGE_gst1-mod-videoconvert \
	CONFIG_PACKAGE_gst1-mod-videotestsrc \
	CONFIG_PACKAGE_gst1-mod-volume \
	CONFIG_PACKAGE_gst1-mod-vorbis \
	CONFIG_PACKAGE_libgst1app \

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

GST_BASE_LIBS:=
GST_BASE_MODULES:=

define Package/gstreamer1-base/Default
  CATEGORY:=Multimedia
  SECTION:=multimedia
  TITLE:=GStreamer
  URL:=http://gstreamer.freedesktop.org/
  DEPENDS:= +libgstreamer1 $(ICONV_DEPENDS)
endef

define Package/gstreamer1-base/description/Default
 GStreamer open source multimedia framework
endef


define Package/gst1-plugins-base
$(call Package/gstreamer1-base/Default)
  TITLE+= plugins collection (base)
  DEPENDS+= $(GST_DEPENDS)
  HIDDEN:=1
endef

define Package/gts1-plugins-base/description
$(call Package/gstreamer1-base/description/Default)
 .
 This meta package contains only dependencies to the other libraries and
 plugins from the base plugins collection.
endef

define Package/gstreamer1-plugins-base
  $(call Package/gstreamer1-base/Default)
  TITLE+= plugins collection (base)
  DEPENDS:=+ALL:gst1-plugins-base +gstreamer1-libs
endef

define Package/gstreamer1-plugins-base/config
    menu "Select GStreamer base modules and libraries"
      depends on PACKAGE_gstreamer1-plugins-base


    config gst1-plugins-base-all
      bool "Include all GStreamer base plugins"
      select PACKAGE_gst1-plugins-base

    comment "Modules"

   $(foreach mod,$(GST_BASE_MODULES), \
    config PACKAGE_gst1-mod-$(mod)
      prompt "GStreamer $(mod) module"

   )

    comment "Libraries"

   $(foreach lib,$(GST_BASE_LIBS), \
    config PACKAGE_libgst1$(lib)
      prompt "GStreamer $(lib) library"

   )

  endmenu

endef

GST_COND_SELECT = $(patsubst %,$(if $(CONFIG_PACKAGE_gst1-mod-$(1)),--enable,--disable)-%,$(1))

GST_VERSION:=1.0

CONFIGURE_ARGS += \
	--disable-debug \
	--disable-examples \
	\
	$(call GST_COND_SELECT,alsa) \
	$(call GST_COND_SELECT,app) \
	$(call GST_COND_SELECT,audioconvert) \
	$(call GST_COND_SELECT,audiorate) \
	$(call GST_COND_SELECT,audioresample) \
	$(call GST_COND_SELECT,audiotestsrc) \
	--disable-cdparanoia \
	--disable-freetypetest \
	$(call GST_COND_SELECT,gio) \
	--disable-libvisual \
	$(call GST_COND_SELECT,ogg) \
	--disable-pango \
	--disable-subparse \
	$(call GST_COND_SELECT,tcp) \
	$(call GST_COND_SELECT,theora) \
	$(call GST_COND_SELECT,videorate) \
	$(call GST_COND_SELECT,videoscale) \
	$(call GST_COND_SELECT,videoconvert) \
	$(call GST_COND_SELECT,videotestsrc) \
	$(call GST_COND_SELECT,volume) \
	$(call GST_COND_SELECT,vorbis) \
	--disable-x \
	--disable-xshm \
	--disable-xvideo \
	\
	--without-libiconv-prefix \
	--without-libintl-prefix \
	--without-x \
	\
	--with-audioresample-format=int \

EXTRA_LDFLAGS+= \
	-Wl,-rpath-link=$(STAGING_DIR)/usr/lib \
	$(if $(ICONV_FULL),-liconv) \

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/gstreamer-$(GST_VERSION)
	( cd $(PKG_INSTALL_DIR); $(CP) \
		./usr/include/gstreamer-$(GST_VERSION)/* \
		$(1)/usr/include/gstreamer-$(GST_VERSION)/ \
	)
	$(INSTALL_DIR) $(1)/usr/lib
	( cd $(PKG_INSTALL_DIR); $(CP) \
		./usr/lib/libgst*-$(GST_VERSION).{la,so*} \
		$(1)/usr/lib/ \
	)
	$(INSTALL_DIR) $(1)/usr/lib/gstreamer-$(GST_VERSION)
	( cd $(PKG_INSTALL_DIR); $(CP) \
		./usr/lib/gstreamer-$(GST_VERSION)/libgst*.{la,so} \
		$(1)/usr/lib/gstreamer-$(GST_VERSION)/ \
	)
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	( cd $(PKG_INSTALL_DIR); $(CP) \
		./usr/lib/pkgconfig/gstreamer*-$(GST_VERSION).pc \
		$(1)/usr/lib/pkgconfig/ \
	)
endef


define Package/gst1-plugins-base/install
  true
endef

define Package/gstreamer1-plugins-base/install
  true
endef

# 1: short name
# 2: description
# 3: dependencies on other gstreamer libraries (short name)
# 4: dependencies on other packages
define GstBuildLibrary

  GST_DEPENDS += +libgst1$(1)

  GST_BASE_LIBS+= $(1)

  define Package/libgst1$(1)
    $(call Package/gstreamer1-base/Default)
    TITLE+= $(2) library (base)
    DEPENDS+= $$(foreach p,$(3),+libgst1$$(p)) $(4)
    HIDDEN:=1
  endef

  define Package/libgst1$(1)/description
   $(call Package/gstreamer1-base/description/Default)
   .
   This package contains the GStreamer $(2) library.
  endef

  define Package/libgst1$(1)/install
	$(INSTALL_DIR) $$(1)/usr/lib
	( cd $(PKG_INSTALL_DIR); $(CP) \
		./usr/lib/libgst$(1)-$(GST_VERSION).so.* \
		$$(1)/usr/lib/ \
	)
  endef

  $$(eval $$(call BuildPackage,libgst1$(1)))
endef

$(eval $(call GstBuildLibrary,allocators,allocators,,))
$(eval $(call GstBuildLibrary,app,app,,))
$(eval $(call GstBuildLibrary,audio,audio,tag,))
$(eval $(call GstBuildLibrary,fft,FFT,,))
$(eval $(call GstBuildLibrary,pbutils,utils,audio tag video,))
$(eval $(call GstBuildLibrary,riff,RIFF media,audio tag,,))
$(eval $(call GstBuildLibrary,rtp,RTP,,))
$(eval $(call GstBuildLibrary,rtsp,RTSP,,))
$(eval $(call GstBuildLibrary,sdp,SDP,,))
$(eval $(call GstBuildLibrary,tag,tag support,,))
$(eval $(call GstBuildLibrary,video,video,,))

# 1: short name
# 2: description
# 3: dependencies on other gstreamer libraries (short name)
# 4: dependencies on other gstreamer plugins (short name)
# 5: dependencies on other packages
define GstBuildPlugin

  GST_DEPENDS += +gst1-mod-$(1)

  GST_BASE_MODULES+= $(1)

  define Package/gst1-mod-$(1)
    $(call Package/gstreamer1-base/Default)
    TITLE+= $(2) plugin (base)
    DEPENDS+= $$(foreach p,$(3),+libgst1$$(p)) $$(foreach p,$(4),+gst1-mod-$$(p)) $(5)
    HIDDEN:=1
  endef

  define Package/gst1-mod-$(1)/description
   $(call Package/gstreamer1-base/description/Default)
   .
   This package contains the GStreamer $(2) plugin.
  endef

  define Package/gst1-mod-$(1)/install
	$(INSTALL_DIR) $$(1)/usr/lib/gstreamer-$(GST_VERSION)
	( cd $(PKG_INSTALL_DIR); $(CP) \
		./usr/lib/gstreamer-$(GST_VERSION)/libgst$(1).so* \
		$$(1)/usr/lib/gstreamer-$(GST_VERSION)/ \
	)
  endef

  $$(eval $$(call BuildPackage,gst1-mod-$(1)))
endef

$(eval $(call GstBuildPlugin,alsa,ALSA,audio tag,,+alsa-lib))
$(eval $(call GstBuildPlugin,app,app,app,,))
$(eval $(call GstBuildPlugin,audioconvert,audio format conversion,audio,,))
$(eval $(call GstBuildPlugin,audiorate,audio rate adjusting,audio tag,,))
$(eval $(call GstBuildPlugin,audioresample,audio resampling,audio tag,,))
$(eval $(call GstBuildPlugin,audiotestsrc,audio test,audio tag controller,,))
$(eval $(call GstBuildPlugin,playback,media decoder (v2),pbutils,,))
$(eval $(call GstBuildPlugin,gio,GIO,,,))
$(eval $(call GstBuildPlugin,ogg,Ogg,riff tag pbutils video,,+libogg))
$(eval $(call GstBuildPlugin,tcp,TCP,,,))
$(eval $(call GstBuildPlugin,theora,Theora,tag video,,+libogg +libtheora))
$(eval $(call GstBuildPlugin,typefindfunctions,'typefind' functions,audio pbutils tag video,,))
$(eval $(call GstBuildPlugin,videoconvert,video format conversion,video,,))
$(eval $(call GstBuildPlugin,videorate,Adjusts video frames,video,,))
$(eval $(call GstBuildPlugin,videoscale,Resizes video,video,,))
$(eval $(call GstBuildPlugin,videotestsrc,video test,video,,+liboil))
$(eval $(call GstBuildPlugin,volume,volume,audio controller,,+liboil))
$(eval $(call GstBuildPlugin,vorbis,Vorbis,audio tag,ogg,+libvorbis))

$(eval $(call BuildPackage,gstreamer1-plugins-base))
$(eval $(call BuildPackage,gst1-plugins-base))
