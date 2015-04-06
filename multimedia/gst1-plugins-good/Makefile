#
# Copyright (C) 2009-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gst1-plugins-good
PKG_VERSION:=1.4.5
PKG_RELEASE:=2

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>

PKG_LICENSE:=LGPLv2
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_DIR:=$(BUILD_DIR)/gst-plugins-good-$(PKG_VERSION)
PKG_SOURCE:=gst-plugins-good-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=http://gstreamer.freedesktop.org/src/gst-plugins-good/
PKG_MD5SUM:=eaf1a6daf73749bc423feac301d60038

PKG_BUILD_DEPENDS:= libgstreamer1 gstreamer1-plugins-base

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

GST_GOOD_MODULES:=

define Package/gstreamer1-good/Default
  CATEGORY:=Multimedia
  SECTION:=multimedia
  TITLE:=GStreamer
  URL:=http://gstreamer.freedesktop.org/
  DEPENDS:= +libgstreamer1 $(ICONV_DEPENDS)
endef

define Package/gstreamer1-good/description/Default
 GStreamer open source multimedia framework
endef


define Package/gst1-plugins-good
$(call Package/gstreamer1-good/Default)
  TITLE+= plugins collection (good)
  DEPENDS+= $(GST_DEPENDS)
  HIDDEN:=1
endef

define Package/gst1-plugins-good/description
$(call Package/gstreamer1-good/description/Default)
 .
 This meta package contains only dependencies to the other plugins from
 the good plugins collection.
endef


define Package/gstreamer1-plugins-good
  $(call Package/gstreamer1-good/Default)
  TITLE+= plugins collection (good)
  DEPENDS:=+ALL:gst1-plugins-good +gstreamer1-plugins-base
endef

define Package/gstreamer1-plugins-good/config
    menu "Select GStreamer good modules"
      depends on PACKAGE_gstreamer1-plugins-good


    config gst1-plugins-good-all
      bool "Include all GStreamer good plugins"
      select PACKAGE_gst1-plugins-good

    comment "Modules"

   $(foreach mod,$(GST_GOOD_MODULES), \
    config PACKAGE_gst1-mod-$(mod)
      prompt "GStreamer $(mod) module"

   )

  endmenu

endef

GST_VERSION:=1.0

CONFIGURE_ARGS += \
	--disable-debug \
	--disable-examples \
	\
	--disable-aalib \
	--disable-annodex \
	--disable-bz2 \
	--disable-cairo \
	--disable-directsound \
	--disable-dv1394 \
	--disable-esd \
	--disable-gconf \
	--disable-gconftool \
	--disable-gdk_pixbuf \
	--disable-hal \
	--disable-libcaca \
	--disable-libdv \
	--disable-osx_audio \
	--disable-osx_video \
	--disable-pulse \
	--disable-qtdemux \
	--disable-rtspmanager \
	--disable-shout2 \
	--disable-sunaudio \
	--disable-wavpack \
	--disable-x \
	--disable-xshm \
	--disable-xvideo \
	--disable-y4m \
	--disable-zlib \
	\
	--without-libiconv-prefix \
	--without-libintl-prefix \
	--without-x \

EXTRA_LDFLAGS+= \
	-Wl,-rpath-link=$(STAGING_DIR)/usr/lib \
	$(if $(ICONV_FULL),-liconv) \


define Package/gst1-plugins-good/install
	/bin/true
endef


# 1: short name
# 2: description
# 3: dependencies on other gstreamer libraries (short name)
# 4: dependencies on other gstreamer plugins (short name)
# 5: dependencies on other packages
define GstBuildPlugin

  GST_DEPENDS += +gst1-mod-$(1)

  GST_GOOD_MODULES+= $(1)

  define Package/gst1-mod-$(1)
    $(call Package/gstreamer1-good/Default)
    TITLE+= $(2) plugin (good)
    DEPENDS+= $$(foreach p,$(3),+libgst1$$(p)) $$(foreach p,$(4),+gst1-mod-$$(p)) $(5)
    HIDDEN:=1
  endef

  define Package/gst1-mod-$(1)/description
   $(call Package/gstreamer1-good/description/Default)
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

