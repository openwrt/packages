# Copyright (C) 2009-2025 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=nfs-kernel-server
PKG_VERSION:=2.8.4
PKG_RELEASE:=2
PKG_HASH:=11c4cc598a434d7d340bad3e072a373ba1dcc2c49f855d44b202222b78ecdbf5

PKG_SOURCE:=nfs-utils-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@KERNEL/linux/utils/nfs-utils/$(PKG_VERSION)
MAINTAINER:=John Audia <therealgraysky@proton.me>
PKG_LICENSE:=GPL-2.0-or-later
PKG_CPE_ID:=cpe:/a:nfs_project:nfs-utils

HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/nfs-utils-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/nfs-utils-$(PKG_VERSION)
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_BUILD_DEPENDS:=$(PKG_NAME)/host libevent2
HOST_BUILD_DEPENDS:=libtirpc/host
PKG_CONFIG_DEPENDS:=CONFIG_IPV6

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/nfs-kernel-server/Default
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Filesystem
	DEPENDS:=+libblkid +libuuid +libtirpc +lsqlite3 +libxml2 +libnl
	URL:=http://nfs.sourceforge.net/
endef

define Package/nfs-utils/Default
	SECTION:=utils
	CATEGORY:=Utilities
	SUBMENU:=Filesystem
	URL:=http://nfs.sourceforge.net/
endef

define Package/nfs-kernel-server
	$(call Package/nfs-kernel-server/Default)
	TITLE:=Kernel NFS server (NFSv3)
	DEPENDS+= +kmod-fs-nfsd +kmod-fs-nfs +rpcbind
	VARIANT:=v3
	USERID:=nfs:nfs
endef

define Package/nfs-kernel-server/description
Kernel NFS server with NFSv3 support
endef

define Package/nfs-kernel-server-v4
	$(call Package/nfs-kernel-server/Default)
	TITLE:=Kernel NFS server (NFSv4.x)
	DEPENDS+= +kmod-fs-nfsd +kmod-fs-nfs +rpcbind +kmod-fs-nfs-v4 +libkeyutils +libdevmapper +libevent2-core +libreadline
	CONFLICTS:=nfs-kernel-server
	VARIANT:=v4
	PROVIDES:=nfs-kernel-server
	USERID:=nfs:nfs
endef

define Package/nfs-kernel-server-v4/description
Kernel NFS server with NFSv4.x support
endef

define Package/nfs-utils
	$(call Package/nfs-utils/Default)
	TITLE:=NFS mount and umount utils (NFSv3)
	DEPENDS:=+libtirpc
	VARIANT:=v3
endef

define Package/nfs-utils/description
Mount/umount utilities for NFSv3
endef

define Package/nfs-utils-v4
	$(call Package/nfs-utils/Default)
	TITLE:=NFS mount and umount utils (NFSv4.x)
	DEPENDS:=+libtirpc +libkeyutils +libdevmapper
	CONFLICTS:=nfs-utils
	VARIANT:=v4
	PROVIDES:=nfs-utils
endef

define Package/nfs-utils-v4/description
Mount/umount utilities for NFSv4.x
endef

define Package/nfs-kernel-server-utils
	$(call Package/nfs-kernel-server/Default)
	TITLE:=NFS server utils
	DEPENDS:=nfs-kernel-server +libtirpc
endef

define Package/nfs-kernel-server-utils/description
NFS server utils including showmount and nfsstat
endef

TARGET_CFLAGS += -Wno-error=implicit-function-declaration \
		-Wno-error=strict-prototypes \
		-Wno-error=incompatible-pointer-types \
		-Wno-error=format-security \
		-Wno-error=undef \
		-Wno-error=missing-include-dirs

ifneq ($(CONFIG_USE_MUSL),)
	TARGET_CFLAGS += -D_LARGEFILE64_SOURCE
endif

TARGET_LDFLAGS += -L$(STAGING_DIR)/usr/lib/libevent

CONFIGURE_ARGS += \
	--disable-caps \
	--disable-gss \
	--enable-static \
	--with-rpcgen=internal

ifeq ($(CONFIG_IPV6),n)
	CONFIGURE_ARGS += --disable-ipv6
endif

ifeq ($(BUILD_VARIANT),v3)
	CONFIGURE_ARGS += \
	--disable-nfsdcld \
	--disable-nfsv4server \
	--disable-nfsv4 \
	--disable-nfsv41 \
	--disable-nfsv42
endif

ifeq ($(BUILD_VARIANT),v4)
	CONFIGURE_ARGS += \
	--enable-nfsdcld \
	--enable-nfsv4server \
	--enable-nfsv4 \
	--enable-nfsv41 \
	--enable-nfsv42
endif

CONFIGURE_VARS += \
	libblkid_cv_is_recent=yes \
	ac_cv_lib_resolv___res_querydomain=yes \
	ac_cv_lib_bsd_daemon=no

