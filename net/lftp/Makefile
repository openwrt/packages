#
# Copyright (C) 2008-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lftp
PKG_VERSION:=4.8.3
PKG_RELEASE:=1
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=http://lftp.tech/ftp/ \
		https://mirror.csclub.uwaterloo.ca/gentoo-distfiles/distfiles/
		
PKG_HASH:=de7aee451afaa1aa391f7076b5f602922c2da0e05524a8d8fea413eda83cc78b


PKG_LICENSE:=GPL-3.0+
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/package.mk

define Package/lftp
  SUBMENU:=File Transfer
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libncurses +libopenssl +libreadline $(CXX_DEPENDS) +libexpat +zlib
  TITLE:=a sophisticated file transfer program with command line interface.
  MAINTAINER:=Federico Di Marco <fededim@gmail.com>
  URL:=http://lftp.yar.ru/
endef

define Package/lftp/description
LFTP is a sophisticated file transfer program with command line interface. It supports FTP, HTTP, FISH, SFTP, HTTPS and FTPS protocols. GNU Readline library is used for input.
Every operation in lftp is reliable, that is any non-fatal error is handled and the operation is retried automatically. So if downloading breaks, it will be restarted from the point automatically. Even if ftp server does not support REST command, lftp will try to retrieve the file from the very beginning until the file is transferred completely. This is useful for dynamic-ip machines which change their IP addresses quite often, and for sites with very bad internet connectivity.

lftp has shell-like command syntax allowing you to launch several commands in parallel in background (&). It is also possible to group commands within () and execute them in background. All background jobs are executed in the same single process. You can bring a foreground job to background with ^Z (c-z) and back with command `wait' (or `fg' which is alias to `wait'). To list running jobs, use command `jobs'. Some commands allow redirecting their output (cat, ls, ...) to file or via pipe to external command. Commands can be executed conditionally based on termination status of previous command (&&, ||).

lftp has builtin mirror which can download or update a whole directory tree. There is also reverse mirror (mirror -R) which uploads or updates a directory tree on server.
endef

CONFIGURE_ARGS += \
	--without-libiconv-prefix \
	--without-libintl-prefix \
	--without-gnutls \
	--without-libidn2 \
	--without-libresolv \
	--with-openssl="$(STAGING_DIR)/usr" \
	--with-readline="$(STAGING_DIR)/usr" \
	--with-zlib="$(STAGING_DIR)/usr" \
	--disable-static

TARGET_CXXFLAGS+= -std=c++11

define Package/lftp/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/lftp $(1)/usr/bin/
endef

$(eval $(call BuildPackage,lftp))
