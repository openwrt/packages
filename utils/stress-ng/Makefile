#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=stress-ng
PKG_VERSION:=0.19.02
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/ColinIanKing/stress-ng/tar.gz/refs/tags/V$(PKG_VERSION)?
PKG_HASH:=15a07030a14bbfd5991e9ba3fbfbc24ed3ae72a2c946b033c06b820bc16f41c4

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
# For MIPS there is some inline assembly, and this won't compile without '-mno-mips16'
PKG_BUILD_FLAGS:=no-mips16

include $(INCLUDE_DIR)/package.mk

define Package/stress-ng
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=stress-ng is a stress test utility
  URL:=https://github.com/ColinIanKing/stress-ng
  DEPENDS:=+zlib +libbsd +libaio +libsctp +libkmod +libatomic +libjpeg +USE_GLIBC:libcrypt-compat
  PROVIDES:=stress
endef

define Package/stress-ng/description
stress-ng will stress test a computer system in various selectable ways. It
was designed to exercise various physical subsystems of a computer as well as
the various operating system kernel interfaces.
endef

MAKE_FLAGS += \
	KERNEL=Linux

define Package/stress-ng/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/stress-ng $(1)/usr/bin/
endef

$(eval $(call BuildPackage,stress-ng))
