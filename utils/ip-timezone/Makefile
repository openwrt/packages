include $(TOPDIR)/rules.mk

PKG_NAME:=ip-timezone
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_MAINTAINER:=Renn Akaza <openwrt.org-ip-timezone@akaza.ren>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/ip-timezone
	SECTION:=utils
	CATEGORY:=Utilities
	TITLE:=Auto set timezone by IP
	PKGARCH:=all
	DEPENDS:=+zoneinfo-all
endef

define Package/ip-timezone/description
Hotplug script to ipmatically configure the timezone UCI settings based on the IP address.

The user needs to set their own endpoint to get the IANA timezone string, e.g.:
	uci set ip-timezone.config.endpoint="https://domain.tld/timezone"
	uci commit ip-timezone

The endpoint is expected to respond GET requests by a plaintext one-line IANA timezone string, e.g. "Europe/London".
The endpoint can be verified by directly accessing the its URL from a browser by the address bar.
endef

define Build/Compile
endef

define Package/collectd/conffiles
/etc/config/ip-timezone
endef

define Package/ip-timezone/install
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface/
	$(INSTALL_DATA) ./files/99-ip-timezone $(1)/etc/hotplug.d/iface/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/ip-timezone.config $(1)/etc/config/ip-timezone
endef

$(eval $(call BuildPackage,ip-timezone))
