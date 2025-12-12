include $(TOPDIR)/rules.mk

PKG_NAME:=beanstalkd
PKG_VERSION:=1.13
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/beanstalkd/$(PKG_NAME)/archive/refs/tags
PKG_SOURCE_VERSION:=1.13

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-v$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_URL_FILE:=v$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-v$(PKG_VERSION)
PKG_HASH:=26292dcdc0a7011d2f8ad968612f2cd8b2ef07687224876015399ae85e9e5263

PKG_MAINTAINER:=Philip Prindeville <philipp@redfish-solutions.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:wildbit:beanstalkd

include $(INCLUDE_DIR)/package.mk

define Package/beanstalkd
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Beanstalk
endef

define Package/beanstalkd/description
 Beanstalk is a simple, fast work queue.
endef

define Build/Configure
endef

define Build/Compile
	cd $(PKG_BUILD_DIR) && make CC="$(TARGET_CC)" CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" PREFIX=/usr OS=linux
endef

define Package/beanstalkd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/beanstalkd $(1)/usr/bin/beanstalkd

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/beanstalkd.init $(1)/etc/init.d/beanstalkd
endef

$(eval $(call BuildPackage,beanstalkd))
