include $(TOPDIR)/rules.mk

PKG_NAME:=inih
PKG_VERSION:=61
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/benhoyt/inih
PKG_SOURCE_VERSION:=r$(PKG_VERSION)
PKG_MIRROR_HASH:=37dadf0ba9177b88c7c721d47bfa3be69297a05a7d8b0b5e743161e3df5a4789

PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE.txt

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk

define Package/libinih/Default
  SECTION:=libs
  CATEGORY:=Libraries
  URL:=https://github.com/benhoyt/inih
endef

define Package/libinih
  $(call Package/libinih/Default)
  TITLE:=Simple .INI file parser in C
endef

define Package/libinireader
  $(call Package/libinih/Default)
  TITLE:=C++ library and API for inih
  DEPENDS:=+libinih +libstdcpp
endef

define Package/libinih/description
  inih (INI Not Invented Here) is a simple .INI file parser written
  in C. It's only a couple of pages of code, and it was designed to
  be small and simple, so it's good for embedded systems. It's also
  more or less compatible with Python's ConfigParser style of .INI
  files, including RFC 822-style multi-line syntax and name: value
  entries.
endef

Package/libinireader/description = $(Package/libinih/description)

MESON_ARGS += \
	-Ddefault_library=both \
	-Ddistro_install=true \
	-Dwith_INIReader=true \
	-Dmulti-line_entries=true \
	-Dutf-8_bom=true \
	-Dinline_comments=true \
	-Duse_heap=false

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/{ini,INIReader}.h $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/{inih,INIReader}.pc $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib{inih,INIReader}.a $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib{inih,INIReader}.so* $(1)/usr/lib/
endef

define Package/libinih/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libinih.so* $(1)/usr/lib/
endef

define Package/libinireader/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libINIReader.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libinih))
$(eval $(call BuildPackage,libinireader))
