# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=mesa
PKG_VERSION:=18.3.4
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://mesa.freedesktop.org/archive/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_HASH:=32314da4365d37f80d84f599bd9625b00161c273c39600ba63b45002d500bb07

PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
PKG_BUILD_DEPENDS:=xorgproto
#ifdef CONFIG_PACKAGE_mesa-llvm
#PKG_BUILD_DEPENDS+=llvm/host python-mako/host
#endif
PKG_INSTALL:=1

PKG_CONFIG_DEPENDS:= \
	CONFIG_PACKAGE_mesa_llvm \
	CONFIG_PACKAGE_mesa_amdgpu \
	CONFIG_PACKAGE_mesa_freedreno \
	CONFIG_PACKAGE_mesa_intel_i915 \
	CONFIG_PACKAGE_mesa_intel_i965 \
	CONFIG_PACKAGE_mesa_intel_vulkan \
	CONFIG_PACKAGE_mesa_radeon \
	CONFIG_PACKAGE_mesa_radeon_r200 \
	CONFIG_PACKAGE_mesa_radeon_r300 \
	CONFIG_PACKAGE_mesa_radeon_r600 \
	CONFIG_PACKAGE_mesa_redeonsi \
	CONFIG_PACKAGE_mesa_nouveau \
	CONFIG_PACKAGE_mesa_swrast \
	CONFIG_PACKAGE_mesa_vc4 \
	CONFIG_PACKAGE_mesa_virtio \
	CONFIG_PACKAGE_mesa_vmware

include $(INCLUDE_DIR)/package.mk

define Package/mesa/Default
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=mesa
  TITLE:=Mesa DRI OpenGL library
  URL:=https://www.mesa3d.org
endef

define Package/mesa
  $(call Package/mesa/Default)
  MENU:=1
  DEPENDS:=+libdrm +libxcb +libx11 +libxext +libxdamage +libxshmfence \
	+libvdpau +libxxf86vm +libxrandr +libstdcpp +zlib +libexpat \
	+libatomic +PACKAGE_mesa-llvm:libva \
	+PACKAGE_mesa-llvm:libllvm +PACKAGE_mesa-llvm:libelf1
endef

define Package/mesa/description
    Mesa is an open-source implementation of the OpenGL specification.
endef

define Package/mesa-llvm
  $(call Package/mesa/Default)
  DEPENDS+=@TARGET_x86
  TITLE:=MESA LLVM support
endef

define Package/mesa-amdgpu
  $(call Package/mesa/Default)
  DEPENDS+=@TARGET_x86 +mesa-llvm +kmod-drm-amdgpu
  TITLE:=MESA AMDGPU support
endef

define Package/mesa-freedreno
  $(call Package/mesa/Default)
  DEPENDS+=@(arm||armeb||aarch64)
  TITLE:=MESA freedreno support
endef

define Package/mesa-intel-i915
  $(call Package/mesa/Default)
  DEPENDS+=@TARGET_x86
  TITLE:=MESA Intel i915 support
endef

define Package/mesa-intel-i965
  $(call Package/mesa/Default)
  DEPENDS+=@TARGET_x86
  TITLE:=MESA Intel i965 support
endef

define Package/mesa-intel-vulkan
  $(call Package/mesa/Default)
  DEPENDS+=@TARGET_x86
  TITLE:=MESA Intel vulkan support
endef

define Package/mesa-radeon
  $(call Package/mesa/Default)
  DEPENDS+=@TARGET_x86 +kmod-drm-radeon
  TITLE:=MESA Radeon support
endef

define Package/mesa-radeon-r200
  $(call Package/mesa/Default)
  DEPENDS+=@TARGET_x86 +kmod-drm-radeon
  TITLE:=MESA Radeon r200 support
endef

define Package/mesa-radeon-r300
  $(call Package/mesa/Default)
  DEPENDS+=@TARGET_x86 +kmod-drm-radeon +mesa-llvm
  TITLE:=MESA Radeon r300 support
endef

define Package/mesa-radeon-r600
  $(call Package/mesa/Default)
  DEPENDS+=@TARGET_x86 +kmod-drm-radeon +mesa-llvm
  TITLE:=MESA Radeon r600 support
endef

define Package/mesa-radeonsi
  $(call Package/mesa/Default)
  DEPENDS+=@TARGET_x86 +kmod-drm-radeon +mesa-llvm
  TITLE:=MESA Radeon radeonsi support
endef

define Package/mesa-nouveau
  $(call Package/mesa/Default)
  DEPENDS+=@TARGET_x86
  TITLE:=MESA nouveau support
