#
# Copyright (C) 2009-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gst1-plugins-ugly
PKG_VERSION:=1.16.0
PKG_RELEASE:=1

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org> \
		Ted Hess <thess@kitschensync.net>

PKG_LICENSE:=LGPLv2
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_DIR:=$(BUILD_DIR)/gst-plugins-ugly-$(PKG_VERSION)
PKG_SOURCE:=gst-plugins-ugly-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://gstreamer.freedesktop.org/src/gst-plugins-ugly
PKG_HASH:=e30964c5f031c32289e0b25e176c3c95a5737f2052dfc81d0f7427ef0233a4c2

PKG_CONFIG_DEPENDS:= \
	CONFIG_PACKAGE_gst1-mod-asf \
	CONFIG_PACKAGE_gst1-mod-mpeg2dec \

PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

GST_UGLY_MODULES:=

define Package/gstreamer1-ugly/Default
  CATEGORY:=Multimedia
  SECTION:=multimedia
  TITLE:=GStreamer
  URL:=https://gstreamer.freedesktop.org/
  DEPENDS:= +libgstreamer1 $(ICONV_DEPENDS)
endef

define Package/gstreamer1-ugly/description/Default
 GStreamer open source multimedia framework
endef


define Package/gst1-plugins-ugly
$(call Package/gstreamer1-ugly/Default)
  TITLE+= plugins collection (ugly)
  DEPENDS+= $(GST_DEPENDS)
  HIDDEN:=1
endef

define Package/gts-plugins-ugly/description
$(call Package/gstreamer1-ugly/description/Default)
 .
 This meta package contains only dependencies to the other plugins from
 the ugly plugins collection.
endef


define Package/gstreamer1-plugins-ugly
  $(call Package/gstreamer1-ugly/Default)
  TITLE+= plugins collection (ugly)
  DEPENDS:=+ALL:gst1-plugins-ugly +gstreamer1-plugins-base
endef

define Package/gstreamer1-plugins-ugly/config
    menu "Select GStreamer ugly modules"
      depends on PACKAGE_gstreamer1-plugins-ugly


    config gst1-plugins-ugly-all
      bool "Include all GStreamer ugly plugins"
      select PACKAGE_gst1-plugins-ugly

    comment "Modules"

   $(foreach mod,$(GST_UGLY_MODULES), \
    config PACKAGE_gst1-mod-$(mod)
      prompt "GStreamer $(mod) module"

   )

  endmenu

endef

GST_COND_SELECT = $(patsubst %,$(if $(CONFIG_PACKAGE_gst1-mod-$(1)),--enable,--disable)-%,$(1))

GST_VERSION:=1.0

CONFIGURE_ARGS += \
	--disable-debug \
	--disable-examples \
	--disable-fatal-warnings \
	--disable-glib-asserts \
	--disable-gobject-cast-checks \
	--disable-gtk-doc-html \
	--disable-valgrind \
	--disable-rpath \
	\
	--disable-a52dec \
	--disable-amrnb \
	--disable-amrwb \
	$(call GST_COND_SELECT,asf) \
	--disable-cdio \
	--disable-dvdlpcmdec \
	--disable-dvdread \
	--disable-dvdsub \
	--disable-iec958 \
	$(call GST_COND_SELECT,mpeg2dec) \
	--disable-mpegaudioparse \
	--disable-mpegstream \
	--disable-realmedia \
	--disable-sidplay \
	--disable-synaesthesia \
	--disable-twolame \
	--disable-x264 \
	\
	--without-libiconv-prefix \
	--without-libintl-prefix \
	--with-pic

define Package/gst1-plugins-ugly/install
	/bin/true
endef


# 1: short name
# 2: description
# 3: dependencies on other gstreamer libraries (short name)
# 4: dependencies on other gstreamer plugins (short name)
# 5: dependencies on other packages
define GstBuildPlugin

  GST_DEPENDS += +gst1-mod-$(1)

  GST_UGLY_MODULES+= $(1)

  define Package/gst1-mod-$(1)
    $(call Package/gstreamer1-ugly/Default)
    TITLE+= $(2) plugin (ugly)
    DEPENDS+= +libgstreamer1 $$(foreach p,$(3),+libgst1$$(p)) $$(foreach p,$(4),+gst1-mod-$$(p)) $(5)
    HIDDEN:=1
  endef

  define Package/gst1-mod-$(1)/description
   $(call Package/gstreamer1-ugly/description/Default)
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

$(eval $(call GstBuildPlugin,asf,ASF demuxer,audio video riff rtp rtsp sdp tag,,))
$(eval $(call GstBuildPlugin,mpeg2dec,MPEG decoder,video,,+libmpeg2))

$(eval $(call BuildPackage,gstreamer1-plugins-ugly))
$(eval $(call BuildPackage,gst1-plugins-ugly))
