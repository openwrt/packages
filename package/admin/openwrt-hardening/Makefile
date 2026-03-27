include $(TOPDIR)/rules.mk

PKG_NAME:=openwrt-hardening
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0-only
PKG_MAINTAINER:=Edwin ten Brink <git@tenbrink-bekkers.nl>
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/openwrt-hardening-base
  SECTION:=admin
  CATEGORY:=Administration
  TITLE:=Conservative sysctl hardening profile
  PKGARCH:=all
endef

define Package/openwrt-hardening-base/description
A conservative kernel/sysctl hardening profile for general OpenWrt systems.
This package installs a small /etc/sysctl.d snippet with low-risk hardening
settings intended for broad compatibility on routers and access points.
endef

define Package/openwrt-hardening-base/conffiles
/etc/sysctl.d/90-openwrt-hardening-base.conf
endef

define Package/openwrt-hardening-strict
  SECTION:=admin
  CATEGORY:=Administration
  TITLE:=Stricter sysctl hardening profile
  PKGARCH:=all
  DEPENDS:=+openwrt-hardening-base
endef

define Package/openwrt-hardening-strict/description
A stricter sysctl hardening profile for OpenWrt systems.
This package adds more restrictive kernel hardening settings on top of
openwrt-hardening-base, but avoids irreversible or high-breakage settings.
endef

define Package/openwrt-hardening-strict/conffiles
/etc/sysctl.d/95-openwrt-hardening-strict.conf
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/openwrt-hardening-base/install
	$(INSTALL_DIR) $(1)/etc/sysctl.d
	$(INSTALL_DATA) ./files/90-openwrt-hardening-base.conf \
		$(1)/etc/sysctl.d/90-openwrt-hardening-base.conf
	$(INSTALL_DIR) $(1)/usr/share/doc/openwrt-hardening
	$(INSTALL_DATA) ./files/README \
		$(1)/usr/share/doc/openwrt-hardening/README
endef

define Package/openwrt-hardening-strict/install
	$(INSTALL_DIR) $(1)/etc/sysctl.d
	$(INSTALL_DATA) ./files/95-openwrt-hardening-strict.conf \
		$(1)/etc/sysctl.d/95-openwrt-hardening-strict.conf
endef

$(eval $(call BuildPackage,openwrt-hardening-base))
$(eval $(call BuildPackage,openwrt-hardening-strict))
