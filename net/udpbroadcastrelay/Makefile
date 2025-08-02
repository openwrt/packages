include $(TOPDIR)/rules.mk

PKG_NAME:=udpbroadcastrelay
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_MAINTAINER:= Tyler Young <git@yfh.addy.io>
PKG_LICENSE:=GPL-2.0

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/marjohn56/udpbroadcastrelay
PKG_SOURCE_DATE:=2025-01-22
PKG_SOURCE_VERSION:=8ebaa9b2690eb61a236184f6f6bf7eb773da4fd9
PKG_MIRROR_HASH:=4f60eda03496ec2b7068213b55c393e8324d5e1361f4fac0f3e8112d719d6fff

include $(INCLUDE_DIR)/package.mk

define Package/udpbroadcastrelay
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Routing and Redirection
	TITLE:=Listens for and replays packets from specific UDP broadcast ports
	URL:=https://github.com/marjohn56/udpbroadcastrelay
endef

define Package/udpbroadcastrelay/description
	This program listens for packets on a specified UDP broadcast port.
	When a packet is received, it sends that packet to all specified interfaces but
	the one it came from as though it originated from the original sender.
	The primary purpose of this is to allow devices or game servers on separated
	local networks (Ethernet, WLAN, VLAN) that use udp broadcasts to find each other to do so.
endef

define Package/udpbroadcastrelay/conffiles
	/etc/config/udpbroadcastrelay
endef

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) $(PKG_BUILD_DIR)/main.c -o $(PKG_BUILD_DIR)/$(PKG_NAME)
endef

define Package/udpbroadcastrelay/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/config $(1)/etc/init.d
	$(CP) $(PKG_BUILD_DIR)/$(PKG_NAME) $(1)/usr/sbin/
	$(INSTALL_CONF) ./files/udpbroadcastrelay.config $(1)/etc/config/udpbroadcastrelay
	$(INSTALL_BIN) ./files/udpbroadcastrelay.init $(1)/etc/init.d/udpbroadcastrelay
endef

$(eval $(call BuildPackage,udpbroadcastrelay))

