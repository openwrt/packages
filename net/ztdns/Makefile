include $(TOPDIR)/rules.mk

PKG_NAME:=ztdns
PKG_VERSION:=0.0.2
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/palonsoro/ztdns.git
PKG_SOURCE_DATE:=2023-01-08
PKG_SOURCE_VERSION:=1510cb47083989549ce2ed53d01b56a79df69ad0
PKG_MIRROR_HASH:=deed1d16b8c3786147ec3acaf7a971b8d1f28766df2dc3172eafc95deba2361a

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Oskari Rauta <oskari.rauta@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/uxbh/ztdns

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/ztdns
  SECTION:=net
  CATEGORY:=Network
  TITLE:=ZerotierDNS
  URL:=https://github.com/uxbh/ztdns
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/ztdns/description
  ztDNS is a dedicated DNS server for a ZeroTier virtual network.
  It is alternative to Zerotier's own zeronsd.
endef

$(eval $(call GoBinPackage,ztdns))
$(eval $(call BuildPackage,ztdns))
