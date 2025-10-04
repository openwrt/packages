#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=linenoise
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/antirez/linenoise.git
PKG_SOURCE_DATE:=2025-09-10
PKG_SOURCE_VERSION:=880b94130ffa5f8236392392b447ff2234b11983
PKG_MIRROR_HASH:=a554a5ea9b2111cfb1d844a072933109f8316914eb40edca3919915a5ddb5df9

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
