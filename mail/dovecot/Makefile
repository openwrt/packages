#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=dovecot
PKG_VERSION:=2.2.13
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.dovecot.org/releases/2.2
PKG_MD5SUM:=a3eb1c0b1822c4f2b0fe9247776baa71

PKG_BUILD_DEPENDS:=libiconv

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/dovecot
  SECTION:=mail
  CATEGORY:=Mail
  DEPENDS:=+libopenssl +librt +zlib +libbz2 +libcap
  TITLE:=An IMAP and POP3 daemon
  MAINTAINER:=Peter Wagner <tripolar@gmx.at>
  URL:=http://www.dovecot.org/
endef

define Package/dovecot/description
 Dovecot is a program which provides POP3 and IMAP services.
endef

CONFIGURE_ARGS += \
	--without-gssapi \
	--without-pam \
	--with-moduledir=/usr/lib/dovecot/modules \
	--with-notify=dnotify \
	--without-lzma \
	--without-lz4

CONFIGURE_VARS += \
	RPCGEN= \
	i_cv_signed_size_t=no \
	i_cv_signed_time_t=no \
	i_cv_gmtime_max_time_t=32 \
	i_cv_mmap_plays_with_write=yes \
	i_cv_fd_passing=yes \
	i_cv_c99_vsnprintf=yes \
	lib_cv_va_copy=yes \
	lib_cv_va_copy=yes \
	lib_cv___va_copy=yes \
	lib_cv_va_val_copy=yes

define Package/dovecot/install
	$(INSTALL_DIR)  $(1)/etc/init.d \
			$(1)/etc/dovecot \
			$(1)/usr/share/doc/dovecot/example-config \
			$(1)/usr/lib/dovecot \
			$(1)/usr/bin \
			$(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/etc/dovecot/* $(1)/etc/dovecot/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/dovecot/* $(1)/usr/lib/dovecot/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/doc/dovecot/example-config $(1)/usr/share/doc/dovecot/example-config
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/doveconf $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/* $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/dovecot.init $(1)/etc/init.d/dovecot
	rm  $(1)/usr/lib/dovecot/dovecot-config
	find $(1)/usr/lib/dovecot/ -name "*.a" -o -name "*.la" | xargs rm
endef

$(eval $(call BuildPackage,dovecot))
