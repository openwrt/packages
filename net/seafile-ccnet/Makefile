#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=seafile-ccnet
PKG_VERSION:=6.0.7
PKG_RELEASE=$(PKG_SOURCE_VERSION)-1
PKG_LICENSE:=GPL-3.0

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/haiwen/ccnet-server.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=a0de32b9cfeca98ab93d84cacbe9d315d7ecca35
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MIRROR_HASH:=b7ac0e5775aff91746e7bfc297b6cf788c9e7372084e28762467f8bd75cee2f8
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
$(call include_mk, python-package.mk)

define Package/seafile-ccnet
    SECTION:=net
    CATEGORY:=Network
    TITLE:=Seafile server - ccnet component
    MAINTAINER:=Gergely Kiss <mail.gery@gmail.com>
    URL:=http://seafile.com/
    DEPENDS:=+libsearpc +libevent2 +libopenssl \
		+glib2 +python +libzdb +libuuid \
		+libpthread +libsqlite3 +jansson $(ICONV_DEPENDS)
    EXTRA_DEPENDS:=libsearpc (=6.0.7-8998e7b2c5587f0b94c48db24e2952d08def5add-1)
endef

define Package/seafile-ccnet/description
   Ccnet is a framework for writing networked applications in C.
endef

CONFIGURE_ARGS += --disable-client \
		    --enable-server \
		    --disable-ldap \
		    --disable-cluster \
		    --enable-python \
		    --disable-server-pkg \
		    --disable-static-build \
		    --disable-compile-demo \
		    --disable-console

PKG_BUILD_DEPENDS:=vala/host

TARGET_LDFLAGS += -Wl,-rpath-link=$(STAGING_DIR)/usr/lib -liconv \
		    -L$(STAGING_DIR)/usr/lib/mysql -lmysqlclient -lz

define Package/seafile-ccnet/install
	$(INSTALL_DIR) $(1)/usr/{bin,lib}
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/ccnet* $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/ccnet $(1)$(PYTHON_PKG_DIR)
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libccnet.so* $(1)/usr/lib/
	find $(1) -name "*\.pyc" -o -name "*\.pyo" | xargs rm -f
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/include/ccnet* $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libccnet.pc $(1)/usr/lib/pkgconfig/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libccnet.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,seafile-ccnet))
