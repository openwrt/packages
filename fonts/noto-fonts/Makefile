include $(TOPDIR)/rules.mk

PKG_NAME:=noto-fonts
PKG_VERSION:=2026.11.01
PKG_RELEASE:=1

PKG_LICENSE:=OFL-1.1
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

include $(INCLUDE_DIR)/package.mk

NOTO_TAG:=noto-monthly-release-$(PKG_VERSION)
NOTO_URL:=https://raw.githubusercontent.com/notofonts/notofonts.github.io/$(NOTO_TAG)
NOTO_DIR:=/usr/share/fonts/noto

define Package/noto-fonts/Default
  SECTION:=fonts
  CATEGORY:=Fonts
  SUBMENU:=Noto
  URL:=https://notofonts.github.io/
  DEPENDS:=+noto-fonts-license
  PKGARCH:=all
endef

define NotoPackage
define Package/noto-fonts-$(1)
  $$(call Package/noto-fonts/Default)
  TITLE:=$$(NOTO_TITLE_$(1))
endef

define Package/noto-fonts-$(1)/description
  Noto font families: $$(NOTO_FAMILIES_$(1))
endef

define Package/noto-fonts-$(1)/install
	$$(INSTALL_DIR) $$(1)$$(NOTO_DIR)
	$$(foreach f,$$(NOTO_FILES_$(1)),$$(INSTALL_DATA) $$(DL_DIR)/noto-fonts-$$(PKG_VERSION)-$$(f) $$(1)$$(NOTO_DIR)/$$(f);)
endef

$$(eval $$(call BuildPackage,noto-fonts-$(1)))
endef

define NotoFile
NOTO_FILES_$(1)+=$(5)

define Download/noto-fonts-$(5)
  URL:=$$(NOTO_URL)/fonts/$(2)/googlefonts/$(3)/
  URL_FILE:=$(4)
  FILE:=noto-fonts-$$(PKG_VERSION)-$(5)
  HASH:=$(6)
  DOWNLOAD_RDEP:=$$(if $$(CONFIG_PACKAGE_noto-fonts-$(1)),$$(STAMP_PREPARED))
endef

$$(eval $$(call Download,noto-fonts-$(5)))
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) $(DL_DIR)/noto-fonts-$(PKG_VERSION)-LICENSE $(PKG_BUILD_DIR)/LICENSE
endef

define Build/Configure
endef

define Build/Compile
endef

include $(CURDIR)/noto-fonts.mk

$(foreach g,$(NOTO_GROUPS),$(eval $(call NotoPackage,$(g))))

define Download/noto-fonts-license
  URL:=$(NOTO_URL)/fonts/
  URL_FILE:=LICENSE
  FILE:=noto-fonts-$(PKG_VERSION)-LICENSE
  HASH:=$(NOTO_LICENSE_HASH)
  DOWNLOAD_RDEP:=$(STAMP_PREPARED)
endef
$(eval $(call Download,noto-fonts-license))

define Package/noto-fonts-license
  SECTION:=fonts
  CATEGORY:=Fonts
  SUBMENU:=Noto
  TITLE:=Noto fonts licence (SIL OFL 1.1)
  URL:=https://notofonts.github.io/
  PKGARCH:=all
endef

define Package/noto-fonts-license/description
  The SIL Open Font License 1.1 text that accompanies the Noto font
  packages. They depend on this package so that the text is installed
  once.
endef

define Package/noto-fonts-license/install
	$(INSTALL_DIR) $(1)/usr/share/licenses/noto-fonts
	$(INSTALL_DATA) $(DL_DIR)/noto-fonts-$(PKG_VERSION)-LICENSE $(1)/usr/share/licenses/noto-fonts/OFL.txt
endef

$(eval $(call BuildPackage,noto-fonts-license))
