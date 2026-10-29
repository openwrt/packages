# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=speedketchup
PKG_VERSION:=0.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/gatispei/speedketchup/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=89a920838693a0f7c25441ac5b9c5d5d48dc58fbd84c5b9171fe0c3d6dd2edd0

PKG_MAINTAINER:=Gatis Peisenieks <peisenieks@gmail.com>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include ../../lang/rust/rust-package.mk

define Package/speedketchup
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Periodic internet speed test with a web page
  URL:=https://speedketchup.com
  DEPENDS:=$(RUST_ARCH_DEPENDS)
endef

define Package/speedketchup/description
  SpeedKetchup runs an internet speed test against the nearest
  speedtest.net server every few minutes, stores the results in a csv
  file and shows them with charts in its builtin web page.
endef

define Package/speedketchup/conffiles
/etc/config/speedketchup
endef

define Package/speedketchup/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/speedketchup $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/speedketchup.config $(1)/etc/config/speedketchup
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/speedketchup.init $(1)/etc/init.d/speedketchup
endef

$(eval $(call RustBinPackage,speedketchup))
$(eval $(call BuildPackage,speedketchup))