#$(eval $(call GstBuildPlugin,1394,IEEE 1394 support,,,))
$(eval $(call GstBuildPlugin,alaw,alaw codec,audio,,))
$(eval $(call GstBuildPlugin,alpha,alpha support,video,,))
$(eval $(call GstBuildPlugin,alphacolor,alphacolor support,video,,))
$(eval $(call GstBuildPlugin,apetag,apetag support,audio pbutils tag video,,))
$(eval $(call GstBuildPlugin,audiofx,audio effects,audio fft controller,,))
$(eval $(call GstBuildPlugin,audioparsers,audioparsers,audio tag pbutils,,))
$(eval $(call GstBuildPlugin,auparse,auparse,audio tag pbutils,,))
$(eval $(call GstBuildPlugin,autodetect,format auto-detection,,,))
$(eval $(call GstBuildPlugin,avi,avi support,audio riff tag video,,))
$(eval $(call GstBuildPlugin,cutter,audio cutter,audio,,))
$(eval $(call GstBuildPlugin,debug,debugging,,,))
$(eval $(call GstBuildPlugin,deinterlace,deinterlace support,video,,))
$(eval $(call GstBuildPlugin,dtmf,dtmf support,rtp,,))
#$(eval $(call GstBuildPlugin,dv,dv support,audio tag video,,))
$(eval $(call GstBuildPlugin,effectv,effectvsupport,video,,))
$(eval $(call GstBuildPlugin,equalizer,audio equalizer,audio controller,,))
$(eval $(call GstBuildPlugin,flac,FLAC codec,audio pbutils tag,,+libflac))
$(eval $(call GstBuildPlugin,flv,flv codec,audio pbutils tag video,,))
$(eval $(call GstBuildPlugin,flxdec,flx codec,,,))
#$(eval $(call GstBuildPlugin,gdkpixbuf,gdkpixbuf support,video,,))
$(eval $(call GstBuildPlugin,goom2k1,goom support,,,))
$(eval $(call GstBuildPlugin,goom,goom support,,,))
$(eval $(call GstBuildPlugin,icydemux,icy demuxer,audio tag,,))
$(eval $(call GstBuildPlugin,id3demux,ID3v1/v2 demuxer,pbutils tag,,))
$(eval $(call GstBuildPlugin,imagefreeze,imagefreeze support,,,))
$(eval $(call GstBuildPlugin,interleave,audio interleave,audio,,))
$(eval $(call GstBuildPlugin,isomp4,isomp4 support,audio pbutils riff rtp tag video,,))
#$(eval $(call GstBuildPlugin,jack,jack support,audio,,))
$(eval $(call GstBuildPlugin,jpeg,jpeg support,video,,+libjpeg))
$(eval $(call GstBuildPlugin,level,audio level,audio,,))
$(eval $(call GstBuildPlugin,matroska,matroska support,audio pbutils riff tag video,,))
$(eval $(call GstBuildPlugin,mulaw,mulaw support,audio,,))
$(eval $(call GstBuildPlugin,multifile,multiple files access,video,,))
$(eval $(call GstBuildPlugin,multipart,multipart stream handling,,,))
$(eval $(call GstBuildPlugin,navigationtest,navigationtest support,video,,))
$(eval $(call GstBuildPlugin,oss4audio,OSS 4 audio support,audio tag,,))
$(eval $(call GstBuildPlugin,ossaudio,OSS audio support,audio,,))
$(eval $(call GstBuildPlugin,png,png support,video,,+libpng))
#$(eval $(call GstBuildPlugin,pulse,pulse support,audio pbutils tag video,,))
$(eval $(call GstBuildPlugin,replaygain,volume normalization,pbutils,,))
$(eval $(call GstBuildPlugin,rtpmanager,RTP manager,audio net rtp tag pbutils video,,))
$(eval $(call GstBuildPlugin,rtp,RTP,audio rtp tag pbutils video,,))
$(eval $(call GstBuildPlugin,rtsp,RTSP,net rtp rtsp sdp,,))
$(eval $(call GstBuildPlugin,shapewipe,shapewipe support,video,,))
#$(eval $(call GstBuildPlugin,shout2,shout2 support,,,))
$(eval $(call GstBuildPlugin,smpte,smpte support,video,,))
$(eval $(call GstBuildPlugin,souphttpsrc,soup input,audio tag,,+libsoup))
$(eval $(call GstBuildPlugin,spectrum,spectrum data output,audio fft,,))
#$(eval $(call GstBuildPlugin,speex,speex support,audio tag,,))
#$(eval $(call GstBuildPlugin,sty4menc,sty4menc support,video,,))
#$(eval $(call GstBuildPlugin,taglib,taglib support,tag,,))
$(eval $(call GstBuildPlugin,udp,UDP,net,,))
$(eval $(call GstBuildPlugin,video4linux2,video4linux2 support,video allocators,,+libv4l))
$(eval $(call GstBuildPlugin,videobox,videobox support,video,,))
$(eval $(call GstBuildPlugin,videocrop,videocrop support,video,,))
$(eval $(call GstBuildPlugin,videofilter,videofilter support,video,,))
$(eval $(call GstBuildPlugin,videomixer,videomixer support,video,,))
$(eval $(call GstBuildPlugin,vpx,vpx support,tag video,,+libvpx))
$(eval $(call GstBuildPlugin,wavenc,Wav encoder,riff,,))
#$(eval $(call GstBuildPlugin,wavpack,Wav packer,audio riff tag,,))
$(eval $(call GstBuildPlugin,wavparse,Wav parser,audio riff tag,,))
#$(eval $(call GstBuildPlugin,ximagesrc,ximagesrc support,video,,))

$(eval $(call BuildPackage,gstreamer1-plugins-good))
$(eval $(call BuildPackage,gst1-plugins-good))
