# Based partially on (wongsyrone/hbl0307106015) versions
include $(TOPDIR)/rules.mk

PKG_NAME:=samba
PKG_VERSION:=4.9.16
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://ftp.heanet.ie/mirrors/ftp.samba.org/stable/ \
		https://ftp.gwdg.de/pub/samba/stable/ \
		https://ftp.riken.jp/net/samba/samba/stable/ \
		http://www.nic.funet.fi/index/samba/pub/samba/stable/ \
		http://samba.mirror.bit.nl/samba/ftp/stable/ \
		https://download.samba.org/pub/samba/stable/
PKG_HASH:=613987fac719ed90f3daad6ca12517329f0754dd51c573f6b3623e6b03cb3916

PKG_MAINTAINER:=Andy Walsh <andy.walsh44+github@gmail.com>
PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:samba:samba

# samba4=(asn1_compile,compile_et) nfs-kernel-server=(rpcgen)
HOST_BUILD_DEPENDS:=python/host nfs-kernel-server/host
PKG_BUILD_DEPENDS:=samba4/host

PKG_CONFIG_DEPENDS:= \
	CONFIG_SAMBA4_SERVER_NETBIOS \
	CONFIG_SAMBA4_SERVER_AVAHI \
	CONFIG_SAMBA4_SERVER_VFS \
	CONFIG_SAMBA4_SERVER_VFSX \
	CONFIG_SAMBA4_SERVER_QUOTAS \
	CONFIG_SAMBA4_SERVER_ACL \
	CONFIG_PACKAGE_kmod-fs-btrfs \
	CONFIG_PACKAGE_kmod-fs-xfs

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/version.mk

define Package/samba4/Default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Samba $(PKG_VERSION)
  URL:=https://www.samba.org/
endef

define Package/samba4/Default/description
  The Samba software suite is a collection of programs that implements the
  SMB/CIFS protocol for UNIX systems, allowing you to serve files and printers.

  Samba 4 implements up-to protocol version SMB v3.1.1 (Win10), supports mDNS via AVAHI and a AD-DC setup via krb5.
  NOTE: No cluster and printer support.
endef

define Package/samba4-libs
  $(call Package/samba4/Default)
  TITLE+= libs
  DEPENDS:= +zlib +libtirpc +libpopt +libreadline +libcap \
	+PACKAGE_libpthread:libpthread +PACKAGE_libnettle:libnettle +PACKAGE_libgcrypt:libgcrypt +PACKAGE_libpam:libpam +PACKAGE_dbus:dbus +PACKAGE_libavahi-client:libavahi-client \
	+SAMBA4_SERVER_VFS:attr \
	+SAMBA4_SERVER_ACL:acl +SAMBA4_SERVER_ACL:attr \
	+SAMBA4_SERVER_AVAHI:libavahi-client
endef

define Package/samba4-server
  $(call Package/samba4/Default)
  TITLE+= server
  DEPENDS:= +samba4-libs
endef

define Package/samba4-server/description
  installs: smbd, nmbd (daemon) smbpasswd pdbedit testparm

  This provides the basic fileserver service and is the minimum needed to serve file shares.
  HINT: https://fitzcarraldoblog.wordpress.com/2016/10/17/a-correct-method-of-configuring-samba-for-browsing-smb-shares-in-a-home-network/
endef

define Package/samba4-server/config
  select PACKAGE_wsdd2
  source "$(SOURCE)/Config.in"
endef

define Package/samba4-client
  $(call Package/samba4/Default)
  TITLE+= client
  DEPENDS:= +samba4-libs
endef

define Package/samba4-client/description
  installs: smbclient cifsdd

  The smbclient program implements a simple ftp-like client for accessing SMB shares
endef

define Package/samba4-admin
  $(call Package/samba4/Default)
  TITLE+= admin tools
  DEPENDS:= +samba4-libs
endef

define Package/samba4-admin/description
  installs: net smbcontrol profiles rpcclient smbcacls smbcquotas

  Administration tools collection
endef

define Package/samba4-utils
  $(call Package/samba4/Default)
  TITLE+= utils
  DEPENDS:= +samba4-libs
endef

define Package/samba4-utils/description
  installs: smbstatus smbtree smbget nmblookup mvxattr

  Utilities collection
endef

TARGET_CFLAGS += -ffunction-sections -fdata-sections
TARGET_LDFLAGS += -Wl,--gc-sections

CONFIGURE_VARS += \
	CPP="$(TARGET_CROSS)cpp"

CONFIGURE_CMD = ./buildtools/bin/waf
HOST_CONFIGURE_CMD = ./buildtools/bin/waf

