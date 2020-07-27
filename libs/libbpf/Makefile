include $(TOPDIR)/rules.mk

PKG_NAME:=libbpf
PKG_VERSION:=0.0.9
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/libbpf/libbpf/archive/
PKG_SOURCE_URL_FILE:=v$(PKG_VERSION).tar.gz
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_URL_FILE)
PKG_HASH:=c216c13b48f5fbd870a9b10a9cb747e0e6063f547e327c4d5a0688713e26a1a4

PKG_MAINTAINER:=Thomas Hebb <tommyhebb@gmail.com>
PKG_LICENSE:=LGPL-2.1-only OR BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE.LPGL-2.1 LICENSE.BSD-2-Clause

MAKE_PATH:=src

include $(INCLUDE_DIR)/package.mk

define Package/libbpf
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Standalone build of libbpf from the Linux kernel
  URL:=https://github.com/libbpf/libbpf
  ABI_VERSION:=0
  DEPENDS:=+libelf +zlib
endef

define Package/libbpf/description
  libbpf is a library, developed in the Linux kernel source tree, that contains
  a large amount of common code needed to load eBPF programs into the kernel
  and communicate with those programs.
endef

# "install" uses the host uname to determine where to place libraries (lib or
# lib64), so we don't use it. We still need to use the upstream set of headers,
# though, so we do use "install_headers".
define Build/Install
	$(call Build/Install/Default,install_headers)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/src/libbpf.{a,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_BUILD_DIR)/src/libbpf.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libbpf/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/src/libbpf.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libbpf))
