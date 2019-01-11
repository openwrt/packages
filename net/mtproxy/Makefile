#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=MTProxy
PKG_VERSION:=1
PKG_RELEASE:=1
PKG_BUILD_PARALLEL:=1

PKG_SOURCE_URL:=https://codeload.github.com/TelegramMessenger/MTProxy/tar.gz/v$(PKG_VERSION)?
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=a1fc704519c84d9b3578c4063476775a54630a5fb007f745ac35ad8e4071d2ef
PKG_LICENSE:=GPL-2+
PKG_LICENSE_FILES:=GPLv2 LGPLv2

include $(INCLUDE_DIR)/package.mk

define Package/mtproxy
	SECTION:=net
	CATEGORY:=Network
	DEPENDS:=+libatomic +libopenssl +zlib
	TITLE:=Simple MT-Proto proxy
	URL:=https://github.com/TelegramMessenger/MTProxy
	MAINTAINER:=David Yang <mmyangfl@gmail.com>
endef

define Package/mtproxy/description
	Simple MT-Proto proxy
endef

MAKE_VARS += \
	COMMIT="$(PKG_VERSION)"

define Package/mtproxy/conffiles
	/etc/config/mtproxy
endef

define Package/mtproxy/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/objs/bin/mtproto-proxy $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/mtproxy.init $(1)/etc/init.d/mtproxy
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/mtproxy.config $(1)/etc/config/mtproxy
endef

$(eval $(call BuildPackage,mtproxy))
