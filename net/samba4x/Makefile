#
# Copyright (C) 2007-2017 OpenWrt
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=samba4x
PKG_VERSION:=4.8.3
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/samba-team/samba.git
PKG_SOURCE_VERSION:=a62c2f3e97d3d779fe0d71162f61987da2645a85
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_MIRROR_HASH:=f6986babcdd70cd30d4ea77e25dcfc866582a18bc6740fd7e2ae4199acd0bc3f
PKG_LICENSE:=GPL-3.0

PKG_MAINTAINER:=Banglang Huang <banglang.huang@foxmail.com>
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
# for $(LINUX_VERSION)
include $(INCLUDE_DIR)/kernel.mk
# for $(VERSION_DIST)
include $(INCLUDE_DIR)/version.mk

define Package/samba4x/Default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Samba $(PKG_VERSION) SMB/CIFS
  URL:=http://www.samba.org/
endef

define Package/samba4x/Default/description
  The Samba software suite is a collection of programs that implements the
  SMB protocol for UNIX systems, allowing you to serve files and printers to
  Windows, NT, OS/2 and DOS clients. This protocol is sometimes also referred
  to as the LanManager or Netbios protocol.
endef

define Package/samba4x-common
  $(call Package/samba4x/Default)
  TITLE+= common libraries and configs
  DEPENDS:=+zlib +libpopt +libnettle \
	  +TARGET_x86:libgnutls +TARGET_x86:tdb \
	  +PACKAGE_libcap:libcap +PACKAGE_libtalloc:libtalloc \
	  +libtirpc +PACKAGE_jansson:jansson
  MENU:=1
endef

define Package/samba4x-common/config
source "$(SOURCE)/Config.in"
endef

define Package/samba4x-tool-server
  $(call Package/samba4x/Default)
  TITLE+= server
  DEPENDS:=+samba4x-common
endef

define Package/samba4x-tool-client
  $(call Package/samba4x/Default)
  TITLE+= client
  DEPENDS:=+samba4x-common
endef

define Package/samba4x-tool-net
  $(call Package/samba4x/Default)
  TITLE+= net
  DEPENDS:=+samba4x-common
endef


CONFIGURE_VARS += \
	CPP="$(TARGET_CROSS)cpp" \
	python_LDFLAGS="" \
	python_LIBDIR=""

CONFIGURE_CMD = ./buildtools/bin/waf

CONFIGURE_PREFIX = /usr

CONFIGURE_ARGS = \
		--target=$(GNU_TARGET_NAME) \
		--program-prefix="" \
		--prefix=$(CONFIGURE_PREFIX) \
		--exec-prefix=$(CONFIGURE_PREFIX) \
		--bindir=$(CONFIGURE_PREFIX)/bin \
		--sbindir=$(CONFIGURE_PREFIX)/sbin \
		--libexecdir=$(CONFIGURE_PREFIX)/lib \
		--sysconfdir=/etc \
		--datadir=$(CONFIGURE_PREFIX)/share \
		--localstatedir=/var \
		--mandir=$(CONFIGURE_PREFIX)/man \
		--infodir=$(CONFIGURE_PREFIX)/info

SAMBA_BUNDLED_LIBS = \
		$(if $(CONFIG_PACKAGE_libtalloc),!talloc)

ifndef CONFIG_SAMBA4X_AVAHI
  SAMBA4X_OPTIONS += --disable-avahi
endif
ifndef CONFIG_SAMBA4X_CEPHFS
  SAMBA4X_OPTIONS += --disable-cephfs
endif
ifndef CONFIG_SAMBA4X_CUPS
  SAMBA4X_OPTIONS += --disable-cups
endif
ifndef CONFIG_SAMBA4X_FAULT_HANDLING
  SAMBA4X_OPTIONS += --disable-fault-handling
endif
ifndef CONFIG_SAMBA4X_GLUSTERFS
  SAMBA4X_OPTIONS += --disable-glusterfs
endif
ifndef CONFIG_SAMBA4X_IPRINT
  SAMBA4X_OPTIONS += --disable-iprint
endif
ifndef CONFIG_SAMBA4X_PTHREADPOOL
  SAMBA4X_OPTIONS += --disable-pthreadpool
endif
ifndef CONFIG_SAMBA4X_PYTHON
  SAMBA4X_OPTIONS += --disable-python
endif
ifndef CONFIG_SAMBA4X_RPATH
  SAMBA4X_OPTIONS += --disable-rpath
endif
ifndef CONFIG_SAMBA4X_RPATH_INSTALL
  SAMBA4X_OPTIONS += --disable-rpath-install
endif
ifndef CONFIG_SAMBA4X_RPATH_PRIVATE_INSTALL
  SAMBA4X_OPTIONS += --disable-rpath-private-install
endif
ifndef CONFIG_SAMBA4X_ACL
  SAMBA4X_OPTIONS += --without-acl-support
endif
ifndef CONFIG_SAMBA4X_ADS
  SAMBA4X_OPTIONS += --without-ads
