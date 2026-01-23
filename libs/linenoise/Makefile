#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=linenoise
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/antirez/linenoise.git
PKG_SOURCE_DATE:=2026-01-08
PKG_SOURCE_VERSION:=dc83cc373ac2058030eb3cf5e404959a26fef112
PKG_MIRROR_HASH:=e32bcc55c6fb1d849883d03a2ec6bc869d3cab5da827e1d7560e712be718e50c

PKG_MAINTAINER:=Maxim Storchak <m.storchak@gmail.com>
PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE

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
