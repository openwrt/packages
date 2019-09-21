include $(TOPDIR)/rules.mk

PKG_NAME:=serdisplib
PKG_VERSION:=2.01
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/serdisplib
PKG_HASH:=a0a4eb6339de33f694e8eec1731bbe31789493434f747998a8788c2d0e6c324b
PKG_LICENSE:=GPL-2.0
PLG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

PKG_FIXUP:=libtool

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += --enable-dynloading --disable-statictools

define Package/serdisplib
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=serdisplib
  URL:=http://serdisplib.sourceforge.net/
endef

define Package/serdisplib/description
 serdisplib started as a library to drive serial displays with
 built-in controllers. It can optionally dynamically link with
 libusb-compat, libgd and libpthread, some features require having
 those packages installed as well.
endef

define Package/serdisplib-tools
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=serdisplib tools
  URL:=http://serdisplib.sourceforge.net/
  DEPENDS:=+serdisplib +libgd
endef

define Package/serdisplib-tools/description
 serdisplib started as a library to drive serial displays with
 built-in controllers. This package contains tools for serdisplib:
 * l4m132c_tool
 * l4m320t_tool
 * multidisplay
 * sdcmegtron_tool
 * touchscreen_tool
endef

TARGET_CFLAGS += $(FPIC)

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/serdisplib
	$(CP) $(PKG_BUILD_DIR)/include/serdisplib/*.h $(1)/usr/include/serdisplib
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/lib/*.{a,so*} $(1)/usr/lib/
endef

define Package/serdisplib/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/lib/*.so* $(1)/usr/lib/
endef

define Package/serdisplib-tools/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tools/l4m132c_tool $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tools/l4m320t_tool $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tools/multidisplay $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tools/sdcmegtron_tool $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tools/touchscreen_tool $(1)/usr/bin
endef

$(eval $(call BuildPackage,serdisplib))
$(eval $(call BuildPackage,serdisplib-tools))