MAKE_FLAGS += \
	OPT="$(TARGET_CFLAGS)" \
	INSTALLSUID="install -m 4755" \
	DESTDIR="$(PKG_INSTALL_DIR)" \
	RPCGEN_PATH=$(STAGING_DIR_HOSTPKG)/bin/rpcgen \
	RPCGEN=$(STAGING_DIR_HOSTPKG)/bin/rpcgen

HOST_CFLAGS += -Dlinux \
	-Wno-error=missing-include-dirs

HOST_CONFIGURE_ARGS += \
	--disable-gss \
	--disable-nfsrahead \
	--disable-nfsdctl \
	--without-tcp-wrappers \
	--disable-junction \
	--with-rpcgen=internal

HOST_CONFIGURE_VARS += \
	ac_cv_lib_event_event_dispatch=yes \
	ac_cv_lib_nfsidmap_nfs4_init_name_mapping=yes \
	ac_cv_lib_blkid_blkid_get_library_version=yes \
	ac_cv_header_event_h=yes \
	ac_cv_header_nfsidmap_h=yes \
	ac_cv_header_blkid_blkid_h=yes \
	ac_cv_lib_resolv___res_querydomain=yes \
	ac_cv_func_prctl=yes \
	ac_cv_sizeof_size_t=0 \
	ac_cv_func_getrpcbynumber=yes \
	ac_cv_func_getrpcbynumber_r=yes \
	enable_ipv6=no \
	enable_nfsdctl=no \
	GSSGLUE_CFLAGS=" " \
	GSSGLUE_LIBS=" " \
	RPCSECGSS_CFLAGS=" " \
	RPCSECGSS_LIBS=" " \
	ac_cv_lib_event_core_event_base_dispatch=yes \
	ac_cv_header_event2_event_h=yes \
	c_cv_lib_sqlite3_sqlite3_libversion_number=yes \
	libsqlite3_cv_is_recent=yes \
	ac_cv_header_libdevmapper_h=yes \
	ac_cv_lib_devmapper_dm_task_create=yes

define Host/Compile
	$(MAKE) -C $(HOST_BUILD_DIR)/tools/rpcgen all
endef

define Host/Install
	$(INSTALL_DIR) $(STAGING_DIR_HOSTPKG)/bin
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/tools/rpcgen/rpcgen $(STAGING_DIR_HOSTPKG)/bin/rpcgen
endef

define Package/nfs-kernel-server/conffiles
/etc/exports
endef

Package/nfs-kernel-server-v4/conffiles = $(Package/nfs-kernel-server/conffiles)

define Package/nfs-utils/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/nfsidmap.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnfsidmap.{a,la,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libnfsidmap.pc $(1)/usr/lib/pkgconfig/
endef

define Package/nfs-kernel-server/install
	$(INSTALL_DIR) $(1)/etc/config $(1)/usr/sbin $(1)/etc/init.d
	$(INSTALL_DATA) ./files/nfsd.v3.exports $(1)/etc/exports
	$(INSTALL_BIN) ./files/nfsd.v3.init $(1)/etc/init.d/nfsd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/utils/statd/sm-notify $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/utils/statd/statd $(1)/usr/sbin/rpc.statd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/utils/nfsd/nfsd $(1)/usr/sbin/rpc.nfsd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/utils/mountd/mountd $(1)/usr/sbin/rpc.mountd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/utils/exportfs/exportfs $(1)/usr/sbin/
endef

define Package/nfs-kernel-server-v4/install
	$(INSTALL_DIR) $(1)/etc/config $(1)/usr/sbin $(1)/etc/init.d
	$(INSTALL_DATA) ./files/nfsd.v4.exports $(1)/etc/exports
	$(INSTALL_BIN) ./files/nfsd.v4.init $(1)/etc/init.d/nfsd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/utils/statd/sm-notify $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/utils/nfsd/nfsd $(1)/usr/sbin/rpc.nfsd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/utils/exportfs/exportfs $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/utils/nfsdcld/nfsdcld $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/rpc.idmapd $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/nfsv4.exportd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnfsidmap.so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnfsidmap/*.so $(1)/usr/lib/
endef

define Package/nfs-utils/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/sbin/mount.nfs $(1)/sbin/
	(cd $(1)/sbin; ln -sf mount.nfs umount.nfs)
endef

define Package/nfs-utils-v4/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/sbin/mount.nfs $(1)/sbin/
	(cd $(1)/sbin; ln -sf mount.nfs mount.nfs4; ln -sf mount.nfs umount.nfs; ln -sf mount.nfs umount.nfs4)
endef

define Package/nfs-kernel-server-utils/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/utils/showmount/showmount $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/utils/nfsstat/nfsstat $(1)/usr/sbin
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,nfs-kernel-server))
$(eval $(call BuildPackage,nfs-kernel-server-v4))
$(eval $(call BuildPackage,nfs-utils))
$(eval $(call BuildPackage,nfs-utils-v4))
$(eval $(call BuildPackage,nfs-kernel-server-utils))
