include $(TOPDIR)/rules.mk

PKG_NAME:=unibilium
PKG_VERSION:=2.1.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/neovim/unibilium/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=370ecb07fbbc20d91d1b350c55f1c806b06bf86797e164081ccc977fc9b3af7a

PKG_MAINTAINER:=Valeriy Kosikhin <vkosikhin@gmail.com>
PKG_LICENSE:=LGPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/libunibilium
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Terminfo parsing library
  URL:=https://github.com/neovim/unibilium/
endef

define Package/libunibilium/description
  Unibilium is a very basic terminfo library. It can read and write
  ncurses-style terminfo files, and it can interpret terminfo format strings.
endef

MAKE_FLAGS+= TERMINFO_DIRS='"/etc/terminfo:/lib/terminfo:/usr/share/terminfo:/usr/lib/terminfo:/usr/local/share/terminfo:/usr/local/lib/terminfo"'

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/unibilium.h $(1)/usr/include
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/unibilium.pc $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libunibilium.a $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libunibilium.so* $(1)/usr/lib
endef

define Package/libunibilium/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libunibilium.so* $(1)/usr/lib
endef

$(eval $(call BuildPackage,libunibilium))
