include $(TOPDIR)/rules.mk

PKG_NAME:=wxwidgets
PKG_VERSION:=3.2.11
PKG_RELEASE:=1

PKG_SOURCE:=wxWidgets-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://github.com/wxWidgets/wxWidgets/releases/download/v$(PKG_VERSION)
PKG_HASH:=6a129015bce2e914e4bf61ec4411854ad962801d47e92f2eb8340adb6a90af08
PKG_BUILD_DIR:=$(BUILD_DIR)/wxWidgets-$(PKG_VERSION)

PKG_MAINTAINER:=Ville Takio <ville+git@takio.fi>
PKG_LICENSE:=LGPL-2.0-or-later WITH WxWindows-exception-3.1
PKG_LICENSE_FILES:=docs/licence.txt docs/lgpl.txt
PKG_CPE_ID:=cpe:/a:wxwidgets:wxwidgets

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

# wx configure aborts on unknown options (--disable-nls).
DISABLE_NLS:=

# The release series (3.2) is part of the library and header paths and,
# being ABI-stable within the series, of the package name.
WX_RELEASE:=$(subst $(space),.,$(wordlist 1,2,$(subst .,$(space),$(PKG_VERSION))))
WX_CONFIG_NAME:=$(GNU_TARGET_NAME)-base-unicode-$(WX_RELEASE)

define Package/libwxbase
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=wxWidgets base library (no GUI)
  URL:=https://www.wxwidgets.org/
  DEPENDS:=+libstdcpp
  ABI_VERSION:=$(WX_RELEASE)
endef

define Package/libwxbase/description
  The non-GUI part of wxWidgets (wxBase): strings, files, streams,
  threads, configuration and command line parsing. Built without
  networking (sockets, URLs, IPC), archive and compressed streams,
  regular expressions, file system watching and debug assertions.
endef

CONFIGURE_ARGS += \
	--disable-gui \
	--disable-debug_flag \
	--disable-sockets \
	--disable-arcstream \
	--disable-fs_archive \
	--disable-tarstream \
	--disable-fswatcher \
	--disable-secretstore \
	--disable-backtrace \
	--without-zlib \
	--without-regex \
	--without-expat \
	--without-liblzma \
	--without-libcurl

# musl and glibc both support positional printf arguments; configure
# cannot run its test program when cross-compiling.
CONFIGURE_VARS += \
	wx_cv_func_snprintf_pos_params=yes

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include $(1)/usr/lib/wx/config $(1)/usr/bin $(2)/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/include/wx-$(WX_RELEASE) $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libwx_baseu-$(WX_RELEASE)*.so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/wx/include $(1)/usr/lib/wx/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/wx/config/$(WX_CONFIG_NAME) $(1)/usr/lib/wx/config/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/wx/config/$(WX_CONFIG_NAME) $(2)/bin/wx-config
	$(SED) 's,^\(prefix\|exec_prefix\)=.*,\1=$(STAGING_DIR)/usr,g' $(2)/bin/wx-config
	$(LN) $(STAGING_DIR)/host/bin/wx-config $(1)/usr/bin/wx-config
endef

define Package/libwxbase/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libwx_baseu-$(WX_RELEASE).so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libwxbase))
