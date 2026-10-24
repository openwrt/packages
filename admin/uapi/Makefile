include $(TOPDIR)/rules.mk

PKG_NAME:=uapi
PKG_VERSION:=3.1.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/openwrt-iac/uapi/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=29ead0ce021d1667d0fe6c5c7249aa7b7bdb5c2896505607b9055fc89110be94

PKG_MAINTAINER:=Guy Godfroy <guy.godfroy@gugod.fr>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/uapi
  SECTION:=admin
  CATEGORY:=Administration
  TITLE:=HTTP REST API for uci and ubus
  URL:=https://github.com/openwrt-iac/uapi
  PKGARCH:=all
  DEPENDS:=+rpcd-mod-iwinfo +ucode +ucode-mod-digest +ucode-mod-fs +ucode-mod-log \
    +ucode-mod-ubus +ucode-mod-uci +uhttpd +uhttpd-mod-ucode
endef

define Package/uapi/description
  uapi translates HTTP REST verbs into ubus and uci operations, as a
  backend for Infrastructure-as-Code tools such as Terraform. It runs
  inside uhttpd as a ucode handler, with no daemon of its own, and
  serves curated endpoints under /api/v3/ plus a raw uci passthrough.
  Each write stages, commits and reloads in one transaction.
endef

define Package/uapi/conffiles
/etc/config/uapi
endef

Build/Compile=

define Package/uapi/install
	$(INSTALL_DIR) $(1)/usr/share/uapi/lib $(1)/usr/share/uapi/resources
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/main.uc $(PKG_BUILD_DIR)/src/raw.uc \
		$(PKG_BUILD_DIR)/build/openapi.json $(PKG_BUILD_DIR)/VERSION \
		$(1)/usr/share/uapi/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/lib/*.uc $(1)/usr/share/uapi/lib/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/resources/*.uc $(1)/usr/share/uapi/resources/

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cli/uapi-token $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/uci-defaults
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/files/etc/config/uapi $(1)/etc/config/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/etc/uci-defaults/99-uapi $(1)/etc/uci-defaults/
endef

define Package/uapi/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] && exit 0
# uhttpd-mod-ucode compiles the handler once, at startup. A reload keeps
# serving the code of the previous version. A restart would also start a
# uhttpd that the operator disabled.
/etc/init.d/uhttpd enabled && /etc/init.d/uhttpd restart >/dev/null 2>&1 || true
exit 0
endef

define Package/uapi/prerm
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] && exit 0
for prefix in $$(uci -q get uhttpd.main.ucode_prefix); do
	case "$$prefix" in
	*=/usr/share/uapi/main.uc)
		uci -q del_list uhttpd.main.ucode_prefix="$$prefix"
		;;
	esac
done
uci -q commit uhttpd
/etc/init.d/uhttpd enabled && /etc/init.d/uhttpd reload >/dev/null 2>&1 || true
exit 0
endef

$(eval $(call BuildPackage,uapi))
