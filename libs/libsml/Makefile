include $(TOPDIR)/rules.mk

PKG_NAME:=libsml
PKG_VERSION:=1.1.5
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/volkszaehler/libsml/tar.gz/v${PKG_VERSION}?
PKG_HASH:=58dbc19edab0122e28676acc62e456f964c71894b10ed55058bcab3f4e3a8cc7

PKG_MAINTAINER:=Andy Voigt <a.voigt@mailbox.org>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/libsml
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Smart Message Language (SML) library
  URL:=https://volkszaehler.org
  DEPENDS:=+libuuid
  ABI_VERSION:=1
endef

define Package/libsml/description
 libSML implements the Smart Message Language (SML) protocol specified by
 VDE's Forum Netztechnik/Netzbetrieb (FNN). It can be used to communicate
 with SML-based smart meters and related components (EDL/MUC).
endef

define Build/Compile
	$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR)/sml \
		CC="$(TARGET_CC)" \
		LD="$(TARGET_CROSS)ld"
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_BUILD_DIR)/sml/include/* $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/sml/lib/libsml.{a,so*} $(1)/usr/lib/
endef

define Package/libsml/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/sml/lib/libsml.so.$(ABI_VERSION) $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libsml))
