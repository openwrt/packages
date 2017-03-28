include $(TOPDIR)/rules.mk

PKG_NAME:=libtirpc
PKG_VERSION:=1.0.2
PKG_RELEASE:=1
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=git://git.linux-nfs.org/projects/steved/libtirpc.git
PKG_SOURCE_VERSION:=503ac2e9fa569d95e366766202a7ca840e28b28a
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE)
PKG_SOURCE:=$(PKG_SOURCE_SUBDIR).tar.gz
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)
PKG_FIXUP:=autoreconf
PKG_LICENSE:=BSD-4c
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

PKG_CONFIG_DEPENDS := \
	CONFIG_LIBTIRPC_GSSAPI \
	CONFIG_LIBTIRPC_KRB5

include $(INCLUDE_DIR)/package.mk

LIBTIRPC_DEPENDS:=
CONFIGURE_ARGS += --disable-static
ifeq ($(CONFIG_LIBTIRPC_GSSAPI),y)
	ifeq ($(CONFIG_LIBTIRPC_KRB5),y)
		LIBTIRPC_DEPENDS += +krb5-libs +e2fsprogs
		TARGET_CPPFLAGS:=-I$(STAGING_DIR)/usr/include/krb5 $(TARGET_CPPFLAGS)
	endif
else
	CONFIGURE_ARGS += --disable-gssapi
endif

define Package/libtirpc
	SECTION:=libs
	CATEGORY:=Libraries
	DEPENDS:=$(LIBTIRPC_DEPENDS)
	TITLE:=Transport-Independent RPC library
	URL:=http://nfsv4.bullopensource.org/doc/tirpc_rpcbind.php
endef

define Package/libtirpc/description
 Libtirpc is a port of Sun's Transport-Independent RPC library to Linux.
 It's being developed by the Bull GNU/Linux NFSv4 project.
endef

define Package/libtirpc/config
	source "$(SOURCE)/Config.in"
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
endef

define Package/libtirpc/install
	$(INSTALL_DIR) $(1)/usr/lib $(1)/etc
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/etc/netconfig $(1)/etc/netconfig
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/$(PKG_NAME).so.3.0.0 $(1)/usr/lib/$(PKG_NAME).so.3.0.0
	$(LN) /usr/lib/$(PKG_NAME).so.3.0.0 $(1)/usr/lib/$(PKG_NAME).so.3
	$(LN) /usr/lib/$(PKG_NAME).so.3.0.0 $(1)/usr/lib/$(PKG_NAME).so
endef

$(eval $(call BuildPackage,libtirpc))
