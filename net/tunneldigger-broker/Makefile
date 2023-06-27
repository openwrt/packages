include $(TOPDIR)/rules.mk

PKG_NAME:=tunneldigger-broker
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/wlanslovenija/tunneldigger.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=4f72b30578ac3dbc5482f4a54054bf870355bdf5
PKG_MIRROR_HASH:=e93b986b60475c16b0022ba4f5da981929cc3d6992c632f41264804912825473

PKG_MAINTAINER:=Nick Hainke <vincent@systemli.org>
PKG_LICENSE:=AGPL-3.0
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_DEPENDS:=python-cffi/host

include ../../lang/python/pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python3-package.mk

define Package/tunneldigger-broker
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:= \
	+ip-full \
	+kmod-l2tp \
	+kmod-l2tp-ip \
	+kmod-l2tp-eth \
	+kmod-sched \
	+libnetfilter-conntrack \
	+libnfnetlink \
	+libnl-tiny \
	+libpthread \
	+librt \
	+python3-cffi \
	+python3-ctypes \
	+python3-light \
	+python3-logging \
	+python3-six \
	+tc-full
  TITLE:=Broker for L2TPv3 tunnels using tunneldigger
  URL:=https://github.com/wlanslovenija/tunneldigger
endef

define Package/tunneldigger-broker/description
Tunneldigger is a simple VPN tunneling solution based on the Linux kernel
support for L2TPv3 tunnels over UDP. This package contains the broker.
endef

PYTHON3_PKG_SETUP_DIR:=broker
PYTHON3_PKG_WHEEL_VERSION:=0.4.0.dev1

define Py3Package/tunneldigger-broker/install
	$(INSTALL_DIR) $(1)/lib/functions
	$(INSTALL_DATA) ./files/tunneldigger.sh $(1)/lib/functions/tunneldigger.sh
	$(INSTALL_DIR) $(1)/usr/lib/tunneldigger-broker/hooks
	$(INSTALL_BIN) ./files/hook-setup $(1)/usr/lib/tunneldigger-broker/hooks/setup
	$(INSTALL_BIN) ./files/hook-teardown $(1)/usr/lib/tunneldigger-broker/hooks/teardown
	$(INSTALL_BIN) ./files/hook-mtu-changed $(1)/usr/lib/tunneldigger-broker/hooks/mtu-changed
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/tunneldigger-broker.init $(1)/etc/init.d/tunneldigger-broker
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/config.default $(1)/etc/config/tunneldigger-broker
endef

define Package/tunneldigger-broker/conffiles
/etc/config/tunneldigger-broker
endef

$(eval $(call Py3Package,tunneldigger-broker))
$(eval $(call BuildPackage,tunneldigger-broker))
$(eval $(call BuildPackage,tunneldigger-broker-src))
