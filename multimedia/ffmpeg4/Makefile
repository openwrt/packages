#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ffmpeg4
PKG_VERSION:=4.2.2
PKG_RELEASE:=1

PKG_MAINTAINER:=
PKG_LICENSE:=GPL-2.0-or-later LGPL-2.1-or-later LGPL-3.0-only
PKG_LICENSE_FILES:=COPYING.GPLv2 COPYING.GPLv3 COPYING.LGPLv2.1 COPYING.LGPLv3

PKG_SOURCE:=ffmpeg-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://www.ffmpeg.org/releases/
PKG_HASH:=cb754255ab0ee2ea5f66f8850e1bd6ad5cac1cd855d0a2f4990fb8c668b0d29c
PKG_BUILD_DIR:=$(BUILD_DIR)/ffmpeg-$(PKG_VERSION)

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

PKG_CONFIG_DEPENDS:= \
  CONFIG_ffmpeg4_LICENSING \
  CONFIG_ffmpeg4_ENC_FLV \
  CONFIG_ffmpeg4_ENC_MJPEG \
  CONFIG_ffmpeg4_ENC_MPEG4 \
  CONFIG_ffmpeg4_ENC_PNG \
  CONFIG_ffmpeg4_FEAT_DASH \
  CONFIG_ffmpeg4_LIB_FDK-AAC \
  CONFIG_ffmpeg4_LIB_LAME \
  CONFIG_ffmpeg4_LIB_LIBOPUS \
  CONFIG_ffmpeg4_LIB_LIBVORBIS \
  CONFIG_ffmpeg4_LIB_LIBX264 \
  CONFIG_ffmpeg4_OPT_PERFORMANCE \
  CONFIG_ffmpeg4_LIB_MBEDTLS \
  CONFIG_ffmpeg4_LIB_OPENSSL

include $(INCLUDE_DIR)/package.mk

define Package/ffmpeg4
  SECTION:=multimedia
  CATEGORY:=Multimedia
  DEPENDS:=+libpthread +zlib \
    +ffmpeg4_FEAT_DASH:libxml2 \
    +ffmpeg4_LIB_FDK-AAC:fdk-aac \
    +ffmpeg4_LIB_LAME:lame-lib \
    +ffmpeg4_LIB_LIBOPUS:libopus \
    +ffmpeg4_LIB_LIBVORBIS:libvorbis \
    +ffmpeg4_LIB_LIBX264:libx264 \
    +ffmpeg4_LIB_MBEDTLS:libmbedtls \
    +ffmpeg4_LIB_OPENSSL:libopenssl

  TITLE:=FFmpeg $(PKG_VERSION)
  URL:=https://www.ffmpeg.org/
  PROVIDES:=libffmpeg libffmpeg-full libffmpeg-mini libffmpeg-custom libffmpeg-audio-dec ffmpeg
endef

define Package/ffmpeg4-ffprobe
  SECTION:=multimedia
  CATEGORY:=Multimedia
  DEPENDS:=ffmpeg4
  TITLE:=ffprobe for FFmpeg $(PKG_VERSION)
  URL:=https://www.ffmpeg.org/
endef

define Package/ffmpeg4/description
  Complete solution to record, convert and stream audio and video
  This packages uses the "one size fits all" approach and may not
  be optimal on devices with very little storage.

  The idea is to have a package that isn't huge and still capable
  of handling common formats of files and streams, do conversions
  and encode without sacrifcing performance (if applicable).

  Some customizations can be done but are kept to a minimum for
  simple configuration and usage. Due to the approach mentioned
  above and distribution polices this package is not available
  in binary (compiled) form.

  Please respect the above and keep it in mind when creating a
  pull request.
endef

define Package/ffmpeg4-ffprobe/description
  FFprobe is a utility that gathers information from multimedia streams
  and prints it in human- and machine-readable fashion.
endef

