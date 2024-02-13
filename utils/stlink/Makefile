include $(TOPDIR)/rules.mk

PKG_NAME:=stlink
PKG_VERSION:=1.8.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/stlink-org/$(PKG_NAME)/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=cff760b5c212c2cc480f705b9ca7f3828d6b9c267950c6a547002cd0a1f5f6ac

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE.md

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/stlink/Default
  SECTION:=utils
  CATEGORY:=Utilities
  URL:=https://github.com/stlink-org/stlink
  TITLE:=stlink - program and debug STM32 devices
  DEPENDS:=+libusb-1.0
endef

define Package/stlink
  $(call Package/stlink/Default)
  MENU:=1
  ABI_VERSION:=1
endef

define Package/stlink/description
 stlink is an open source toolset to program and debug STM32 devices
 and boards manufactured by STMicroelectronics. It supports several so
 called STLINK programmer boards (and clones thereof) which use a
 microcontroller chip to translate commands from USB to JTAG/SWD.
endef

define GenPlugin
  define Package/$(addprefix stlink-,$(1))
    $(call Package/stlink/Default)
    TITLE:=Utility $(1) from stlink
    DEPENDS:=stlink
  endef

   define Package/$(addprefix stlink-,$(1))/description
     Utility $(1) from the stlink package.
   endef
endef

FILES:= \
	st-info \
	st-flash \
	st-trace \
	st-util

$(foreach a,$(FILES),$(eval $(call GenPlugin,$(a))))

define PartInstall
define Package/stlink-$(1)/install
	$(INSTALL_DIR) $$(1)/usr/bin
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/$(1) \
		$$(1)/usr/bin/
endef
endef

$(foreach file,$(FILES),$(eval $(call PartInstall,$(file))))

define Package/stlink/install
	$(INSTALL_DIR) $(1)/usr/lib $(1)/usr/share/stlink/chips/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libstlink.so.$(ABI_VERSION)* \
		$(1)/usr/lib/
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/share/stlink/chips/*.chip \
		$(1)/usr/share/stlink/chips/
endef

$(eval $(call BuildPackage,stlink))
$(foreach file,$(FILES),$(eval $(call BuildPackage,stlink-$(file))))