endif
ifndef CONFIG_SAMBA4X_AD_DC
  SAMBA4X_OPTIONS += --without-ad-dc
endif
ifndef CONFIG_SAMBA4X_AUTOMOUNT
  SAMBA4X_OPTIONS += --without-automount
endif
ifndef CONFIG_SAMBA4X_DMAPI
  SAMBA4X_OPTIONS += --without-dmapi
endif
ifndef CONFIG_SAMBA4X_DNSUPDATE
  SAMBA4X_OPTIONS += --without-dnsupdate
endif
ifndef CONFIG_SAMBA4X_FAM
  SAMBA4X_OPTIONS += --without-fam
endif
ifndef CONFIG_SAMBA4X_GPGME
  SAMBA4X_OPTIONS += --without-gpgme
endif
ifndef CONFIG_SAMBA4X_ICONV
  SAMBA4X_OPTIONS += --without-iconv
endif
ifndef CONFIG_SAMBA4X_LDAP
  SAMBA4X_OPTIONS += --without-ldap
endif
ifndef CONFIG_SAMBA4X_LIBARCHIVE
  SAMBA4X_OPTIONS += --without-libarchive
endif
ifndef CONFIG_SAMBA4X_LTTNG
  SAMBA4X_OPTIONS += --without-lttng
endif
ifndef CONFIG_SAMBA4X_PAM
  SAMBA4X_OPTIONS += --without-pam
endif
ifndef CONFIG_SAMBA4X_QUOTAS
  SAMBA4X_OPTIONS += --without-quotas
endif
ifndef CONFIG_SAMBA4X_REGEDIT
  SAMBA4X_OPTIONS += --without-regedit
endif
ifndef CONFIG_SAMBA4X_RELRO
  SAMBA4X_OPTIONS += --without-relro
endif
ifndef CONFIG_SAMBA4X_SYSTEMD
  SAMBA4X_OPTIONS += --without-systemd
endif
ifndef CONFIG_SAMBA4X_UTMP
  SAMBA4X_OPTIONS += --without-utmp
endif
ifndef CONFIG_SAMBA4X_WINBIND
  SAMBA4X_OPTIONS += --without-winbind
endif

CONFIGURE_ARGS += \
		--hostcc="$(shell which gcc)" \
		--bundled-libraries="$(SAMBA_BUNDLED_LIBS)" \
		--cross-compile \
		--cross-answers="$(PKG_BUILD_DIR)/cache.txt" \
		--accel-aes=none \
		--enable-fhs \
		--fatal-errors \
		--pedantic \
		--without-ntvfs-fileserver \
		$(SAMBA4X_OPTIONS) \
		--nopyc --nopyo

define Build/Configure
	$(CP) ./files/cache.txt $(PKG_BUILD_DIR)/cache.txt;
	echo -e "\nChecking uname sysname type: \"$(VERSION_DIST)\" \
	\nChecking uname release type: \"$(LINUX_VERSION)\" \
	\nChecking uname machine type: \"$(ARCH)\" \
	\nChecking uname version type: \"$(VERSION_DIST) Linux-$(LINUX_VERSION) $(shell date +%Y-%m-%d)\"\n" >> $(PKG_BUILD_DIR)/cache.txt;

	$(call Build/Configure/Default,configure)
endef

TARGET_CFLAGS += \
	-fdata-sections \
	-ffunction-sections

TARGET_LDFLAGS += \
	-Wl,--gc-sections

define Build/Compile
	(cd $(PKG_BUILD_DIR); \
		./buildtools/bin/waf build -vvv \
		--targets=smbd/smbd,nmbd,smbpasswd,smbclient,nmblookup,net \
		-j$(shell nproc))
endef

define Package/samba4x-common/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/samba/*.so* $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/samba/auth/*.so* $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/samba/idmap/*.so* $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/samba/ldb/*.so* $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/samba/nss_info/*.so* $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/samba/vfs/*.so* $(1)/usr/lib
endef

define Package/samba4x-tool-server/install
	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/samba $(1)/etc/init.d
	$(INSTALL_DATA) ./files/samba.config $(1)/etc/config/samba
	$(INSTALL_DATA) ./files/smb.conf.template $(1)/etc/samba
	$(INSTALL_BIN) ./files/samba.init $(1)/etc/init.d/samba
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/{smbd,nmbd} $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/smbpasswd $(1)/usr/bin
endef

define Package/samba4x-tool-client/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/smbclient $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/nmblookup $(1)/usr/bin
endef

define Package/samba4x-tool-net/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/net $(1)/usr/bin
endef

define Package/samba4x-tool-server/conffiles
/etc/config/samba
/etc/samba/smb.conf.template
/etc/samba/smbpasswd
endef

$(eval $(call BuildPackage,samba4x-common))
$(eval $(call BuildPackage,samba4x-tool-server))
$(eval $(call BuildPackage,samba4x-tool-client))
$(eval $(call BuildPackage,samba4x-tool-net))