define Package/ffmpeg4/config
  source "$(SOURCE)/Config.in"
endef

TARGET_CFLAGS:=$(FPIC) $(filter-out -O%,$(TARGET_CFLAGS))

### When crosscompiling LD needs to set as CC
CONFIGURE_VARS:=$(filter-out LD=%,$(CONFIGURE_VARS)) LD="$(TARGET_CC)"
MAKE_FLAGS:=$(filter-out LD=%,$(MAKE_FLAGS)) LD="$(TARGET_CC)"

### Don't override FFmpeg's ARCH setting via ./configure
### Fixes various linking issues
MAKE_FLAGS:=$(filter-out ARCH=%,$(MAKE_FLAGS))

CONFIGURE_ARGS:=$(filter-out	\
	--target=%		\
	--host=%		\
	--build=%		\
	--program-prefix=%	\
	--program-suffix=%	\
	--exec-prefix=%		\
	--disable-nls		\
	--sbindir=%		\
	--libexecdir=%		\
	--sysconfdir=%		\
	--localstatedir=%	\
	--infodir=%		\
	, $(CONFIGURE_ARGS))

CONFIGURE_ARGS += \
	--disable-static --enable-shared --disable-ffplay \
	--disable-doc --disable-htmlpages \
	--disable-manpages --disable-podpages \
	--disable-txtpages --disable-postproc \
	--disable-everything --enable-swscale \
	--enable-decoder=aac,aac_fixed,aac_latm,ac3,ac3_fixed \
	--enable-decoder=adpcm_g722,adpcm_g726,adpcm_g726le \
	--enable-decoder=alac,als,amrnb,amrwb,ass \
	--enable-decoder=bitpacked,dca \
	--enable-decoder=dsd_lsbf,dsd_lsbf_planar,dsd_msbf \
	--enable-decoder=dsd_msbf_planar,eac3 \
	--enable-decoder=ffv1,flac,flashsv,flashsv2,flv \
	--enable-decoder=g723_1,g729,gsm,gsm_ms,h263,h263i \
	--enable-decoder=h263p,h264,hevc,mjpeg,mjpegb \
	--enable-decoder=mlp,mp1,mp1float,mp2,mp2float,mp3 \
	--enable-decoder=mp3adu,mp3adufloat,mp3float \
	--enable-decoder=mp3on4,mp3on4float,mpeg1video \
	--enable-decoder=mpeg2video,mpeg4,mpegvideo \
	--enable-decoder=msmpeg4v1,msmpeg4v2,msmpeg4v3 \
	--enable-decoder=opus,pcm_alaw,pcm_bluray \
	--enable-decoder=pcm_dvd,pcm_f16le,pcm_f24le \
	--enable-decoder=pcm_f32be,pcm_f32le,pcm_f64be \
	--enable-decoder=pcm_f64le,pcm_mulaw,pcm_s16be \
	--enable-decoder=pcm_s16be_planar,pcm_s16le \
	--enable-decoder=pcm_s16le_planar,pcm_s24be \
	--enable-decoder=pcm_s24daud,pcm_s24le \
	--enable-decoder=pcm_s24le_planar,pcm_s32be \
	--enable-decoder=pcm_s32le,pcm_s32le_planar \
	--enable-decoder=pcm_s64be,pcm_s64le,pcm_s8 \
	--enable-decoder=pcm_s8_planar,pcm_u16be,pcm_u16le \
	--enable-decoder=pcm_u24be,pcm_u24le,pcm_u32be \
	--enable-decoder=pcm_u32le,pcm_u8 \
	--enable-decoder=rawvideo,truehd \
	--enable-decoder=vorbis,vp7,vp8,vp9,webp \
	--enable-decoder=wrapped_avframe,zlib \
	--enable-encoder=alac,flac,pcm_alaw \
	--enable-encoder=pcm_f32be,pcm_f32le,pcm_f64be \
	--enable-encoder=pcm_f64le,pcm_mulaw,pcm_s16be \
	--enable-encoder=pcm_s16be_planar,pcm_s16le \
	--enable-encoder=pcm_s16le_planar,pcm_s24be \
	--enable-encoder=pcm_s24daud,pcm_s24le \
	--enable-encoder=pcm_s24le_planar,pcm_s32be \
	--enable-encoder=pcm_s32le,pcm_s32le_planar \
	--enable-encoder=pcm_s64be,pcm_s64le,pcm_s8 \
	--enable-encoder=pcm_s8_planar,pcm_u16be \
	--enable-encoder=pcm_u16le,pcm_u24be,pcm_u24le \
	--enable-encoder=pcm_u32be,pcm_u32le,pcm_u8 \
	--enable-encoder=wrapped_avframe,zlib \
	--enable-demuxer=aac,ac3,ass,avi,concat,data \
	--enable-demuxer=dts,dtshd,dvbsub,dvbtxt,eac3,ffmetadata,flac \
	--enable-demuxer=flv,g723_1,g726,g726le,g729,h263,h264,hevc \
	--enable-demuxer=hls,live_flv,loas,m4v,matroska,mjpeg,mlp,mov \
	--enable-demuxer=mp3,mpegps,mpegts,mpegtsraw,mpegvideo,mpjpeg \
	--enable-demuxer=mv,nc,nsv,ogg,pcm_alaw,pcm_f32be,pcm_f32le \
	--enable-demuxer=pcm_f64be,pcm_f64le,pcm_mulaw,pcm_s16be \
	--enable-demuxer=pcm_s16le,pcm_s24be,pcm_s24le,pcm_s32be \
	--enable-demuxer=pcm_s32le,pcm_s8,pcm_u16be,pcm_u16le \
	--enable-demuxer=pcm_u24be,pcm_u24le,pcm_u32be,pcm_u32le \
	--enable-demuxer=pcm_u8,rawvideo,rtp,rtsp,s337m,sap,sdp \
	--enable-demuxer=srt,sup,swf,truehd,vobsub,wav \
	--enable-demuxer=webm_dash_manifest,webvtt,yuv4mpegpipe \
	--enable-muxer=ac3,adts,amr \
	--enable-muxer=ass,avi,bit,dash,data,dts,eac3 \
	--enable-muxer=f4v,ffmetadata,fifo,flac,flv \
	--enable-muxer=g722,g723_1,g726,g726le,gsm \
	--enable-muxer=h263,h264,hds,hevc,hls,ipod \
	--enable-muxer=latm,m4v,matroska,matroska_audio \
	--enable-muxer=mjpeg,mkvtimestamp_v2,mlp,mov \
	--enable-muxer=mp2,mp3,mp4,mpeg1system \
	--enable-muxer=mpeg1vcd,mpeg1video,mpeg2dvd \
	--enable-muxer=mpeg2svcd,mpeg2video,mpeg2vob \
	--enable-muxer=mpegts,null,ogg,opus,pcm_alaw \
	--enable-muxer=pcm_f32be,pcm_f32le,pcm_f64be \
	--enable-muxer=pcm_f64le,pcm_mulaw,pcm_s16be \
	--enable-muxer=pcm_s16le,pcm_s24be,pcm_s24le \
	--enable-muxer=pcm_s32be,pcm_s32le,pcm_s8 \
	--enable-muxer=pcm_u16be,pcm_u16le,pcm_u24be \
	--enable-muxer=pcm_u24le,pcm_u32be,pcm_u32le \
	--enable-muxer=pcm_u8,rawvideo,rtp,rtp_mpegts \
	--enable-muxer=rtsp,sap,segment,srt \
	--enable-muxer=stream_segment,truehd \
	--enable-muxer=wav,webm,webm_chunk \
	--enable-muxer=webm_dash_manifest,webvtt \
	--enable-muxer=yuv4mpegpipe \
	--enable-parser=aac,aac_latm,ac3,dca \
	--enable-parser=flac,g729,gsm,h263 \
	--enable-parser=h264,hevc,mjpeg,mpeg4video \
	--enable-parser=mpegaudio,mpegvideo,opus \
	--enable-parser=vorbis,vp8,vp9 \
	--enable-protocol=async,cache,concat,data \
	--enable-protocol=file,hls,http,https,icecast \
	--enable-protocol=pipe,rtmp,rtmps,srtp,tcp,udp,unix \
	--enable-bsf=aac_adtstoasc,chomp,dca_core \
	--enable-bsf=dump_extradata,eac3_core,extract_extradata \
	--enable-bsf=h264_metadata,h264_mp4toannexb,hevc_mp4toannexb \
	--enable-bsf=hevc_metadata,hevc_mp4toannexb \
	--enable-bsf=mjpeg2jpeg,mjpega_dump_header,mlp_parser \
	--enable-bsf=mp3_header_decompress,mpeg2_metadata \
	--enable-bsf=mpeg4_unpack_bframes,noise,null \
	--enable-bsf=remove_extradata \
	--enable-bsf=vp9_raw_reorder,vp9_superframe \
	--enable-bsf=vp9_superframe_split \
	--enable-filter=acopy,adelay,aformat,ainterleave \
	--enable-filter=ametadata,apad,aresample \
	--enable-filter=ashowinfo,astreamselect,atrim \
	--enable-filter=bwdif,channelmap,copy,crop,format \
	--enable-filter=fps,framerate \
	--enable-filter=interleave,join,metadata \
	--enable-filter=movie,null,nullsink \
	--enable-filter=nullsrc,pad,qp \
	--enable-filter=realtime,scale,select \
	--enable-filter=showinfo,streamselect,trim \
	--enable-filter=volume,w3fdif,yadif  \
	--disable-bzlib --disable-lzma \
	--enable-cross-compile --disable-debug \
	--cross-prefix="$(TARGET_CROSS)" \
	--arch="$(ARCH)" \
	--target-os="linux" \
	--ld="$(TARGET_CC)" \
	--pkg-config="pkg-config" \
	$(if $(CONFIG_ffmpeg4_ENC_FLV),--enable-encoder=flv,) \
	$(if $(CONFIG_ffmpeg4_ENC_MJPEG),--enable-encoder=mjpeg,) \
	$(if $(CONFIG_ffmpeg4_ENC_MPEG4),--enable-encoder=mpeg4,) \
	$(if $(CONFIG_ffmpeg4_ENC_PNG),--enable-encoder=png,) \
	$(if $(CONFIG_ffmpeg4_FEAT_DASH),--enable-demuxer=dash --enable-libxml2,) \
	$(if $(CONFIG_ffmpeg4_LIB_FDK-AAC),--enable-decoder=libfdk_aac --enable-encoder=libfdk_aac --enable-libfdk-aac --enable-nonfree, --disable-libfdk-aac) \
	$(if $(CONFIG_ffmpeg4_LIB_LAME),--enable-encoder=libmp3lame --enable-libmp3lame,--disable-libmp3lame) \
	$(if $(CONFIG_ffmpeg4_LIB_MBEDTLS),--enable-mbedtls --enable-version3,--disable-mbedtls) \
	$(if $(CONFIG_ffmpeg4_LIB_OPENSSL),--enable-openssl --enable-nonfree,--disable-openssl) \
	$(if $(CONFIG_ffmpeg4_LIB_LIBOPUS),--enable-decoder=libopus --enable-encoder=libopus --enable-libopus,--disable-libopus) \
	$(if $(CONFIG_ffmpeg4_LIB_LIBVORBIS),--enable-decoder=libvorbis --enable-encoder=libvorbis --enable-libvorbis,--disable-libvorbis) \
	$(if $(CONFIG_ffmpeg4_LIB_LIBX264),--enable-encoder=libx264 --enable-encoder=libx264rgb --enable-libx264 --enable-gpl,--disable-libx264) \
	$(if $(CONFIG_ffmpeg4_OPT_PERFORMANCE),,--enable-small)

