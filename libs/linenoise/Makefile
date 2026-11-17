#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=linenoise
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/antirez/linenoise.git
PKG_SOURCE_DATE:=2026-03-02
PKG_SOURCE_VERSION:=a473823d74b93eab2ba83480df16ed37617493f2
PKG_MIRROR_HASH:=3d0d1ce121e2000c6c1425e540281ca72ffe3ffb9cb77832585ac8435cf00b10

PKG_MAINTAINER:=Maxim Storchak <m.storchak@gmail.com>
PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:antirez:linenoise

include $(INCLUDE_DIR)/package.mk

define Package/linenoise
  TITLE:=A minimal, zero-config, readline replacement
  CATEGORY:=Libraries
  URL:=https://github.com/antirez/linenoise
  BUILDONLY:=1
endef

define Package/linenoise/description
 A minimal, zero-config, BSD licensed, readline replacement used in Redis,
 MongoDB, Android and many other projects.
endef

define Build/Compile
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/linenoise
	$(CP) $(PKG_BUILD_DIR)/linenoise.[ch] $(1)/usr/include/linenoise
endef

define Build/Clean
	$(RM) -rf $(STAGING_DIR)/usr/include/linenoise
endef

$(eval $(call BuildPackage,linenoise))
