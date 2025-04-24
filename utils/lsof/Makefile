#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=lsof
PKG_VERSION:=4.99.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/lsof-org/lsof/releases/download/$(PKG_VERSION)
PKG_HASH:=86428a8881b0d1147a52058e853c775b83d794f0da685d549b2bfd07063ed1cd
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=Maxim Storchak <m.storchak@gmail.com>
PKG_LICENSE:=lsof
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:lsof_project:lsof

include $(INCLUDE_DIR)/package.mk

define Package/lsof
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libtirpc
  TITLE:=LiSt Open Files - a diagnostic tool
  URL:=http://people.freebsd.org/~abe/
endef

CONFIGURE_ARGS += --without-selinux

define Package/lsof/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lsof $(1)/usr/bin
endef

$(eval $(call BuildPackage,lsof))
