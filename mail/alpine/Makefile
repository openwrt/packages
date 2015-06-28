#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=alpine
PKG_VERSION:=2.20
PKG_RELEASE:=2

PKG_SOURCE_URL:=http://patches.freeiz.com/alpine/release/src/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_MD5SUM:=043b67666af73b26f9627ad97e2aaf92

PKG_MAINTAINER:=Antti Seppälä <a.seppala@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_INSTALL:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/alpine/Default
  SECTION:=mail
  CATEGORY:=Mail
  DEPENDS:=+libopenssl +libncurses +libpthread +libpam $(ICONV_DEPENDS) $(INTL_DEPENDS)
  TITLE:=Alternatively Licensed Program for Internet News and Email
  URL:=http://www.washington.edu/alpine
endef

define Package/alpine/Default/description
 Alpine (Alternatively Licenced Program for Internet News and Email) is a
 free software email client developed at the University of Washington.
 It is suitable for both the inexperienced email user as well as for
 the most demanding power user.
endef

define Package/alpine
$(call Package/alpine/Default)
  TITLE+= (with OpenSSL support)
  DEPENDS+= +libopenssl
  VARIANT:=ssl
endef

define Package/alpine/description
$(call Package/alpine/Default/description)
 This package is built with OpenSSL support.
endef

define Package/alpine-nossl
$(call Package/alpine/Default)
  TITLE+= (without OpenSSL support)
  VARIANT:=nossl
endef

define Package/alpine-nossl/description
$(call Package/alpine/Default/description)
 This package is built without OpenSSL support.
endef

CONFIGURE_ARGS += \
	--with-libiconv-prefix=$(ICONV_PREFIX) \
	--with-libintl-prefix=$(INTL_PREFIX) \
	--without-tcl \
	--without-ldap \
	--without-krb5 \
	--with-system-pinerc=/etc/pine.conf \
	--with-system-fixed-pinerc=/etc/pine.conf.fixed \
	--with-supplied-regex \
	--with-default-sshpath=/usr/bin/ssh \
	--disable-debug \
	--disable-mouse \
	--with-c-client-target=slx \

CONFIGURE_VARS += \
	top_builddir=$(PKG_BUILD_DIR)

ifeq ($(BUILD_VARIANT),ssl)
	CONFIGURE_ARGS += \
		--with-ssl-include-dir=$(STAGING_DIR)/usr/include/openssl/. \
		--with-ssl-lib-dir=$(STAGING_DIR)/usr/lib
endif

ifeq ($(BUILD_VARIANT),nossl)
	CONFIGURE_ARGS += \
		--without-ssl
endif

ifeq ($(CONFIG_BUILD_NLS),y)
  DISABLE_NLS:=
endif

ifeq ($(CONFIG_IPV6),y)
  DISABLE_IPV6:=
else
  DISABLE_IPV6:=--without-ipv6
endif

define Build/Compile
	( cd $(PKG_BUILD_DIR)/pith ; \
		$(HOSTCC) help_h_gen.c -c -o help_h_gen.o ; \
		$(HOSTCC) help_h_gen.o -o help_h_gen ; \
		$(HOSTCC) help_c_gen.c -c -o help_c_gen.o ; \
		$(HOSTCC) help_c_gen.o -o help_c_gen ; \
	)
	$(call Build/Compile/Default)
endef

define Package/alpine/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/$(PKG_NAME) $(1)/usr/bin/$(PKG_NAME)
endef

Package/alpine-nossl/install = $(Package/alpine/install)

$(eval $(call BuildPackage,alpine))
$(eval $(call BuildPackage,alpine-nossl))
