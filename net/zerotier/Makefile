#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=zerotier
PKG_VERSION:=1.2.2
PKG_RELEASE:=4

PKG_LICENSE:=GPL-3.0

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/zerotier/ZeroTierOne
PKG_SOURCE_SUBDIR:=ZeroTierOne-$(PKG_VERSION)
PKG_SOURCE_VERSION:=cfe0d0971f3ce5972d955250dc1ff6ec7a30e3f7
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_MIRROR_MD5SUM:=c8c3219c995a59161832d580a194f6280de7a4eef75cebece6f38400b64f003e
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)

PKG_BUILD_PARALLEL:=1
include $(INCLUDE_DIR)/package.mk

define Package/zerotier
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libpthread +kmod-tun +ip +libstdcpp +ZEROTIER_ENABLE_PORTMAPPING:libminiupnpc +ZEROTIER_ENABLE_PORTMAPPING:libnatpmp
  TITLE:=Create flat virtual Ethernet networks of almost unlimited size
  URL:=https://www.zerotier.com
  SUBMENU:=VPN
  MAINTAINER:=Moritz Warning <moritzwarning@web.de>
endef

define Package/zerotier/description
	ZeroTier creates a global provider-independent virtual private cloud network.
endef

define Package/zerotier/config
	source "$(SOURCE)/Config.in"
endef

ifeq ($(CONFIG_ZEROTIER_ENABLE_CLUSTER),y)
MAKE_FLAGS += ZT_ENABLE_CLUSTER=1
endif

ifeq ($(CONFIG_ZEROTIER_ENABLE_PORTMAPPING),y)
MAKE_FLAGS += ZT_ENABLE_PORTMAPPING=1
endif

ifeq ($(CONFIG_ZEROTIER_ENABLE_DEBUG),y)
TARGET_CXXFLAGS += -DZT_TRACE -ggdb3
endif

define Build/Compile
	$(call Build/Compile/Default,one)
ifeq ($(CONFIG_ZEROTIER_ENABLE_SELFTEST),y)
	$(call Build/Compile/Default,selftest)
endif
endef

define Package/zerotier/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/zerotier-one $(1)/usr/bin/
	$(LN) zerotier-one $(1)/usr/bin/zerotier-cli
	$(LN) zerotier-one $(1)/usr/bin/zerotier-idtool

ifeq ($(CONFIG_ZEROTIER_ENABLE_SELFTEST),y)
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/zerotier-selftest $(1)/usr/bin/
endif

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) files/zerotier.init $(1)/etc/init.d/zerotier
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) files/zerotier.config $(1)/etc/config/zerotier
endef

$(eval $(call BuildPackage,zerotier))

