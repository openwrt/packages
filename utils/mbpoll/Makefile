include $(TOPDIR)/rules.mk

PKG_NAME:=mbpoll
PKG_VERSION:=1.5.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/epsilonrt/mbpoll/archive/refs/tags/v$(PKG_VERSION).tar.gz?
PKG_HASH:=a9bcc3afa3b85b3794505d07827873ead280d96a94769d236892eb8a4fb9956f

PKG_MAINTAINER:=Jens Wagner <jens@wagner2013.de>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/mbpoll
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Command line utility to communicate with Modbus slaves (RTU/TCP)
  URL:=https://epsilonrt.fr/
  DEPENDS:=+libmodbus
endef

define Package/mbpoll/description
  mbpoll is a command line utility to communicate with Modbus slaves
  (RTU/TCP). It can handle discrete inputs, binary outputs (coils),
  input registers and write output registers (holding registers)
endef

define Package/mbpoll/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/mbpoll $(1)/usr/bin/
endef

$(eval $(call BuildPackage,mbpoll))
