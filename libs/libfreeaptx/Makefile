include $(TOPDIR)/rules.mk

PKG_NAME:=libfreeaptx
PKG_VERSION:=0.2.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/regularhunter/libfreeaptx/tar.gz/$(PKG_VERSION)?
PKG_HASH:=5ab5ebddf3f2eb7ce47a505b87460b00fc1ede99c70010796d3575ab31ea80bf

PKG_MAINTAINER:=Mirko Vogt <mirko-openwrt@nanl.de>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libfreeaptx
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Open source aptX / aptX HD codec library
  URL:=https://github.com/regularhunter/libfreeaptx
  ABI_VERSION:=0
endef

define Package/libfreeaptx/description
  Fork of libopenaptx: encoder and decoder for the Qualcomm aptX and
  aptX HD Bluetooth A2DP codecs, as used by the bluez5 plugin of PipeWire.
endef

# Plain POSIX Makefile. Override CFLAGS/LDFLAGS wholesale: upstream defaults
# are just "-W -Wall -O3" and "-s" (stripping is OpenWrt's job).
MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS) -W -Wall" \
	CPPFLAGS="$(TARGET_CPPFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	PREFIX=/usr

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/include/freeaptx.h $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libfreeaptx.so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libfreeaptx.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libfreeaptx/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libfreeaptx.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libfreeaptx))