# Strip options that WAF configure script does not recognize
CONFIGURE_ARGS:=$(filter-out	\
	--target=%			\
	--host=%			\
	--build=%			\
	--program-prefix=%	\
	--program-suffix=% 	\
	--disable-nls		\
	--disable-ipv6		\
	, $(CONFIGURE_ARGS))

HOST_CONFIGURE_ARGS:=$(filter-out	\
	--target=%			\
	--host=%			\
	--build=%			\
	--program-prefix=%	\
	--program-suffix=% 	\
	--disable-nls		\
	--disable-ipv6		\
	, $(HOST_CONFIGURE_ARGS))

# Waf needs the "configure" argument
CONFIGURE_ARGS:=configure $(CONFIGURE_ARGS)
HOST_CONFIGURE_ARGS:=configure $(HOST_CONFIGURE_ARGS)

CONFIGURE_ARGS += \
		--hostcc="$(HOSTCC)" \
		--cross-compile \
		--cross-answers=cross-answers.txt \
		--disable-cups \
		--disable-iprint \
		--disable-cephfs \
		--disable-fault-handling \
		--disable-glusterfs \
		--disable-rpath \
		--disable-rpath-install \
		--disable-rpath-private-install \
		--enable-fhs \
		--without-automount \
		--without-iconv \
		--without-lttng \
		--without-ntvfs-fileserver \
		--without-pam \
		--without-systemd \
		--without-utmp \
		--without-dmapi \
		--without-fam \
		--without-gettext \
		--without-regedit \
		--without-gpgme

HOST_CONFIGURE_ARGS += \
		--hostcc="$(HOSTCC)" \
		--disable-cups \
		--disable-iprint \
		--disable-cephfs \
		--disable-fault-handling \
		--disable-glusterfs \
		--disable-rpath \
		--disable-rpath-install \
		--disable-rpath-private-install \
		--enable-fhs \
		--without-automount \
		--without-iconv \
		--without-lttng \
		--without-ntvfs-fileserver \
		--without-pam \
		--without-systemd \
		--without-utmp \
		--without-dmapi \
		--without-fam \
		--without-gettext \
		--without-regedit \
		--without-gpgme

HOST_CONFIGURE_ARGS += --disable-avahi --without-quotas --without-acl-support --without-winbind \
	--without-ad-dc --without-json-audit --without-libarchive --disable-python --nopyc --nopyo \
	--disable-gnutls --without-dnsupdate --without-ads --without-ldap
HOST_CONFIGURE_VARS += python_LDFLAGS="" python_LIBDIR=""

# Optional AES-NI support - https://lists.samba.org/archive/samba-technical/2017-September/122738.html
# Support for Nettle wasn't comitted
ifdef CONFIG_TARGET_x86_64
	CONFIGURE_ARGS += --accel-aes=intelaesni
else
	CONFIGURE_ARGS += --accel-aes=none
endif

CONFIGURE_ARGS += \
		--with-lockdir=/var/lock \
		--with-logfilebase=/var/log \
		--with-piddir=/var/run \
		--with-privatedir=/etc/samba

ifeq ($(CONFIG_SAMBA4_SERVER_AVAHI),y)
	CONFIGURE_ARGS += --enable-avahi
else
	CONFIGURE_ARGS += --disable-avahi
endif
ifeq ($(CONFIG_SAMBA4_SERVER_QUOTAS),y)
	CONFIGURE_ARGS += --with-quotas
else
	CONFIGURE_ARGS += --without-quotas
endif
ifeq ($(CONFIG_SAMBA4_SERVER_ACL),y)
	CONFIGURE_ARGS += --with-acl-support
else
	CONFIGURE_ARGS += --without-acl-support
endif
# features
CONFIGURE_ARGS += --without-ad-dc --without-json-audit --without-libarchive --disable-python --nopyc --nopyo \
	--disable-gnutls --without-dnsupdate --without-ads --without-ldap
CONFIGURE_VARS += \
	python_LDFLAGS="" \
	python_LIBDIR=""

SAMBA4_PDB_MODULES :=pdb_smbpasswd,pdb_tdbsam,
SAMBA4_AUTH_MODULES :=auth_builtin,auth_sam,auth_unix,auth_script,
SAMBA4_VFS_MODULES :=vfs_default,
SAMBA4_VFS_MODULES_SHARED :=
ifeq ($(CONFIG_SAMBA4_SERVER_VFS),y)
	SAMBA4_VFS_MODULES_SHARED :=$(SAMBA4_VFS_MODULES_SHARED)vfs_fruit,vfs_shadow_copy2,vfs_recycle,vfs_fake_perms,vfs_readonly,vfs_cap,vfs_offline,vfs_crossrename,vfs_catia,vfs_streams_xattr,vfs_xattr_tdb,
