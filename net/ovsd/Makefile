include $(TOPDIR)/rules.mk

PKG_NAME:=ovsd
PKG_VERSION:=2020-10-12
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://gitlab.hhi.fraunhofer.de/wn-ina/ovsd.git
PKG_SOURCE_VERSION:=e6a07f27dd8a5893eb6110c69922077995b9b26a
PKG_MIRROR_HASH:=9d903b3fecd8a3e102e1477efe479fc3851b1814ea0852e1dae39065b88cd157

PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz

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
  MAINTAINER:=Arne Kappen <akappen@inet.tu-berlin.de>
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
