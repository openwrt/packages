include $(TOPDIR)/rules.mk

PKG_NAME:=smbd-tools
PKG_VERSION:=3.0.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/cifsd-team/$(PKG_NAME)/archive/$(PKG_VERSION)/
PKG_HASH:=29f85de8b39608d28ec406c8b557264e004f5dce9b307a37f8324508cdea6217

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

define Package/smbd-tools/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Filesystem
  TITLE:=Kernel SMB
  URL:=https://github.com/cifsd-team/smbd-tools
  DEPENDS:= +glib2 $(ICONV_DEPENDS) $(INTL_DEPENDS)
endef

define Package/smbd-tools/Default/description
  Userspace tools for the SMB kernel fileserver (smbd.ko).
  The config file location is /etc/smbd/smb.conf
endef

define Package/smbd-server
  $(call Package/smbd-tools/Default)
  TITLE+= server
  DEPENDS+= +kmod-fs-smbd +libnl-core +libnl-genl
endef

define Package/smbd-server/description
  installs: usmbd

  This provides the basic fileserver service and is the minimum needed to serve 'guest only' file shares or use a existing smbdpwd.db.
endef

define Package/smbd-server/config
  select PACKAGE_wsdd2
endef

define Package/smbd-utils
  $(call Package/smbd-tools/Default)
  TITLE+= user management-util
endef

define Package/smbd-utils/description
  installs: smbuseradd (smbshareadd)

  Tool needed to create the smbdpwd.db, to manage per user share passwords.
  NOTE: Not needed for 'guest only' shares.
endef

define Package/smbd-utils/config
	config SMBD_UTILS_SHAREADD
		bool "Add smbshareadd util"
		depends on PACKAGE_smbd-utils
		help
			Add the smbshareadd tool, to directly manipulate the /etc/smbd/smb.conf.
		default n
endef

CONFIGURE_ARGS += \
	--disable-shared \
	--enable-static

# CONFIGURE_VARS += GLIB_LIBS="$(STAGING_DIR)/usr/lib/libglib-2.0.a"

TARGET_CFLAGS += -ffunction-sections -fdata-sections -flto
TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed -liconv $(if $(INTL_FULL),-lintl)

define Package/smbd-server/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/usmbd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/smbd $(1)/etc/init.d
	$(INSTALL_CONF) ./files/smbd.config $(1)/etc/config/smbd
	$(INSTALL_DATA) ./files/smb.conf.template $(1)/etc/smbd/
	$(INSTALL_BIN) ./files/smbd.init $(1)/etc/init.d/smbd
	# copy examples until we have a wiki page
	$(INSTALL_DATA) ./files/smbd.config.example $(1)/etc/smbd/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/Documentation/configuration.txt $(1)/etc/smbd/
endef

define Package/smbd-utils/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/smbuseradd $(1)/usr/sbin/
ifeq ($(CONFIG_SMBD_UTILS_SHAREADD),y)
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/smbshareadd $(1)/usr/sbin/
endif
endef

define Package/smbd-server/conffiles
/etc/config/smbd
/etc/smbd/smb.conf.template
/etc/smbd/smb.conf
/etc/smbd/smbdpwd.db
endef

$(eval $(call BuildPackage,smbd-server))
$(eval $(call BuildPackage,smbd-utils))
