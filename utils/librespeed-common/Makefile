#
# Copyright (C) 2026 Josef Schlehofer
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=librespeed-common
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/librespeed-common
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=LibreSpeed measurement orchestration
  DEPENDS:=+librespeed-cli +rpcd-mod-ucode +jsonfilter +ucode +ucode-mod-fs \
	+ucode-mod-uci +jshn
  PKGARCH:=all
endef

define Package/librespeed-common/description
  Runs LibreSpeed measurements from UCI configuration: a single entry point
  used both interactively and from cron, a schedule kept in step with UCI by
  the init script, and results recorded as JSON for anything that wants to
  read them, such as luci-app-librespeed, and a ubus interface for anything else.
endef

define Package/librespeed-common/conffiles
/etc/config/librespeed
endef

# rpcd only enumerates its plugin directory at startup, so the librespeed ubus
# object appears (and disappears) with a reload, not with the file.
define Package/librespeed-common/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || /etc/init.d/rpcd reload
exit 0
endef

define Package/librespeed-common/postrm
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || /etc/init.d/rpcd reload
exit 0
endef

# No source archive to unpack: the license text ships beside the Makefile and
# is staged so PKG_LICENSE_FILES points at a real file.
define Build/Prepare
	$(INSTALL_DATA) ./LICENSE $(PKG_BUILD_DIR)/
endef

define Build/Compile
endef

define Package/librespeed-common/install
	$(INSTALL_DIR) $(1)/usr/libexec
	$(INSTALL_BIN) ./files/librespeed-run $(1)/usr/libexec/librespeed-run
	$(INSTALL_BIN) ./files/librespeed-aggregate $(1)/usr/libexec/librespeed-aggregate
	$(SED) 's/%%VERSION%%/$(PKG_VERSION)-$(PKG_RELEASE)/g' \
		$(1)/usr/libexec/librespeed-run \
		$(1)/usr/libexec/librespeed-aggregate
	$(INSTALL_DIR) $(1)/usr/share/rpcd/ucode
	$(INSTALL_DATA) ./files/librespeed.uc $(1)/usr/share/rpcd/ucode/librespeed.uc
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/librespeed.config $(1)/etc/config/librespeed
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/librespeed.init $(1)/etc/init.d/librespeed
endef

$(eval $(call BuildPackage,librespeed-common))
