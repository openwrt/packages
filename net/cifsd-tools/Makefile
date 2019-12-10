include $(TOPDIR)/rules.mk

PKG_NAME:=cifsd-tools
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/cifsd-team/cifsd-tools.git
PKG_SOURCE_DATE:=2019-12-17
PKG_SOURCE_VERSION:=f0f5979fd00d7097eddec7dae3027dff0a34935b
PKG_MIRROR_HASH:=afc67d94ca4c2e16d0774a1a25f3d94ccebbecd76bdd78521129181b724ef466

PKG_MAINTAINER:=Andy Walsh <andy.walsh44+github@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_REMOVE_FILES:=autogen.sh

PKG_BUILD_DEPENDS:=glib2

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/cifsd-tools/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Filesystem
  TITLE:=Kernel SMB/CIFS
  URL:=https://github.com/cifsd-team/cifsd-tools
  DEPENDS:= $(ICONV_DEPENDS) $(INTL_DEPENDS)
endef

define Package/cifsd-tools/Default/description
  Userspace tools for the SMB/CIFS kernel fileserver (cifsd.ko).
  The config file location is /etc/cifs/smb.conf
endef

define Package/cifsd-server
  $(call Package/cifsd-tools/Default)
  TITLE+= server
  DEPENDS+= +kmod-fs-cifsd +libnl-core +libnl-genl
endef

define Package/cifsd-server/description
  installs: cifsd

  This provides the basic fileserver service and is the minimum needed to serve 'guest only' file shares or use a existing cifsdpwd.db.
endef

define Package/cifsd-server/config
  select PACKAGE_wsdd2
endef

define Package/cifsd-utils
  $(call Package/cifsd-tools/Default)
  TITLE+= user management-util
endef

define Package/cifsd-utils/description
  installs: cifsuseradd (cifsshareadd)

  Tool needed to create the cifsdpwd.db, to manage per user share passwords.
  NOTE: Not needed for 'guest only' shares.
endef

define Package/cifsd-utils/config
	config CIFSD_UTILS_SHAREADD
		bool "Add cifsshareadd util"
		depends on PACKAGE_cifsd-utils
		help
			Add the cifsshareadd tool, to directly manipulate the /etc/cifs/smb.conf.
		default n
endef

CONFIGURE_ARGS += \
	--disable-shared \
	--enable-static

CONFIGURE_VARS += GLIB_LIBS="$(STAGING_DIR)/usr/lib/libglib-2.0.a"

TARGET_CFLAGS += -ffunction-sections -fdata-sections -flto
TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed -liconv $(if $(INTL_FULL),-lintl)

define Package/cifsd-server/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/cifsd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/cifs $(1)/etc/init.d
	$(INSTALL_CONF) ./files/cifsd.config $(1)/etc/config/cifsd
	$(INSTALL_DATA) ./files/smb.conf.template $(1)/etc/cifs/
	$(INSTALL_BIN) ./files/cifsd.init $(1)/etc/init.d/cifsd
	# copy examples until we have a wiki page
	$(INSTALL_DATA) ./files/cifsd.config.example $(1)/etc/cifs/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/Documentation/configuration.txt $(1)/etc/cifs/
endef

define Package/cifsd-utils/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/cifsuseradd $(1)/usr/sbin/
ifeq ($(CONFIG_CIFSD_UTILS_SHAREADD),y)
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/cifsshareadd $(1)/usr/sbin/
endif
endef

define Package/cifsd-server/conffiles
/etc/config/cifsd
/etc/cifs/smb.conf.template
/etc/cifs/smb.conf
/etc/cifs/cifsdpwd.db
endef

$(eval $(call BuildPackage,cifsd-server))
$(eval $(call BuildPackage,cifsd-utils))
