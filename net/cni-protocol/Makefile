include $(TOPDIR)/rules.mk

PKG_NAME:=cni-protocol
PKG_VERSION:=20231008
PKG_RELEASE:=1

PKG_MAINTAINER:=Oskari Rauta <oskari.rauta@gmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/cni-protocol
  SECTION:=net
  CATEGORY:=Network
  TITLE:=cni netifd protocol
  PKGARCH:=all
endef

define Package/cni-protocol/description
  protocol support for netavark/cni networks for netifd
  makes defining networks for podman and other similar
  systems easier and simple.

  with protocol, a network where firewall and portmapper
  management is disabled, control of firewalling, whether
  it was exposing ports, and forwarding to them from wan,
  or limiting/accepting access to other networks such
  as lan can made through openwrt's own firewalling
  configuration.

  example configuration could be as following:
    - lan network: 10.0.0.0/16 (255.255.0.0)
    - container network: 10.129.0.1/24 (255.255.255.0)

  Add a network configuration for your container network
  using cni protocol. Then create firewall zone for it.

  You could create a new container/pod with static ip
  address 10.129.0.2 (as 10.129.0.1 as container network's
  gateway).

  Easily define permissions so that local networks can
  connect to cni network, but not the other way around.
  Also you want to allow forwarding from/to wan.

  Now, as cni cannot access local dns, make a rule for
  your firewall to accept connections from cni network
  to port 53 (dns).

  Now all you have to do, is make redirects to your firewall
  and point them to 10.129.0.2 and connections from wan are
  redirectered to containers/pods.

  Protocol has 2 settings: device and delay. Sometimes polling
  interfaces takes some time, and in that case you might want
  to add few seconds to delay. Otherwise, it can be excluded
  from configuration.
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/cni-protocol/install
	$(INSTALL_DIR) $(1)/lib/netifd/proto
	$(INSTALL_BIN) ./files/cni.sh $(1)/lib/netifd/proto/cni.sh
endef

$(eval $(call BuildPackage,cni-protocol))
