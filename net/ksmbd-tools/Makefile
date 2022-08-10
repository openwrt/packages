include $(TOPDIR)/rules.mk

PKG_NAME:=ksmbd-tools
PKG_VERSION:=3.4.5
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/cifsd-team/ksmbd-tools/tar.gz/$(PKG_VERSION)?
PKG_HASH:=e22e5bef29ffa2670fc82c490ad4dc6eb00963b4f963dd1852c811b437c77ee1

PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_DEPENDS:=glib2

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/meson.mk

TAR_OPTIONS+= --strip-components 1
TAR_CMD=$(HOST_TAR) -C $(1) $(TAR_OPTIONS)

define Package/ksmbd-tools/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Filesystem
  TITLE:=Kernel SMB
  URL:=https://github.com/cifsd-team/ksmbd-tools
  DEPENDS:= $(ICONV_DEPENDS) $(INTL_DEPENDS)
endef

define Package/ksmbd-tools/Default/description
  Userspace tools to manage the SMB kernel fileserver (ksmbd.ko).
  The config file location is /etc/ksmbd/smb.conf
endef

define Package/ksmbd-server
  $(call Package/ksmbd-tools/Default)
  TITLE+= server
  DEPENDS+= +kmod-fs-ksmbd +libnl-core +libnl-genl
endef

define Package/ksmbd-server/description
  installs: ksmbd.mountd

  This provides the basic fileserver service and is the minimum needed to serve 'guest only' file shares or use a existing user database file ksmbdpwd.db.
endef

define Package/ksmbd-server/config
  select PACKAGE_wsdd2
endef

define Package/ksmbd-utils
  $(call Package/ksmbd-tools/Default)
  TITLE+= user management-util
endef

define Package/ksmbd-utils/description
  installs: ksmbd.adduser (ksmbd.addshare)

  Tool needed to create the ksmbdpwd.db, to manage per user share passwords.
  NOTE: Not needed for 'guest only' shares.
endef

define Package/ksmbd-utils/config
	config KSMBD_UTILS_SHAREADD
		bool "Add ksmbd.addshare util"
		depends on PACKAGE_ksmbd-utils
		help
			Add the ksmbd.addshare tool, to directly manipulate the /etc/ksmbd/smb.conf.
		default n
endef

define Package/ksmbd-avahi-service
  $(call Package/ksmbd-tools/Default)
  TITLE+= (Avahi service)
  DEPENDS:= +avahi-daemon
endef

define Package/ksmbd-avahi-service/description
  installs: smb.service

  This package contains the service definition for announcing the
  Ksmbd (smb/445) Daemon service via mDNS/DNS-SD.
endef

define Package/ksmbd-hotplug
  $(call Package/ksmbd-tools/Default)
  TITLE+= hotplug script for auto sharing
  DEPENDS:=+blockd
endef

MESON_ARGS += \
	-Db_lto=true \
	-Dkrb5=disabled

TARGET_CFLAGS += -ffunction-sections -fdata-sections
TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

define Package/ksmbd-server/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ksmbd.mountd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/ksmbd $(1)/etc/init.d
	$(INSTALL_CONF) ./files/ksmbd.config $(1)/etc/config/ksmbd
	$(INSTALL_DATA) ./files/smb.conf.template $(1)/etc/ksmbd/
	$(INSTALL_BIN) ./files/ksmbd.init $(1)/etc/init.d/ksmbd
	# copy examples until we have a wiki page
	$(INSTALL_DATA) ./files/ksmbd.config.example $(1)/etc/ksmbd/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/Documentation/configuration.txt $(1)/etc/ksmbd/
endef

define Package/ksmbd-utils/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ksmbd.adduser $(1)/usr/sbin/
ifeq ($(CONFIG_KSMBD_UTILS_SHAREADD),y)
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ksmbd.addshare $(1)/usr/sbin/
endif
endef

define Package/ksmbd-avahi-service/install
	$(INSTALL_DIR) $(1)/etc/avahi/services
	$(INSTALL_DATA) ./files/smb.service $(1)/etc/avahi/services/
endef

define Package/ksmbd-hotplug/install
	$(INSTALL_DIR) $(1)/etc/hotplug.d/mount
	$(INSTALL_CONF) ./files/ksmbd.hotplug $(1)/etc/hotplug.d/mount/60-ksmbd
endef

define Package/ksmbd-server/conffiles
/etc/config/ksmbd
/etc/ksmbd/smb.conf.template
/etc/ksmbd/smb.conf
/etc/ksmbd/ksmbdpwd.db
endef

define Package/ksmbd-avahi-service/conffiles
/etc/avahi/services/smb.service
endef

$(eval $(call BuildPackage,ksmbd-server))
$(eval $(call BuildPackage,ksmbd-utils))
$(eval $(call BuildPackage,ksmbd-avahi-service))
$(eval $(call BuildPackage,ksmbd-hotplug))
