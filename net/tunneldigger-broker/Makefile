include $(TOPDIR)/rules.mk

PKG_NAME:=tunneldigger-broker
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/wlanslovenija/tunneldigger.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=v0.4.0
PKG_MIRROR_HASH:=c67a0e626cec571823085a7a28bc72fcaa077669cac52c441b0dde02d676e16c

PKG_MAINTAINER:=Nick Hainke <vincent@systemli.org>
PKG_LICENSE:=AGPL-3.0
PKG_LICENSE_FILES:=COPYING

include ../../lang/python/pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python3-package.mk

define Package/tunneldigger-broker
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:= \
	+ip \
	+kmod-l2tp \
	+kmod-l2tp-eth \
	+kmod-sched \
	+libnfnetlink \
	+libnl-tiny \
	+libpthread \
	+librt \
	+python3-ctypes \
	+python3-light \
	+python3-logging \
	+tc-tiny
  TITLE:=Broker for L2TPv3 tunnels using tunneldigger
  URL:=https://github.com/wlanslovenija/tunneldigger
endef

define Package/tunneldigger-broker/description
Tunneldigger is a simple VPN tunneling solution based on the Linux kernel
support for L2TPv3 tunnels over UDP. This package contains the broker.
endef

PYTHON3_PKG_SETUP_DIR:=broker
PYTHON3_PKG_WHEEL_VERSION:=0.4.0

define Py3Package/tunneldigger-broker/install
	$(INSTALL_DIR) $(1)/lib/functions
	$(INSTALL_DATA) ./files/tunneldigger.sh $(1)/lib/functions/tunneldigger.sh
	$(INSTALL_DIR) $(1)/usr/lib/tunneldigger-broker/hooks
	$(INSTALL_BIN) ./files/hook-setup $(1)/usr/lib/tunneldigger-broker/hooks/setup
	$(INSTALL_BIN) ./files/hook-teardown $(1)/usr/lib/tunneldigger-broker/hooks/teardown
	$(INSTALL_BIN) ./files/hook-mtu-changed $(1)/usr/lib/tunneldigger-broker/hooks/mtu-changed
	$(INSTALL_BIN) ./files/hook-connection-rate-limit $(1)/usr/lib/tunneldigger-broker/hooks/connection-rate-limit
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
