#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=duperemove
PKG_VERSION:=0.15.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/markfasheh/duperemove/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=68cc28f5aa43fa2034e512f7b22cf5282ce2b0319b4e1061f7cdf55cc134273b

PKG_MAINTAINER:=Keith Garner <kgarner@kgarner.com>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE

# Set variables used in the source's Makefile
export VERSION="$(PKG_VERSION)"
export IS_RELEASE=1

include $(INCLUDE_DIR)/package.mk

define Package/duperemove
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Filesystem
  TITLE:=Duplicate file removal tool
  URL:=https://markfasheh.github.io/duperemove/
  DEPENDS:= \
  +libsqlite3 \
  +glib2 \
  +libxxhash \
  +libuuid \
  +libmount \
  +libblkid \
  +libbsd \
  +libatomic
endef

define Package/duperemove/description
  Duperemove is a simple tool for finding duplicated extents and submitting
  them for deduplication. When given a list of files it will hash their
  contents on an extent by extent basis and compare those hashes to each
  other, finding and categorizing extents that match each other. Optionally,
  a per-block hash can be applied for further duplication lookup. When given
  the -d option, duperemove will submit those extents for deduplication using
  the Linux kernel FIDEDUPRANGE ioctl.
endef

define Package/duperemove/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/duperemove $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/hashstats $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/btrfs-extent-same $(1)/usr/bin
endef

$(eval $(call BuildPackage,duperemove))
