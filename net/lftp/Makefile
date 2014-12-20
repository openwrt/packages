#
# Copyright (C) 2008-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lftp
PKG_VERSION:=4.6.0
PKG_RELEASE:=1
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=http://lftp.yar.ru/ftp \ http://lftp.cybermirror.org \ http://lftp.cybermirror.org/old
PKG_MD5SUM:=fc5f4e3b45c9011a193eb8c0c12eb2eb

PKG_LICENSE:=GPL-3.0+
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/package.mk

define Package/lftp
  SUBMENU:=File Transfer
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libncurses +libopenssl +libreadline $(CXX_DEPENDS) +libexpat
  TITLE:=a sophisticated file transfer program with command line interface.
  MAINTAINER:=Federico Di Marco <fededim@gmail.com>
  URL:=http://lftp.yar.ru/
endef

define Package/lftp/description
LFTP is a sophisticated file transfer program with command line interface. It supports FTP, HTTP, FISH, SFTP, HTTPS and FTPS protocols. GNU Readline library is used for input.
Every operation in lftp is reliable, that is any non-fatal error is handled and the operation is retried automatically. So if downloading breaks, it will be restarted from the point automatically. Even if ftp server does not support REST command, lftp will try to retrieve the file from the very beginning until the file is transferred completely. This is useful for dynamic-ip machines which change their IP addresses quite often, and for sites with very bad internet connectivity.

If you exit lftp when some jobs are not finished yet, lftp will move itself to nohup mode in background. The same happens when you have a real modem hangup or when you close an xterm.

lftp has shell-like command syntax allowing you to launch several commands in parallel in background (&). It is also possible to group commands within () and execute them in background. All background jobs are executed in the same single process. You can bring a foreground job to background with ^Z (c-z) and back with command `wait' (or `fg' which is alias to `wait'). To list running jobs, use command `jobs'. Some commands allow redirecting their output (cat, ls, ...) to file or via pipe to external command. Commands can be executed conditionally based on termination status of previous command (&&, ||).

lftp has builtin mirror which can download or update a whole directory tree. There is also reverse mirror (mirror -R) which uploads or updates a directory tree on server.

There is command `at' to launch a job at specified time in current context, command `queue' to queue commands for sequential execution for current server, and much more.

LFTP supports IPv6 for both FTP and HTTP protocols. For FTP protocol it uses method described in RFC2428.

Other low level stuff supported: ftp proxy, http proxy, ftp over http, opie/skey, fxp transfers, socks.

LFTP supports secure versions of the protocols FTP and HTTP: FTPS (explicit and implicit) and HTTPS. LFTP needs to be linked with an SSL library to support them. GNU TLS and OpenSSL are both supported as SSL backend.
endef

CONFIGURE_ARGS += \
	--without-libiconv-prefix \
	--without-libintl-prefix \
	--without-gnutls \
	--without-libidn \
	--without-libresolv \
	--with-openssl="$(STAGING_DIR)/usr" \
	--disable-static

#CONFIGURE_VARS += \
#	LIBS="-lz -lutil -lcurses -ldl" \
#	i_cv_posix_fallocate_works=no

#MAKE_VARS += \
#	LD="$(TARGET_CXX)"

define Package/lftp/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/lftp $(1)/usr/bin/
endef

$(eval $(call BuildPackage,lftp))
