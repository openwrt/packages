include $(TOPDIR)/rules.mk

PKG_NAME:=corosync-qdevice
PKG_VERSION:=3.0.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/corosync/corosync-qdevice/releases/download/v$(PKG_VERSION)/
PKG_HASH:=c2821329ed1efd6bf8f82e2878f75ca66889439d27c788785fd0ccc972ac307c

PKG_MAINTAINER:=Christian Sandberg <chrsandb@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_BUILD_DEPENDS:=nss

include $(INCLUDE_DIR)/package.mk

CONFIGURE_VARS += \
	ac_cv_path_BASHPATH=/bin/bash \
	ac_cv_prog_GROFF=

CONFIGURE_ARGS += \
	--disable-qdevices \
	--enable-qnetd \
	--enable-install-qnetd-in-sbin \
	--disable-systemd \
	--sysconfdir=/etc

define Package/corosync-qnetd
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Corosync QDevice network daemon
  URL:=https://github.com/corosync/corosync-qdevice
  DEPENDS:=+bash +libnss +nspr +nss-utils
  USERID:=coroqnetd:coroqnetd
endef

define Package/corosync-qnetd/description
  Corosync QNet daemon providing an external vote to Corosync clusters.
  Multiple clusters can use one QNet daemon as their external quorum server.
endef

define Package/corosync-qnetd/conffiles
/etc/config/corosync-qnetd
/etc/corosync/qnetd/
endef

define Package/corosync-qnetd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/corosync-qnetd $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/corosync-qnetd-tool $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/corosync-qnetd-certutil $(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/etc/corosync/qnetd
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/corosync-qnetd.config $(1)/etc/config/corosync-qnetd
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/corosync-qnetd.init $(1)/etc/init.d/corosync-qnetd
	$(INSTALL_DIR) $(1)/usr/libexec
	$(INSTALL_BIN) ./files/corosync-qnetd-maintenance $(1)/usr/libexec/
endef

$(eval $(call BuildPackage,corosync-qnetd))
