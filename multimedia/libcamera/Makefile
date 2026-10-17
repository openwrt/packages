#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libcamera
PKG_VERSION:=0.7.2
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://git.libcamera.org/libcamera/libcamera.git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH:=818205008b9e070ceb35d2bdc58d9d07c3313805d8fc99b8257331170f711d73

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=LGPL-2.1-or-later GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSES/LGPL-2.1-or-later.txt LICENSES/GPL-2.0-or-later.txt
PKG_CPE_ID:=cpe:/a:libcamera:libcamera

PKG_BUILD_DEPENDS:=python3/host python-jinja2/host python-ply/host python-yaml/host
PKG_BUILD_FLAGS:=no-mips16

MESON_USE_STAGING_PYTHON:=1

include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python3-host.mk
include $(INCLUDE_DIR)/meson.mk

MESON_VARS += PYTHONPATH="$(HOST_PYTHON3PATH)"

# libcamera reads the ELF section headers of IPA modules, sstrip removes them
ifeq ($(CONFIG_NO_STRIP),)
STRIP:=$(TARGET_CROSS)strip --strip-unneeded
endif

define Package/libcamera/Default
  SECTION:=multimedia
  CATEGORY:=Multimedia
  URL:=https://libcamera.org/
endef

define Package/libcamera
  $(call Package/libcamera/Default)
  TITLE:=Camera stack library
  DEPENDS:=+libstdcpp +libatomic +libudev-zero +libyaml
endef

define Package/libcamera/description
  libcamera provides a userspace camera stack with pipeline handlers for
  ISPs and image sources, and image processing algorithms that run in
  loadable IPA modules.
endef

define Package/libcamera-gst
  $(call Package/libcamera/Default)
  TITLE:=libcamera GStreamer plugin (libcamerasrc)
  DEPENDS:=+libcamera +glib2 +libgstreamer1 +libgst1allocators +libgst1video
endef

define Package/libcamera-gst/description
  The libcamerasrc GStreamer element, which captures from cameras
  through libcamera.
endef

define Package/libcamera-v4l2
  $(call Package/libcamera/Default)
  TITLE:=libcamera V4L2 compatibility layer
  DEPENDS:=+libcamera
endef

define Package/libcamera-v4l2/description
  A preloadable library that lets V4L2 applications capture from
  cameras through libcamera, and the libcamerify wrapper that loads it.
endef

define Package/libcamera-cam
  $(call Package/libcamera/Default)
  TITLE:=libcamera command line capture tool
  DEPENDS:=+libcamera +libevent2 +libevent2-pthreads
endef

define Package/libcamera-cam/description
  The cam utility lists cameras and captures frames through libcamera.
endef

# $(1) package suffix, $(2) title, $(3) module name, $(4) proxy name,
# $(5) tuning data directory
define LibcameraIPA
  define Package/libcamera-ipa-$(1)
    $$(call Package/libcamera/Default)
    TITLE:=libcamera IPA module for $(2)
    DEPENDS:=+libcamera
  endef

  define Package/libcamera-ipa-$(1)/description
    The image processing algorithms and tuning data that libcamera uses
    for $(2).
  endef

  define Package/libcamera-ipa-$(1)/install
	$$(INSTALL_DIR) $$(1)/usr/lib/libcamera/ipa
	$$(INSTALL_BIN) $$(PKG_INSTALL_DIR)/usr/lib/libcamera/ipa/ipa_$(3).so \
		$$(1)/usr/lib/libcamera/ipa/
	$$(INSTALL_DIR) $$(1)/usr/libexec/libcamera
	$$(INSTALL_BIN) $$(PKG_INSTALL_DIR)/usr/libexec/libcamera/$(4)_ipa_proxy \
		$$(1)/usr/libexec/libcamera/
	$$(INSTALL_DIR) $$(1)/usr/share/libcamera/ipa/$(5)
	$$(CP) $$(PKG_INSTALL_DIR)/usr/share/libcamera/ipa/$(5)/* \
		$$(1)/usr/share/libcamera/ipa/$(5)/
  endef

  $$(eval $$(call BuildPackage,libcamera-ipa-$(1)))
endef

MESON_ARGS += \
	-Dandroid=disabled \
	-Dcam=enabled \
	-Dcam-output-kms=disabled \
	-Dcam-output-sdl2=disabled \
	-Dcam-jpeg=disabled \
	-Ddocumentation=disabled \
	-Dgstreamer=enabled \
	-Dipa-signing=disabled \
	-Dipas=ipu3,mali-c55,rkisp1,rkisp2,rpi/vc4,softisp \
	-Dlc-compliance=disabled \
	-Dlibdw=disabled \
	-Dlibunwind=disabled \
	-Dapps-output-dng=disabled \
	-Dpipelines=imx8-isi,ipu3,mali-c55,rkisp1,rkisp2,rpi/vc4,simple,uvcvideo \
	-Dpycamera=disabled \
	-Dqcam=disabled \
	-Drpi-awb-nn=disabled \
	-Dsoftisp-gpu=disabled \
	-Dtest=false \
	-Dtracing=disabled \
	-Dudev=enabled \
	-Dv4l2=enabled \
	-Dwerror=false

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libcamera $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libcamera*.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libcamera*.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libcamera/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libcamera*.so.* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/share/libcamera
	$(CP) $(PKG_INSTALL_DIR)/usr/share/libcamera/pipeline $(1)/usr/share/libcamera/
endef

define Package/libcamera-gst/install
	$(INSTALL_DIR) $(1)/usr/lib/gstreamer-1.0
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/gstreamer-1.0/libgstlibcamera.so \
		$(1)/usr/lib/gstreamer-1.0/
endef

define Package/libcamera-v4l2/install
	$(INSTALL_DIR) $(1)/usr/libexec/libcamera
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/libexec/libcamera/v4l2-compat.so \
		$(1)/usr/libexec/libcamera/
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/libcamerify $(1)/usr/bin/
endef

define Package/libcamera-cam/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/cam $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libcamera))
$(eval $(call BuildPackage,libcamera-gst))
$(eval $(call BuildPackage,libcamera-v4l2))
$(eval $(call BuildPackage,libcamera-cam))

$(eval $(call LibcameraIPA,ipu3,the Intel IPU3 ISP,ipu3,ipu3,ipu3))
$(eval $(call LibcameraIPA,mali-c55,the Arm Mali-C55 ISP,mali_c55,mali-c55,mali-c55))
$(eval $(call LibcameraIPA,rkisp1,the Rockchip ISP1,rkisp1,rkisp1,rkisp1))
$(eval $(call LibcameraIPA,rkisp2,the Rockchip ISP2,rkisp2,rkisp2,rkisp2))
$(eval $(call LibcameraIPA,rpi-vc4,the Raspberry Pi VC4 ISP,rpi_vc4,raspberrypi,rpi/vc4))
$(eval $(call LibcameraIPA,softisp,the software ISP,softisp,softisp,softisp))