### Platform specific fixes

### ARM (XScale)
### Note: No need to include instructions that aren't supported
ifeq ($(CONFIG_SOFT_FLOAT),y)
  ifeq ($(call qstrip,$(CONFIG_CPU_TYPE)),xscale)
    CONFIGURE_ARGS += --disable-armv6 --disable-armv6t2 --disable-vfp \
    --disable-neon --disable-fast-unaligned
  endif
endif

### MIPS 32-bit and 64-bit
### Note: FFmpeg does support MIPS32R2 optimization however it uses opcodes
### that aren't supported hence --cpu=generic otherwise the build will fail.
### Enabling assembly generates "invalid operands" using GCC 8.3.0 and
### binutils 2.32, additionally MIPS16 breaks LTO
ifeq ($(CONFIG_SOFT_FLOAT),y)
  ifneq (,$(filter $(call qstrip,$(CONFIG_CPU_TYPE)), mips32 24kc 34kc 74kc octeonplus))
    CONFIGURE_ARGS += --disable-mipsfpu --disable-mipsdsp \
	--disable-mipsdspr2 --disable-fast-unaligned --disable-msa \
	--disable-mmi --disable-asm --cpu=generic
  endif
endif

ifneq ($(CONFIG_USE_MIPS16),y)
  CONFIGURE_ARGS += --enable-lto
