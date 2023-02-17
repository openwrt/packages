include $(TOPDIR)/rules.mk

PKG_NAME:=cni-protocol
PKG_VERSION:=20230217
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
  protocol support for cni networks for netifd
  makes defining network for podman and other similar
  systems using cni networking much easier and simpler.

  with cni protocol support, on a network, where firewall
  and portmapper management is disabled, you may control
  firewalling with openwrt's default firewall configuration.

  for example, create a container that hosts web content on
  port 80 with static ip on your cni network, if your
  network is 10.88.0.0/16, use for eg. 10.88.0.101 as
  your containers static ip address. Create a zone, cni
  to your firewall and add your interface to it.

  Now you can easily set up redirectiong to 10.88.0.101:80
  to expose it's port 80 to wan for serving your website.

  Protocol has one setting: device, on podman this often
  is cni-podman0.
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