endef

define Package/mesa-swrast
  $(call Package/mesa/Default)
  DEPENDS+=
  TITLE:=MESA swrast support
endef

define Package/mesa-vc4
  $(call Package/mesa/Default)
  DEPENDS+=@(arm||armeb||aarch64)
  TITLE:=MESA vc4 support
endef

define Package/mesa-virtio
  $(call Package/mesa/Default)
  DEPENDS+=@TARGET_x86
  TITLE:=MESA virtio support
endef

define Package/mesa-vmware
  $(call Package/mesa/Default)
  DEPENDS+=@TARGET_x86
  TITLE:=MESA vmware support
endef

#  --enable-gallium-osmesa \

#_dri_driverdir=/usr/lib/xorg/modules/dri
ifeq ($(ARCH),i386)
    _drv_opts=--enable-glx-rts --disable-asm
    _dri_drivers=i915,i965,radeon,r200,nouveau,swrast
    _gallium_drivers=i915,nouveau,svga,swrast,virgl
    _vulkan_drivers=intel
else ifeq ($(ARCH),x86_64)
    _dri_drivers=i915,i965,radeon,r200,nouveau,swrast
    _gallium_drivers=i915,nouveau,svga,swrast,virgl
    _vulkan_drivers=intel
    _drv_opts=
endif
#
ifdef CONFIG_PACKAGE_mesa-llvm
    export LLVM_CONFIG=$(STAGING_DIR_HOSTPKG)/usr/lib/llvm/bin/llvm-config
    _llvm_opts=--enable-llvm --with-llvm-prefix=$(STAGING_DIR)/usr/lib \
    --enable-llvm-shared-libs
    _gallium_drivers+=,r300,r600,radeonsi
    _vulkan_drivers+=,radeon
    _drv_opts+=--enable-va
endif

ifdef CONFIG_PACKAGE_mesa-vmware
    _drv_opts+=--enable-xa
endif


ifeq ($(ARCH),arm)
    _gallium_drivers=swrast,freedreno,vc4,virgl
    _llvm_opts=--disable-llvm
else ifeq ($(ARCH),aarch64)
    _gallium_drivers=swrast,freedreno,vc4,virgl
    _llvm_opts=--disable-llvm
endif

#  --with-llvm-prefix=$(STAGING_DIR_HOSTPKG)/usr/lib/llvm \

CONFIGURE_ARGS += \
  --prefix=/usr \
  --libdir=/usr/lib \
  --sysconfdir=/etc \
  --libdir=/usr/lib \
  --datarootdir=/usr/share \
  --sbindir=/usr/sbin \
  --enable-shared-glapi \
  --enable-gbm \
  --enable-dri \
  --enable-glx \
  --enable-gles1 \
  --enable-gles2 \
  --enable-egl \
  --enable-vdpau \
  --enable-dri3 \
  --disable-xvmc \
  --disable-glx-tls \
  --disable-nine \
  $(_llvm_opts) \
  $(_drv_opts) \
  --with-platforms=x11,drm \
  --with-dri-drivers="$(_dri_drivers)" \
  --with-gallium-drivers="$(_gallium_drivers)" \
  --with-vulkan-drivers="$(_vulkan_drivers)"

#  --enable-texture-float \