ifeq ($(CONFIG_PACKAGE_kmod-fs-btrfs),y)
	SAMBA4_VFS_MODULES_SHARED :=$(SAMBA4_VFS_MODULES_SHARED)vfs_btrfs,
endif
endif
ifeq ($(CONFIG_SAMBA4_SERVER_VFSX),y)
	SAMBA4_VFS_MODULES_SHARED :=$(SAMBA4_VFS_MODULES_SHARED)vfs_virusfilter,vfs_shell_snap,vfs_commit,vfs_worm,vfs_aio_fork,vfs_aio_pthread,vfs_netatalk,vfs_dirsort,vfs_fileid,
ifeq ($(CONFIG_PACKAGE_kmod-fs-xfs),y)
	SAMBA4_VFS_MODULES_SHARED :=$(SAMBA4_VFS_MODULES_SHARED)vfs_linux_xfs_sgid,
endif
endif
ifeq ($(CONFIG_SAMBA4_SERVER_QUOTAS),y)
	SAMBA4_VFS_MODULES_SHARED :=$(SAMBA4_VFS_MODULES_SHARED)vfs_default_quota,
endif
ifeq ($(CONFIG_SAMBA4_SERVER_ACL),y)
	SAMBA4_VFS_MODULES :=$(SAMBA4_VFS_MODULES)vfs_posixacl,
	SAMBA4_VFS_MODULES_SHARED :=$(SAMBA4_VFS_MODULES_SHARED)vfs_acl_xattr,vfs_acl_tdb,
	# vfs_zfsacl needs https://github.com/zfsonlinux/zfs/tree/master/include/sys/zfs_acl.h
	# vfs_nfs4acl_xattr needs https://github.com/notriddle/libdrpc/blob/master/rpc/xdr.h
endif

SAMBA4_MODULES :=${SAMBA4_VFS_MODULES}${SAMBA4_AUTH_MODULES}${SAMBA4_PDB_MODULES}
SAMBA4_MODULES_SHARDED :=${SAMBA4_VFS_MODULES_SHARED}

CONFIGURE_ARGS += \
		--with-static-modules=$(SAMBA4_MODULES)!DEFAULT,!FORCED \
		--with-shared-modules=$(SAMBA4_MODULES_SHARDED)!DEFAULT,!FORCED

HOST_CONFIGURE_ARGS += \
		--with-static-modules=!DEFAULT,!FORCED \
		--with-shared-modules=!DEFAULT,!FORCED

# Setup build/install targets
# CONFIG_PACKAGE_samba4-server
BUILD_TARGETS_SERVER :=smbd/smbd,smbpasswd,pdbedit,testparm
# Optional server targets
ifeq ($(CONFIG_SAMBA4_SERVER_ACL),y)
	BUILD_TARGETS_SERVER :=$(BUILD_TARGETS_SERVER),sharesec
endif
ifeq ($(CONFIG_SAMBA4_SERVER_NETBIOS),y)
	BUILD_TARGETS_SERVER :=$(BUILD_TARGETS_SERVER),nmbd
endif
# CONFIG_PACKAGE_samba4-client
BUILD_TARGETS_CLIENT :=client/smbclient,client/cifsdd
# CONFIG_PACKAGE_samba4-admin
BUILD_TARGETS_ADMIN :=net,smbcontrol,profiles,rpcclient,smbcacls,smbcquotas,eventlogadm
# CONFIG_PACKAGE_samba4-utils
BUILD_TARGETS_UTILS :=smbstatus,smbtree,smbget,mvxattr,nmblookup

# lib bundling
# NOTE: bundle + make private, we want to avoid version configuration (build, link) conflicts
CONFIGURE_ARGS += --builtin-libraries=talloc,tevent,tevent-util,texpect,tdb,ldb,tdr,cmocka,com_err
HOST_CONFIGURE_ARGS += --builtin-libraries=replace --nonshared-binary=asn1_compile,compile_et
#CONFIGURE_ARGS += --bundled-libraries=talloc,tevent,tevent-util,texpect,tdb,ldb,tdr,cmocka,replace,!asn1_compile,!compile_et,!popt
CONFIGURE_ARGS += --bundled-libraries=talloc,tevent,tevent-util,texpect,tdb,ldb,tdr,cmocka,replace,com_err,roken,wind,hx509,asn1,heimbase,hcrypto,krb5,gssapi,heimntlm,hdb,kdc,NONE
# BUG: --private-libraries, Does not work for System possible libs, will not get "samba4" suffix!
CONFIGURE_ARGS += --private-libraries=talloc,tevent,tevent-util,texpect,tdb,ldb,tdr,cmocka,replace,com_err
# CONFIGURE_ARGS += --disable-symbol-versions

define Host/Compile
	(cd $(HOST_BUILD_DIR); \
		./buildtools/bin/waf build \
		--targets=asn1_compile,compile_et \
	)
