#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ragel
PKG_VERSION:=6.10
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://www.colm.net/files/ragel/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=5f156edb65d20b856d638dd9ee2dfb43285914d9aa2b6ec779dac0270cd56c3f

PKG_MAINTAINER:=John Audia <therealgraysky@proton.me>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING

PKG_HOST_ONLY:=1
HOST_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/ragel
  SECTION:=devel
  CATEGORY:=Development
  TITLE:=Compiles finite state machines from regular languages into executable code
  URL:=https://www.colm.net/open-source/ragel/
  BUILDONLY:=1
endef

HOST_CONFIGURE_VARS += CXXFLAGS="$(HOST_CXXFLAGS) -std=gnu++98"

$(eval $(call HostBuild))
$(eval $(call BuildPackage,ragel))
