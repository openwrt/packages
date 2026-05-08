include $(TOPDIR)/rules.mk

PKG_NAME:=zlog
PKG_VERSION:=1.2.18
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/HardySimpson/zlog
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_MIRROR_HASH:=947645c75a07cdf0228c6b8aed34d2e3e95ef0d6feaa524625b59f4711b066fc

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:zlog_project:zlog

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/zlog
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Pure C logging library
  URL:=http://hardysimpson.github.io/zlog/
endef

define Package/zlog/description
  zlog is a reliable, high-performance, thread safe, flexible, clear-model, pure C logging library.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/ $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/*.h $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libzlog.* $(1)/usr/lib/
endef

define Package/zlog/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libzlog.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,zlog))
