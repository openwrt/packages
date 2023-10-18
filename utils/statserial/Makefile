include $(TOPDIR)/rules.mk

PKG_NAME:=statserial
PKG_VERSION:=1.1-25
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://salsa.debian.org/debian/statserial.git
PKG_SOURCE_VERSION:=debian/$(PKG_VERSION)
PKG_MIRROR_HASH:=d493fd3154de4e52811e1d4f2ee68d573b1bcc24b58089b3b3dc41461357920e

PKG_MAINTAINER:=Jakub Raczynski <myszsoda@gmail.com>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/statserial
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=statserial
  URL:=https://salsa.debian.org/debian/statserial
  DEPENDS:=+libncurses
endef

define Package/statserial/description
 Display serial port modem status lines.

 Statserial displays a table of the signals on a standard 9-pin or
 25-pin serial port, and indicates the status of the handshaking lines.
 It can be useful for debugging problems with serial ports or modems.
endef

define Package/statserial/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/statserial $(1)/usr/bin/
endef

$(eval $(call BuildPackage,statserial))