define Build/InstallDev
	$(INSTALL_DIR) \
	  $(1)/usr/include \
	  $(1)/usr/lib

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/include/* \
	  $(1)/usr/include/

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/{pkgconfig,*.so*} \
	  $(1)/usr/lib/
endef

define Package/mesa/install
	$(INSTALL_DIR) \
	  $(1)/usr/lib \
	  $(1)/usr/share/drirc.d
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/libg*.so* \
	  $(1)/usr/lib/
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/lib{E,G}*.so* \
	  $(1)/usr/lib/
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/share/drirc.d \
	  $(1)/usr/share/
endef

define Package/mesa-llvm/install
	$(INSTALL_DIR) \
	  $(1)/usr/lib
endef

define Package/mesa-amdgpu/install
	$(INSTALL_DIR) \
	  $(1)/usr/lib \
	  $(1)/usr/share/vulkan/icd.d
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/libvulkan_radeon.so \
	  $(1)/usr/lib/
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/share/vulkan/icd.d/radeon*.json \
	  $(1)/usr/share/vulkan/icd.d/
endef

define Package/mesa-freedreno/install
	$(INSTALL_DIR) \
	  $(1)/usr/lib/dri
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/dri/{msm_dri.so,kgsl_dri.so} \
	  $(1)/usr/lib/dri/
endef

define Package/mesa-intel-i915/install
	$(INSTALL_DIR) \
	  $(1)/usr/lib/dri
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/dri/i915_dri.so \
	  $(1)/usr/lib/dri/
endef

define Package/mesa-intel-i965/install
	$(INSTALL_DIR) \
	  $(1)/usr/lib/dri
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/dri/i965_dri.so \
	  $(1)/usr/lib/dri/
endef

define Package/mesa-intel-vulkan/install
	$(INSTALL_DIR) \
	  $(1)/usr/lib \
	  $(1)/usr/share/vulkan/icd.d
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/libvulkan_intel.so \
	  $(1)/usr/lib/
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/share/vulkan/icd.d/intel*.json \
	  $(1)/usr/share/vulkan/icd.d/
endef

define Package/mesa-radeon/install
	$(INSTALL_DIR) \
	  $(1)/usr/lib/dri
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/dri/radeon_dri.so \
	  $(1)/usr/lib/dri/
endef

define Package/mesa-radeon-r200/install
	$(INSTALL_DIR) \
	  $(1)/usr/lib/dri
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/dri/r200_dri.so \
	  $(1)/usr/lib/dri/
endef

define Package/mesa-radeon-r300/install
	$(INSTALL_DIR) \
	  $(1)/usr/lib/dri \
	  $(1)/usr/lib/vdpau
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/dri/r300_dri.so \
	  $(1)/usr/lib/dri/
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/vdpau/libvdpau_r300*.so* \
	  $(1)/usr/lib/vdpau/
endef

define Package/mesa-radeon-r600/install
	$(INSTALL_DIR) \
	  $(1)/usr/lib/dri \
	  $(1)/usr/lib/vdpau
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/dri/r600*.so \
	  $(1)/usr/lib/dri/
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/vdpau/libvdpau_r600*.so* \
	  $(1)/usr/lib/vdpau/
endef

define Package/mesa-radeonsi/install
	$(INSTALL_DIR) \
	  $(1)/usr/lib/dri \
	  $(1)/usr/lib/vdpau
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/dri/radeonsi*.so \
	  $(1)/usr/lib/dri/
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/vdpau/libvdpau_radeonsi*.so* \
	  $(1)/usr/lib/vdpau/
endef

define Package/mesa-nouveau/install
	$(INSTALL_DIR) \
	  $(1)/usr/lib/dri \
	  $(1)/usr/lib/vdpau
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/dri/nouveau*.so \
	  $(1)/usr/lib/dri/
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/vdpau/libvdpau_nouveau*.so* \
	  $(1)/usr/lib/vdpau/
endef

define Package/mesa-swrast/install
	$(INSTALL_DIR) \
	  $(1)/usr/lib/dri
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/dri/*swrast*.so \
	  $(1)/usr/lib/dri/
endef

define Package/mesa-vc4/install
	$(INSTALL_DIR) \
	  $(1)/usr/lib/dri
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/dri/vc4_dri.so \
	  $(1)/usr/lib/dri/
endef

define Package/mesa-virtio/install
	$(INSTALL_DIR) \
	  $(1)/usr/lib/dri
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/dri/virtio_gpu_dri.so \
	  $(1)/usr/lib/dri/
endef

define Package/mesa-vmware/install
	$(INSTALL_DIR) \
	  $(1)/usr/lib/dri
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/dri/vmwgfx_dri.so \
	   $(1)/usr/lib/dri/
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/libxatracker*.so.* \
	   $(1)/usr/lib/
endef


$(eval $(call BuildPackage,mesa))
$(eval $(call BuildPackage,mesa-llvm))
$(eval $(call BuildPackage,mesa-amdgpu))
$(eval $(call BuildPackage,mesa-freedreno))
$(eval $(call BuildPackage,mesa-intel-i915))
$(eval $(call BuildPackage,mesa-intel-i965))
$(eval $(call BuildPackage,mesa-intel-vulkan))
$(eval $(call BuildPackage,mesa-radeon))
$(eval $(call BuildPackage,mesa-radeon-r200))
$(eval $(call BuildPackage,mesa-radeon-r300))
$(eval $(call BuildPackage,mesa-radeon-r600))
$(eval $(call BuildPackage,mesa-radeonsi))
$(eval $(call BuildPackage,mesa-nouveau))
$(eval $(call BuildPackage,mesa-swrast))
$(eval $(call BuildPackage,mesa-vc4))
$(eval $(call BuildPackage,mesa-virtio))
$(eval $(call BuildPackage,mesa-vmware))
