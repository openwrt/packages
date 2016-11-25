#
# Copyright (C) 2016 Nikil Mehta <nikil.mehta@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=atool
PKG_VERSION:=0.39.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SAVANNAH/$(PKG_NAME)
PKG_MD5SUM:=aaf60095884abb872e25f8e919a8a63d0dabaeca46faeba87d12812d6efc703b

PKG_MAINTAINER:=Nikil Mehta <nikil.mehta@gmail.com>
PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/atool
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Compression
  TITLE:=tool for managing file archives of various types
  URL:=http://www.nongnu.org/atool/
  DEPENDS:=+perl +perlbase-encode +perlbase-file +perlbase-getopt +perlbase-posix
endef

define Package/atool/description
	atool is a script for managing file archives of various types (tar,
	tar+gzip, zip etc). The main command is probably aunpack,
	extracting files from an archive. It overcomes the dreaded "multiple
	files in archive root" problem by first extracting to a unique
	subdirectory, and then moving back the files if possible. aunpack
	also prevents local files from being overwritten by mistake.
	.
	Other commands provided are apack (create archives), als (list files
	in archives), and acat (extract files to standard out).
endef

define Package/atool/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/atool $(1)/usr/bin/
endef

$(eval $(call BuildPackage,atool))
