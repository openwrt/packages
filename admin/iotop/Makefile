include $(TOPDIR)/rules.mk

PKG_NAME:=iotop
PKG_VERSION:=1.27
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/Tomas-M/iotop/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=ca643a9d11fb398158decd2094dcf74c3e4625d06c54300073a69f1e92c721ea

PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID=cpe:/a:iotop:iotop

include $(INCLUDE_DIR)/package.mk

define Package/iotop
  SECTION:=admin
  CATEGORY:=Administration
  TITLE:=A top utility for IO
  DEPENDS:=+libncurses +@KERNEL_TASKSTATS
  URL:=https://github.com/Tomas-M/iotop
  PKG_MAINTAINER:=John Audia <therealgraysky@proton.me>
endef

define Package/iotop/description
  Iotop identifies processes that use high amount of input/output
  requests on your machine. It is similar to the well known top utility
  but instead of showing you what consumes CPU the most, it lists
  processes by their IO usage.
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)"
endef

define Package/iotop/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/iotop $(1)/usr/bin/
endef

$(eval $(call BuildPackage,iotop))
