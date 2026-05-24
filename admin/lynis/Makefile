include $(TOPDIR)/rules.mk

PKG_NAME:=lynis
PKG_VERSION:=3.1.6
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://downloads.cisofy.com/lynis/
PKG_HASH:=0513f62ba5ab615c4333827b804237d58cf7bd623d09e1b4918d3fc85f08fc70

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

PKG_MAINTAINER:=John Audia <therealgraysky@proton.me>
PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/lynis
  SECTION:=admin
  CATEGORY:=Administration
  TITLE:=Security and system auditing tool
  URL:=https://cisofy.com/lynis/
  PKGARCH:=all
  DEPENDS:=+bind-dig +file +net-tools-netstat +net-tools-route
endef

define Package/lynis/description
  Lynis is a security auditing tool for Unix/Linux systems. It performs
  an in-depth security scan to detect software and security issues,
  installed packages, and possible configuration errors.
endef

define Package/lynis/conffiles
/etc/lynis/default.prf
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/lynis/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lynis $(1)/usr/bin/lynis

	$(INSTALL_DIR) $(1)/etc/lynis
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/default.prf $(1)/etc/lynis/default.prf

	$(INSTALL_DIR) $(1)/usr/share/lynis
	$(CP) $(PKG_BUILD_DIR)/db $(1)/usr/share/lynis/
	$(CP) $(PKG_BUILD_DIR)/include $(1)/usr/share/lynis/
	$(CP) $(PKG_BUILD_DIR)/plugins $(1)/usr/share/lynis/
endef

$(eval $(call BuildPackage,lynis))
