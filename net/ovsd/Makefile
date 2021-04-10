include $(TOPDIR)/rules.mk

PKG_NAME:=ovsd
PKG_VERSION:=2020-10-12
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://gitlab.hhi.fraunhofer.de/wn-ina/ovsd
PKG_SOURCE_DATE:=2020-12-08
PKG_SOURCE_VERSION:=3a03476e2fececed3752ba4e68c92e71160c7db1
PKG_MIRROR_HASH:=7c6895b8aef8b3997ec86c2225792a443be9870985de7b7c01397cd97a6c7a25

PKG_MAINTAINER:=Arne Kappen <akappen@inet.tu-berlin.de>
PKG_LICENSE:=GPL-2.0

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/ovsd
  SECTION:=net
  SUBMENU:=Open vSwitch
  CATEGORY:=Network
  DEPENDS:=+openvswitch +libubox +libubus +netifd
  TITLE:=Open vSwtich configuration daemon for netifd
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
