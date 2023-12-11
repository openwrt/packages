include $(TOPDIR)/rules.mk

PKG_NAME:=tvheadend
PKG_VERSION:=2023-06-05
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/tvheadend/tvheadend.git
PKG_MIRROR_HASH:=921506f54a93fa78ba17578a0ef127f4eebd4df0691aef5905cd1eb2eae52bef
PKG_SOURCE_VERSION:=003fd92707531bdf7ad1753ab028db8748ac5ab8
PKG_SOURCE_DATE:=2023-06-05

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=LICENSE.md

PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf
PKG_BUILD_FLAGS:=no-mips16
PKG_BUILD_DEPENDS:=gettext-full/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/tvheadend
  SECTION:=multimedia
  CATEGORY:=Multimedia
  TITLE:=TV streaming server
  MENU:=1
  USERID:=tvheadend:dvb
  URL:=https://tvheadend.org
  MAINTAINER:=Marius Dinu <m95d+git@psihoexpert.ro>
  DEPENDS:= \
	+librt \
	+libffi \
	+libopenssl \
	$(ICONV_DEPENDS) \
	+zlib \
	+TVHEADEND_AVAHI_SUPPORT:libavahi-client \
	+TVHEADEND_REGEX_PCRE2:libpcre2 \
	+BUILD_PATENTED&&TVHEADEND_CSA:libdvbcsa

## Transcoding | Add these to DEPENDS.
##	+TVHEADEND_LIBFFMPEG:libffmpeg-full \
##	+TVHEADEND_LIBVPX:libvpx \
##	+TVHEADEND_LIBTHEORA:libtheora \
##	+TVHEADEND_LIBVORBIS:libvorbis \
##	+TVHEADEND_LIBOPUS:libopusenc \
##	+TVHEADEND_LIBFDKAAC:fdk-aac \
##	+BUILD_PATENTED&&TVHEADEND_LIBX264:libx264 \

endef

define Package/tvheadend/description
  Tvheadend is a TV streaming server and recorder for Linux, FreeBSD and Android
  supporting DVB-S, DVB-S2, DVB-C, DVB-T, ATSC, IPTV, SAT>IP and HDHomeRun as input sources.
  Tvheadend offers the HTTP (VLC, MPlayer), HTSP (Kodi, Movian) and SAT>IP streaming.
endef

define Package/tvheadend/config
  source "$(SOURCE)/Config.in"
endef

## Generic OpenWrt options
ifneq ($(CONFIG_PKG_ASLR_PIE_NONE),)
	CONFIGURE_ARGS += --disable-pie
endif

## Generic tvheadend options
ifneq ($(CONFIG_TVHEADEND_OPTIMIZE_SPEED),)
	TARGET_CFLAGS := $(filter-out -O%,$(TARGET_CFLAGS)) -O3 -flto
	TARGET_CXXFLAGS := $(filter-out -O%,$(TARGET_CXXFLAGS)) -O3 -flto
	TARGET_LDFLAGS += -flto
endif

ifeq ($(CONFIG_TVHEADEND_TRACE),)
	CONFIGURE_ARGS += --disable-trace
endif

CONFIGURE_ARGS += --disable-pcre
ifneq ($(CONFIG_TVHEADEND_REGEX_PCRE2),)
	CONFIGURE_ARGS += --enable-pcre2
else
ifneq ($(CONFIG_TVHEADEND_REGEX_POSIX),)
	CONFIGURE_ARGS += --disable-pcre2
endif
endif

ifeq ($(CONFIG_TVHEADEND_AVAHI_SUPPORT),)
	CONFIGURE_ARGS += --disable-avahi
else
	CONFIGURE_ARGS += --enable-avahi
endif

ifeq ($(CONFIG_TVHEADEND_IMAGECACHE),)
	CONFIGURE_ARGS += --disable-imagecache
else
	CONFIGURE_ARGS += --enable-imagecache
endif

## TV sources
ifeq ($(CONFIG_TVHEADEND_LINUXDVB_SUPPORT),)
	CONFIGURE_ARGS += --disable-linuxdvb
endif

ifeq ($(CONFIG_TVHEADEND_DVBSCAN_SUPPORT),)
	CONFIGURE_ARGS += --disable-dvbscan
endif

ifeq ($(CONFIG_TVHEADEND_IPTV),)
	CONFIGURE_ARGS += --disable-iptv
endif

ifeq ($(CONFIG_TVHEADEND_SATIP_SERVER),)
	CONFIGURE_ARGS += --disable-satip_server
endif

ifeq ($(CONFIG_TVHEADEND_SATIP_CLIENT),)
	CONFIGURE_ARGS += --disable-satip_client
endif

ifeq ($(CONFIG_TVHEADEND_HDHOMERUN_CLIENT),)
	CONFIGURE_ARGS += --disable-hdhomerun_static
else
	CONFIGURE_ARGS += --enable-hdhomerun_client
endif

