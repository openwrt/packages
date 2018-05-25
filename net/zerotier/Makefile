#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=zerotier
PKG_VERSION:=1.2.10
PKG_RELEASE:=1

PKG_LICENSE:=GPL-3.0

PKG_SOURCE_URL:=https://codeload.github.com/zerotier/ZeroTierOne/tar.gz/$(PKG_VERSION)?
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=1c79ec57e67764079a77704b336e642ae3cf221dc8088b0cf9e9c81e0a9c0c57
PKG_BUILD_DIR:=$(BUILD_DIR)/ZeroTierOne-$(PKG_VERSION)


PKG_BUILD_PARALLEL:=1
include $(INCLUDE_DIR)/package.mk

define Package/zerotier
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libpthread +libstdcpp +kmod-tun +ip +libminiupnpc +libnatpmp
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

ifeq ($(CONFIG_ZEROTIER_ENABLE_DEBUG),y)
MAKE_FLAGS += ZT_DEBUG=1
endif

MAKE_FLAGS += \
	DEFS="" \

define Build/Compile
	$(call Build/Compile/Default,one)
ifeq ($(CONFIG_ZEROTIER_ENABLE_SELFTEST),y)
	$(call Build/Compile/Default,selftest)
endif
endef

# Make binary smaller
TARGET_CFLAGS += -ffunction-sections -fdata-sections
TARGET_LDFLAGS += -Wl,--gc-sections

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

