#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=stress-ng
PKG_VERSION:=0.17.03
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/ColinIanKing/stress-ng/tar.gz/refs/tags/V$(PKG_VERSION)?
PKG_HASH:=3646118dcd683bf1929357e67d36c75f950e849db48f26d298b11028e78f3e7a

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/stress-ng
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=stress-ng is a stress test utility
  URL:=https://github.com/ColinIanKing/stress-ng
  DEPENDS:=+zlib +libbsd +libaio +libsctp +libkmod +libatomic +libjpeg
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
