#
# Copyright (C) 2026 Daniel Golle <daniel@makrotopia.org>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=kcp
PKG_VERSION:=2.1.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/skywind3000/kcp/tar.gz/$(PKG_VERSION)?
PKG_HASH:=54d3c80928d206529f67cba6f96f2c98007182b46e3112819b200d914f96e425

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

# Upstream honours BUILD_SHARED_LIBS but sets no VERSION/SOVERSION, so the
# soname is imposed here (see Build/Prepare): a bare libkcp.so leaves no way
# to express an ABI break. Upstream offers no ABI guarantee either way, so
# treat 0 as a packaged ABI epoch and bump it if the ikcp_* surface changes.
define Package/libkcp
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=KCP - A Fast and Reliable ARQ Protocol
  URL:=https://github.com/skywind3000/kcp
  ABI_VERSION:=0
endef

define Package/libkcp/description
  KCP is a fast and reliable ARQ protocol implementing a TCP-like reliable
  ordered stream on top of an unreliable datagram transport such as UDP,
  trading about 10-20% more bandwidth for 30-40% lower latency than TCP.
  It is a pure algorithm: the caller supplies the datagram in- and output.
endef

CMAKE_OPTIONS += \
	-DBUILD_TESTING=OFF \
	-DBUILD_SHARED_LIBS=ON

# CMake sets the soname itself, so a linker flag cannot win; the target
# property is the only thing it honours.
define Build/Prepare
	$(Build/Prepare/Default)
	echo 'set_target_properties(kcp PROPERTIES VERSION $(PKG_VERSION) SOVERSION 0)' \
		>> $(PKG_BUILD_DIR)/CMakeLists.txt
endef

define Package/libkcp/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libkcp.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libkcp))