## Descrambling
ifeq ($(CONFIG_BUILD_PATENTED),)
	CONFIGURE_ARGS += --disable-tvhcsa --disable-dvbcsa --disable-constcw --disable-cwc --disable-capmt --disable-cccam
else
ifeq ($(CONFIG_TVHEADEND_CSA),)
	CONFIGURE_ARGS += --disable-tvhcsa --disable-dvbcsa --disable-constcw --disable-cwc --disable-capmt --disable-cccam
else
	CONFIGURE_ARGS += --enable-tvhcsa --enable-dvbcsa
ifeq ($(CONFIG_TVHEADEND_CONSTCW),)
	CONFIGURE_ARGS += --disable-constcw
endif
ifeq ($(CONFIG_TVHEADEND_NEWCAMD),)
	CONFIGURE_ARGS += --disable-cwc
endif
ifeq ($(CONFIG_TVHEADEND_CAPMT),)
	CONFIGURE_ARGS += --disable-capmt
endif
ifeq ($(CONFIG_TVHEADEND_CCCAM),)
	CONFIGURE_ARGS += --disable-cccam
endif
endif
endif

## Transcoding | Uncomment these.
##ifeq ($(CONFIG_BUILD_PATENTED),)
##	CONFIGURE_ARGS += --disable-libav --disable-libx264 --disable-libx265 --disable-libx265_static
##else
##ifeq ($(CONFIG_TVHEADEND_LIBFFMPEG),)
##	CONFIGURE_ARGS += --disable-libav
##else
##	CONFIGURE_ARGS += --enable-libav
##endif
##ifeq ($(CONFIG_TVHEADEND_LIBX264),)
##	CONFIGURE_ARGS += --disable-libx264
##endif
##ifeq ($(CONFIG_TVHEADEND_LIBX265),)
##	CONFIGURE_ARGS += --disable-libx265 --disable-libx265_static
##endif
##ifneq ($(CONFIG_TVHEADEND_LIBFDKAAC),)
##	CONFIGURE_ARGS += --enable-libfdkaac
##endif
##endif
##
##ifeq ($(CONFIG_TVHEADEND_LIBVPX),)
##	CONFIGURE_ARGS += --disable-libvpx
##endif
##
##ifeq ($(CONFIG_TVHEADEND_LIBlibtheora),)
##	CONFIGURE_ARGS += --disable-libtheora
##endif
##
##ifeq ($(CONFIG_TVHEADEND_LIBVORBIS),)
##	CONFIGURE_ARGS += --disable-libvorbis
##endif
##
##ifeq ($(CONFIG_TVHEADEND_LIBOPUS),)
##	CONFIGURE_ARGS += --disable-libopus
##endif

#required to cross-compile hdhomerun on non-Linux build host
MAKE_FLAGS += \
	OS=Linux

#required to always have "build.linux" dir, not "build.darwin" on macos
CONFIGURE_VARS += \
	PLATFORM=linux

#--platfrom=linux is required to cross-compile tvheadend on non-Linux build host
CONFIGURE_ARGS += \
	--platform=linux \
	--arch=$(ARCH) \
	--disable-libsystemd_daemon \
	--disable-dbus_1 \
	--disable-libav \
	--disable-ffmpeg_static \
	--disable-libx264 \
	--disable-libx264_static \
	--disable-libx265 \
	--disable-libx265_static \
	--disable-libvpx \
	--disable-libvpx_static \
	--disable-libtheora \
	--disable-libtheora_static \
	--disable-libvorbis \
	--disable-libvorbis_static \
	--disable-libopus \
	--disable-libopus_static \
	--disable-libfdkaac \
	--disable-libfdkaac_static \
	--disable-pcloud_cache \
	--enable-bundle \
	--disable-uriparser \
	--disable-execinfo \
	--nowerror=unused-variable

## Transcoding | Remove these from CONFIGURE_ARGS.
##	--disable-libav \
##	--disable-libx265 \
##	--disable-libx265_static \
##	--disable-libx264_static \
##	--disable-libvpx_static \
##	--disable-libtheora_static \
##	--disable-libvorbis_static \
##	--disable-libopus_static \
##	--disable-libfdkaac_static \
##	--disable-pcloud_cache \

define Build/Prepare
	$(call Build/Prepare/Default)
	echo 'Tvheadend $(shell echo $(PKG_SOURCE_VERSION) | sed "s/^v//")~openwrt$(PKG_RELEASE)' \
		> $(PKG_BUILD_DIR)/debian/changelog
endef

define Package/tvheadend/conffiles
/etc/config/tvheadend
/etc/tvheadend
endef

define Package/tvheadend/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/tvheadend.init $(1)/etc/init.d/tvheadend
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/tvheadend.config $(1)/etc/config/tvheadend
	$(INSTALL_DIR) $(1)/etc/hotplug.d/usb
	$(INSTALL_BIN) ./files/dvb.hotplug $(1)/etc/hotplug.d/usb/50-dvb
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/build.linux/tvheadend $(1)/usr/bin/
endef

$(eval $(call BuildPackage,tvheadend))
