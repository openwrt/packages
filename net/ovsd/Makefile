include $(TOPDIR)/rules.mk

PKG_NAME:=ovsd
PKG_SOURCE_DATE:=2020-12-08
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://gitlab.hhi.fraunhofer.de/wn-ina/ovsd
PKG_SOURCE_VERSION:=3a03476e2fececed3752ba4e68c92e71160c7db1
PKG_MIRROR_HASH:=8e67b1b5d99fa79f407f0a572861bc3963b7c77ecc8b1cf16c22fbecaa2e2763

PKG_MAINTAINER:=Arne Kappen <akappen@inet.tu-berlin.de>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/ovsd
  SECTION:=net
  SUBMENU:=Open vSwitch
  CATEGORY:=Network
  TITLE:=Open vSwtich configuration daemon for netifd
  URL:=https://gitlab.hhi.fraunhofer.de/wn-ina/ovsd
  DEPENDS:=+openvswitch +libubox +libubus +netifd
endef

define Package/ovsd/description
  External device handler adding Open vSwitch support to netifd.
endef

define Package/ovsd/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ovsd $(1)/sbin/
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,ovsd))
