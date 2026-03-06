include $(TOPDIR)/rules.mk

PKG_NAME:=libsml
PKG_VERSION:=1.1.4
PKG_RELEASE:=1

PKG_SOURCE:=v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/volkszaehler/libsml/archive/refs/tags/
PKG_HASH:=97d5647e5805b7f0e31d8875a1867a6afccbff1c1945b961b36041af3597f275

PKG_MAINTAINER:=Andy Voigt <a.voigt@mailbox.org>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/libsml
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Smart Message Language (SML) library
  URL:=https://volkszaehler.org
  DEPENDS:=+libuuid
endef

define Package/libsml/description
 libSML implements the Smart Message Language (SML) protocol
 specified by VDE's Forum Netztechnik/Netzbetrieb (FNN).
 It can be used to communicate with SML-based smart meters
 and related components (EDL/MUC).
endef

define Build/Compile
	$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR)/sml \
		CC="$(TARGET_CC)"
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_BUILD_DIR)/sml/include/*.h $(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/sml/lib/libsml.so* $(1)/usr/lib/
endef

define Package/libsml/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/sml/lib/libsml.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libsml))