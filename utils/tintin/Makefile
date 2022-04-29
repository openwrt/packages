include $(TOPDIR)/rules.mk

PKG_NAME:=tintin
PKG_VERSION:=2.02.20
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/scandum/tintin/releases/download/$(PKG_VERSION)/
PKG_HASH:=331673e6ee3c945cf27e1c0d71cec1225c9d992588ed73b2a707c4c49523e8d2

PKG_MAINTAINER:=scandum <ivdhoven@gmail.com>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:gnu:tt++

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/tintin
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Terminal
  TITLE:=tintin a MUD client
  DEPENDS:=+zlib +libpcre +libgnutls
  URL:=https://downloads.sf.net/tintin/
endef

define Package/tintin/description
  TinTin++ is a command line MUD client which features support for TELNET,
  PCRE, UTF-8, SSL, VT100, IPv6, the dynamic TINTIN scripting language,
  a comprensive trigger system, and several other features geared towards
  mudding, scripting, shell-scripting, text processing, automation,
  interprocess communication, redirection, xterm terminal emulation, and
  multiplexing / demultiplexing.
endef

define Build/Prepare
	$(Build/Prepare/Default)
	($(CP) $(PKG_BUILD_DIR)/../tt/src/. $(PKG_BUILD_DIR)/ && \
		$(SED) 's/^.*ptmx.*/#&/' $(PKG_BUILD_DIR)/configure.in && \
		$(SED) 's/^.*cannot check for file existence when cross compiling.*/#&/' $(PKG_BUILD_DIR)/configure)
endef
define Package/tintin/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/tt++ $(1)/usr/bin/
endef

$(eval $(call BuildPackage,tintin))
