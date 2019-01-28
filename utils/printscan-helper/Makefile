# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=printscan-helper
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Daniel Dickinson <cshored@thecshore.com>

include $(INCLUDE_DIR)/package.mk

define Package/printscan-helper
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=A helper for muxing printer/scanner combos
  ALTERNATIVES:=300:/usr/sbin/saned:/usr/sbin/saned-wrapper
endef

define Package/printscan-helper/description
  printscan-helper is a pair of small setuid root C programs and
  a wrapper around saned that unloads the usb lp driver before
  scanning and reloads the lp driver after scanning so that a
  multifunction printer/scanner can use a simple print sharing
  app such as p910nd and sane-daemon.  It is needed because
  the scanner drivers can't use the MFP/AIO USB device while
  the kernel usblp driver is attached but they don't know how
  to reattach the driver after scanning (or rather don't
  because on systems/devices attaching and reattching is
  problematic).
endef

define Build/Prepare
	$(INSTALL_DIR) $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Configure
	true
endef

define Package/printscan-helper/install
	$(INSTALL_DIR) $(1)/usr/sbin
	install -m4750 $(PKG_BUILD_DIR)/printscan-loadlp $(1)/usr/sbin/
	install -m4750 $(PKG_BUILD_DIR)/printscan-unloadlp $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/saned-wrapper $(1)/usr/sbin/saned-wrapper
endef

$(eval $(call BuildPackage,printscan-helper))