endif

### PowerPC apm821xx
### Note: No need to include instructions that aren't supported
ifeq ($(call qstrip,$(CONFIG_CPU_TYPE)),464fp)
  CONFIGURE_ARGS += --disable-altivec --disable-vsx
endif

### x86 / x86-64
### Note: FFmpeg blindly assumes that NASM is available
### NASM produces broken files for i386 subtargets except for pentium4
### For whatever reason compilation using GCC 8.3.0 and binutils 2.32 fails in
### libswscale/x86/yuv2rgb_template.c with the following message:
### "error: 'asm' operand has impossible constraints" on x86 (32-bit)
### with assembly enabled. For now just disable assembly to bypass this issue.
### Some assembly files for x86 are licensed under
### GNU General Public License v2.0 or later
### https://github.com/FFmpeg/FFmpeg/blob/master/LICENSE.md

ifeq ($(CONFIG_TARGET_x86),y)
  CONFIGURE_ARGS += --enable-gpl --disable-asm
  ifneq ($(CONFIG_NASM),y)
    CONFIGURE_ARGS += --disable-x86asm
  endif
endif

ifeq ($(CONFIG_x86_64),y)
  CONFIGURE_ARGS += --enable-gpl
  ifneq ($(CONFIG_NASM),y)
    CONFIGURE_ARGS += --disable-x86asm
  endif
endif

### Main build already has ffprobe
define Build/ffmpeg4-ffprobe/Prepare
endef

define Build/ffmpeg4-ffprobe/Configure
endef

define Build/ffmpeg4-ffprobe/Compile
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/include/lib{avcodec,avdevice,avfilter,avformat,avutil,swresample,swscale} $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib{avcodec,avdevice,avfilter,avformat,avutil,swresample,swscale}.so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/lib{avcodec,avdevice,avfilter,avformat,avutil,swresample,swscale}.pc $(1)/usr/lib/pkgconfig/
endef

define Package/ffmpeg4/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib{avcodec,avdevice,avfilter,avformat,avutil,swresample,swscale}.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/ffmpeg $(1)/usr/bin/
endef

define Package/ffmpeg4-ffprobe/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/ffprobe $(1)/usr/bin/
endef

$(eval $(call BuildPackage,ffmpeg4-ffprobe))
$(eval $(call BuildPackage,ffmpeg4))
