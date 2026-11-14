include $(TOPDIR)/rules.mk

PKG_NAME:=noto-fonts-cjk
PKG_RELEASE:=1

PKG_LICENSE:=OFL-1.1
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

include $(INCLUDE_DIR)/package.mk

NOTO_CJK_SANS_VER:=2.004
NOTO_CJK_SERIF_VER:=2.003
NOTO_CJK_URL:=https://raw.githubusercontent.com/notofonts/noto-cjk
NOTO_CJK_DIR:=/usr/share/fonts/noto

NOTO_CJK_SANS:=NotoSansCJK-VF.otf.ttc
NOTO_CJK_SANS_MONO:=NotoSansMonoCJK-VF.otf.ttc
NOTO_CJK_SERIF:=NotoSerifCJK-VF.otf.ttc
NOTO_CJK_LICENSE:=$(PKG_NAME)-$(NOTO_CJK_SANS_VER)-LICENSE

define Download/noto-cjk-sans
  URL:=$(NOTO_CJK_URL)/Sans$(NOTO_CJK_SANS_VER)/Sans/Variable/OTC/
  URL_FILE:=$(NOTO_CJK_SANS)
  FILE:=$(PKG_NAME)-$(NOTO_CJK_SANS_VER)-$(NOTO_CJK_SANS)
  HASH:=d3d8256cdec8dbcb3552284bc6b20c734dd60c2ee9df83b5758e34807c4bac32
  DOWNLOAD_RDEP:=$(if $(CONFIG_PACKAGE_noto-fonts-cjk-sans),$(STAMP_PREPARED))
endef
$(eval $(call Download,noto-cjk-sans))

define Download/noto-cjk-sans-mono
  URL:=$(NOTO_CJK_URL)/Sans$(NOTO_CJK_SANS_VER)/Sans/Variable/OTC/
  URL_FILE:=$(NOTO_CJK_SANS_MONO)
  FILE:=$(PKG_NAME)-$(NOTO_CJK_SANS_VER)-$(NOTO_CJK_SANS_MONO)
  HASH:=3a73c225abcfd5742ab84e613b427fb5b40c9e59b70fe3d1683f9b1da96568a0
  DOWNLOAD_RDEP:=$(if $(CONFIG_PACKAGE_noto-fonts-cjk-sans-mono),$(STAMP_PREPARED))
endef
$(eval $(call Download,noto-cjk-sans-mono))

define Download/noto-cjk-serif
  URL:=$(NOTO_CJK_URL)/Serif$(NOTO_CJK_SERIF_VER)/Serif/Variable/OTC/
  URL_FILE:=$(NOTO_CJK_SERIF)
  FILE:=$(PKG_NAME)-$(NOTO_CJK_SERIF_VER)-$(NOTO_CJK_SERIF)
  HASH:=24720ea76c8b13e822059d155cefb0f9f6be1cfdee1e2bb67b61c96067de42c9
  DOWNLOAD_RDEP:=$(if $(CONFIG_PACKAGE_noto-fonts-cjk-serif),$(STAMP_PREPARED))
endef
$(eval $(call Download,noto-cjk-serif))

define Download/noto-cjk-license
  URL:=$(NOTO_CJK_URL)/Sans$(NOTO_CJK_SANS_VER)/
  URL_FILE:=LICENSE
  FILE:=$(NOTO_CJK_LICENSE)
  HASH:=6a73f9541c2de74158c0e7cf6b0a58ef774f5a780bf191f2d7ec9cc53efe2bf2
  DOWNLOAD_RDEP:=$(STAMP_PREPARED)
endef
$(eval $(call Download,noto-cjk-license))

define Package/noto-fonts-cjk/Default
  SECTION:=fonts
  CATEGORY:=Fonts
  SUBMENU:=Noto
  URL:=https://github.com/notofonts/noto-cjk
  DEPENDS:=+noto-fonts-license
  PKGARCH:=all
endef

define Package/noto-fonts-cjk-sans
$(call Package/noto-fonts-cjk/Default)
  TITLE:=Noto Sans CJK (variable, JP KR SC TC HK)
  VERSION:=$(NOTO_CJK_SANS_VER)-r$(PKG_RELEASE)
endef

define Package/noto-fonts-cjk-sans-mono
$(call Package/noto-fonts-cjk/Default)
  TITLE:=Noto Sans Mono CJK (variable, JP KR SC TC HK)
  VERSION:=$(NOTO_CJK_SANS_VER)-r$(PKG_RELEASE)
endef

define Package/noto-fonts-cjk-serif
$(call Package/noto-fonts-cjk/Default)
  TITLE:=Noto Serif CJK (variable, JP KR SC TC HK)
  VERSION:=$(NOTO_CJK_SERIF_VER)-r$(PKG_RELEASE)
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) $(DL_DIR)/$(NOTO_CJK_LICENSE) $(PKG_BUILD_DIR)/LICENSE
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/noto-fonts-cjk-sans/install
	$(INSTALL_DIR) $(1)$(NOTO_CJK_DIR)
	$(INSTALL_DATA) $(DL_DIR)/$(PKG_NAME)-$(NOTO_CJK_SANS_VER)-$(NOTO_CJK_SANS) $(1)$(NOTO_CJK_DIR)/$(NOTO_CJK_SANS)
endef

define Package/noto-fonts-cjk-sans-mono/install
	$(INSTALL_DIR) $(1)$(NOTO_CJK_DIR)
	$(INSTALL_DATA) $(DL_DIR)/$(PKG_NAME)-$(NOTO_CJK_SANS_VER)-$(NOTO_CJK_SANS_MONO) $(1)$(NOTO_CJK_DIR)/$(NOTO_CJK_SANS_MONO)
endef

define Package/noto-fonts-cjk-serif/install
	$(INSTALL_DIR) $(1)$(NOTO_CJK_DIR)
	$(INSTALL_DATA) $(DL_DIR)/$(PKG_NAME)-$(NOTO_CJK_SERIF_VER)-$(NOTO_CJK_SERIF) $(1)$(NOTO_CJK_DIR)/$(NOTO_CJK_SERIF)
endef

$(eval $(call BuildPackage,noto-fonts-cjk-sans))
$(eval $(call BuildPackage,noto-fonts-cjk-sans-mono))
$(eval $(call BuildPackage,noto-fonts-cjk-serif))
