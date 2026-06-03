include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-calllog
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

LUCI_TITLE:=LuCI JS call log viewer for modem
LUCI_DESCRIPTION:=Standalone call log viewer for modem devices. Displays incoming, missed and dialed calls collected by a background daemon with port configuration and daemon management.
LUCI_PKGARCH:=all
PKG_MAINTAINER:=devopenm <devopenm@proton.me>

define Package/luci-app-calllog/conffiles
/etc/config/sms_tool_js
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
