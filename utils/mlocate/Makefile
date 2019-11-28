#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mlocate
PKG_VERSION:=0.26
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://releases.pagure.org/mlocate/
PKG_HASH:=3063df79fe198fb9618e180c54baf3105b33d88fe602ff2d8570aaf944f1263e

PKG_INSTALL:=1
PKG_FORTIFY_SOURCE:=0

PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec@nic.cz>

include $(INCLUDE_DIR)/package.mk

define Package/mlocate
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=mlocate - quickly find files on the filesystem
  URL:=https://pagure.io/mlocate
endef

define Package/mlocate/description
 Quickly find files on the filesystem based on their name mlocate is a new implementation of locate, a tool to find files
 anywhere in the filesystem based on their name, using a fixed pattern or a regular expression. Unlike other tools like find(1), locate uses
 a previously created database to perform the search, allowing queries to execute much faster.
endef

define Package/mlocate/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
endef

$(eval $(call BuildPackage,mlocate))
