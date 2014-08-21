#
# Copyright (C) 2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=xz
PKG_VERSION:=5.0.4
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://tukaani.org/xz
PKG_MD5SUM:=741cd3a5f64b23b7bac56ec5b2258715

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

XZ_UTILS := \
	lzcat lzcmp lzdiff lzegrep lzfgrep lzgrep lzless lzma lzmadec lzmainfo \
	lzmore unlzma unxz xz xzcat xzcmp xzdec xzdiff xzegrep xzfgrep xzgrep \
	xzless xzmore

DEPENDS_lzmadec = +libpthread +liblzma
DEPENDS_lzmainfo = +libpthread +liblzma
DEPENDS_xz = +libpthread +liblzma
DEPENDS_xzdec = +libpthread +liblzma

XZ_DEPENDS_lzcat = xz
XZ_DEPENDS_lzcmp = xzdiff
XZ_DEPENDS_lzcat = xz
XZ_DEPENDS_lzcmp = xzdiff
XZ_DEPENDS_lzdiff = xzdiff
XZ_DEPENDS_lzegrep = xzgrep
XZ_DEPENDS_lzfgrep = xzgrep
XZ_DEPENDS_lzgrep = xzgrep
XZ_DEPENDS_lzless = xzless
XZ_DEPENDS_lzma = xz
XZ_DEPENDS_lzmore = xzmore
XZ_DEPENDS_unlzma = xz
XZ_DEPENDS_unxz = xz
XZ_DEPENDS_xzcat = xz
XZ_DEPENDS_xzcmp = xzdiff
XZ_DEPENDS_xzegrep = xzgrep
XZ_DEPENDS_xzfgrep = xzgrep

define Package/xz/Default
  SECTION:=utils
  CATEGORY:=Utilities
endef

define Package/xz
  $(call Package/xz/Default)
  TITLE:=XZ Utils
  MENU:=1
endef

define Package/liblzma
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libpthread
  TITLE:=liblzma library from XZ Utils
endef

define GenPlugin
 define Package/$(1)
   $(call Package/xz/Default)
   DEPENDS:=xz +$(DEPENDS_$(2)) $(if $(XZ_DEPENDS_$(2)),+xz-$(XZ_DEPENDS_$(2)))
   TITLE:=$(2) utility from XZ Utils
 endef
endef

$(foreach i,$(XZ_UTILS),$(eval $(call GenPlugin,xz-$(i),$(i))))

CONFIGURE_ARGS += \
	--enable-small \
	--enable-assume-ram=4 \
	--disable-assembler \
	--disable-werror

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/lzma
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/lzma.h \
		$(1)/usr/include/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/lzma/*.h \
		$(1)/usr/include/lzma/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/liblzma.pc \
		$(1)/usr/lib/pkgconfig/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/liblzma.* \
		$(1)/usr/lib/
endef

define Package/xz/install
	true
endef

define BuildPlugin
  define Package/$(1)/install
	$(INSTALL_DIR) $$(1)/usr/bin
ifneq ($(XZ_DEPENDS_$(2)),)
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/bin/$(2) \
		$$(1)/usr/bin/
else
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/$(2) \
		$$(1)/usr/bin/
endif
  endef

  $$(eval $$(call BuildPackage,$(1)))
endef

define Package/liblzma/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/liblzma.so* \
		$(1)/usr/lib/
endef

$(eval $(call BuildPackage,xz))
$(eval $(call BuildPackage,liblzma))
$(foreach i,$(XZ_UTILS),$(eval $(call BuildPlugin,xz-$(i),$(i))))
