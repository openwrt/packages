include $(TOPDIR)/rules.mk

PKG_NAME:=mdk4
PKG_LICENSE:=GPL-3.0-or-later

PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/aircrack-ng/mdk4
PKG_SOURCE_DATE:=2021-07-07
PKG_SOURCE_VERSION:=683e074f081624418f50090641a09db53ce0378d
PKG_MIRROR_HASH:=f4fa0abb8c3b2191d70b2cbf7a52d807fbce20eaed29908e24588141872225ef

include $(INCLUDE_DIR)/package.mk

EXTRA_CFLAGS=$(TARGET_CPPFLAGS)

define Package/mdk4
    SECTION:=net
    CATEGORY:=Network
    TITLE:=mdk4
    MAINTAINER:=Markus Koetter <commonism@users.noreply.github.com>
    DEPENDS:= +libnl +libpcap
    URL:=https://github.com/aircrack-ng/mdk4
    SUBMENU:=Wireless
endef


define Package/mdk4/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/mdk4 $(1)/usr/bin/mdk4
endef


$(eval $(call BuildPackage,mdk4))