endef

define Host/Install
	$(INSTALL_DIR) $(STAGING_DIR_HOSTPKG)/bin/
	# add host tools suffix, prevent conflicts with krb5
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/bin/asn1_compile $(STAGING_DIR_HOSTPKG)/bin/asn1_compile_samba
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/bin/compile_et $(STAGING_DIR_HOSTPKG)/bin/compile_et_samba
endef

define Build/Prepare
	$(Build/Prepare/Default)
	# un-bundle dnspython
	$(SED) '/"dns.resolver":/d' $(PKG_BUILD_DIR)/third_party/wscript
	# unbundle iso8601
	$(SED) '/"iso8601":/d' $(PKG_BUILD_DIR)/third_party/wscript
endef

define Build/Configure
	$(CP) ./waf-cross-answers/$(ARCH).txt $(PKG_BUILD_DIR)/cross-answers.txt
	echo 'Checking uname machine type: "$(ARCH)"' >> $(PKG_BUILD_DIR)/cross-answers.txt
	echo 'Checking uname release type: "$(LINUX_VERSION)"' >> $(PKG_BUILD_DIR)/cross-answers.txt
	echo 'Checking uname version type: "$(VERSION_DIST) Linux-$(LINUX_VERSION) $(shell date +%Y-%m-%d)"' >> $(PKG_BUILD_DIR)/cross-answers.txt
	# NOTE: For some unknown reason this answer is not needed on some hosts/distros, yet needed on others?
	echo 'Checking whether POSIX capabilities are available: OK' >> $(PKG_BUILD_DIR)/cross-answers.txt
	$(call Build/Configure/Default)
endef

# Note: We need to build via "waf install --targets=". Why do we also need to add the modules as targets here?
define Build/Compile
	(cd $(PKG_BUILD_DIR); \
		./buildtools/bin/waf install \
		--jobs=$(shell nproc) \
		--destdir="$(PKG_INSTALL_DIR)" \
		--targets=$(SAMBA4_MODULES)$(SAMBA4_MODULES_SHARDED)$(BUILD_TARGETS_SERVER),$(BUILD_TARGETS_UTILS),$(BUILD_TARGETS_ADMIN),$(BUILD_TARGETS_CLIENT) \
	)
endef

# No default install see above
define Build/Install
endef

define Package/samba4-libs/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/samba/*.so* $(1)/usr/lib/
	
	$(INSTALL_DIR) $(1)/usr/lib/samba/vfs $(1)/usr/lib/samba/ldb $(1)/usr/lib/samba/krb5
	if [ -d $(PKG_INSTALL_DIR)/usr/lib/samba/vfs ]; then \
		$(CP) $(PKG_INSTALL_DIR)/usr/lib/samba/vfs $(1)/usr/lib/samba/; \
	fi
	if [ -d $(PKG_INSTALL_DIR)/usr/lib/samba/krb5 ]; then \
		$(CP) $(PKG_INSTALL_DIR)/usr/lib/samba/krb5 $(1)/usr/lib/samba/; \
	fi
endef

define Package/samba4-client/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/{smbclient,cifsdd} $(1)/usr/bin/
endef

define Package/samba4-admin/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/{net,smbcontrol,profiles,rpcclient,smbcacls,smbcquotas} $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/eventlogadm $(1)/usr/sbin/
endef

define Package/samba4-utils/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/{smbstatus,smbtree,smbget,mvxattr,nmblookup} $(1)/usr/bin/
endef

define Package/samba4-server/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/{smbpasswd,pdbedit,testparm} $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/smbd $(1)/usr/sbin/
ifeq ($(CONFIG_SAMBA4_SERVER_NETBIOS),y)
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/nmbd $(1)/usr/sbin/
endif
ifeq ($(CONFIG_SAMBA4_SERVER_ACL),y)
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/sharesec $(1)/usr/bin/
endif
	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/samba $(1)/etc/init.d
	$(INSTALL_CONF) ./files/samba.config $(1)/etc/config/samba4
	$(INSTALL_DATA) ./files/smb.conf.template $(1)/etc/samba
	$(INSTALL_BIN) ./files/samba.init $(1)/etc/init.d/samba4
endef

define Package/samba4-server/conffiles
/etc/config/samba4
/etc/samba/smb.conf.template
/etc/samba/smb.conf
/etc/samba/smbpasswd
/etc/samba/secrets.tdb
/etc/samba/passdb.tdb
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,samba4-libs))
$(eval $(call BuildPackage,samba4-server))
$(eval $(call BuildPackage,samba4-client))
$(eval $(call BuildPackage,samba4-admin))
$(eval $(call BuildPackage,samba4-utils))
