#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=weechat
PKG_VERSION:=4.10.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://weechat.org/files/src/
PKG_HASH:=b8744c6f5dc5543062791f563e0516dbc96a36161e1a03c468b3b7dcc8be5aff

PKG_MAINTAINER:=Josef Schlehofer <pepe.schlehofer@gmail.com>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:weechat:weechat

PKG_CONFIG_DEPENDS:= \
	CONFIG_WEECHAT_ZSTD \
	CONFIG_WEECHAT_CJSON \
	CONFIG_WEECHAT_PYTHON \
	CONFIG_WEECHAT_LUA \
	CONFIG_WEECHAT_RUBY \
	CONFIG_WEECHAT_PERL \
	CONFIG_WEECHAT_TCL

PKG_BUILD_DEPENDS:=$(if $(CONFIG_WEECHAT_PYTHON),python3/host)
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk
include $(INCLUDE_DIR)/nls.mk

define Package/weechat/Default
  SUBMENU:=Instant Messaging
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Fast, light and extensible chat client
  URL:=https://weechat.org/
  DEPENDS:=+libgcrypt +libgnutls +libcurl +zlib $(ICONV_DEPENDS) $(INTL_DEPENDS) +ca-bundle \
	+WEECHAT_ZSTD:libzstd \
	+WEECHAT_CJSON:cJSON \
	+WEECHAT_PYTHON:python3-light \
	+WEECHAT_LUA:liblua \
	+WEECHAT_RUBY:ruby \
	+WEECHAT_PERL:perl \
	+WEECHAT_TCL:tcl
  USERID:=weechat:weechat
endef

define Package/weechat/Default/description
  WeeChat (Wee Enhanced Environment for Chat) is a fast, light and
  extensible chat client. It is multi-platform, supports IRC and
  has a plugin architecture with relay capabilities.
endef

define Package/weechat-minimal
  $(call Package/weechat/Default)
  TITLE+= (headless minimal)
  VARIANT:=minimal
  DEFAULT_VARIANT:=1
  PROVIDES:=weechat
endef

define Package/weechat-minimal/description
  $(call Package/weechat/Default/description)
  This package contains the minimal headless daemon (no ncurses dependency).
endef

define Package/weechat-full
  $(call Package/weechat/Default)
  TITLE+= (full with ncurses UI)
  DEPENDS+= +libncurses
  VARIANT:=full
  PROVIDES:=weechat
  CONFLICTS:=weechat-minimal
endef

define Package/weechat-full/description
  $(call Package/weechat/Default/description)
  This package contains both the full ncurses terminal client and the headless daemon.
endef

define Package/weechat/conffiles
/etc/config/weechat
/etc/weechat/
endef

Package/weechat-minimal/conffiles = $(Package/weechat/conffiles)
Package/weechat-full/conffiles = $(Package/weechat/conffiles)

define Package/weechat/config
	source "$(SOURCE)/Config.in"
endef

# One copy of the options is enough, they apply to both variants
Package/weechat-minimal/config = $(Package/weechat/config)

ifeq ($(BUILD_VARIANT),full)
CMAKE_OPTIONS += \
	-DENABLE_NCURSES=ON \
	-DENABLE_HEADLESS=ON
else
CMAKE_OPTIONS += \
	-DENABLE_NCURSES=OFF \
	-DENABLE_HEADLESS=ON
endif

weechat_has_scripts:=$(if $(CONFIG_WEECHAT_PERL)$(CONFIG_WEECHAT_PYTHON)$(CONFIG_WEECHAT_RUBY)$(CONFIG_WEECHAT_LUA)$(CONFIG_WEECHAT_TCL),ON,OFF)

CMAKE_OPTIONS += \
	-DENABLE_DOC=OFF \
	-DENABLE_MAN=OFF \
	-DENABLE_TESTS=OFF \
	-DENABLE_SCRIPTS=$(weechat_has_scripts) \
	-DENABLE_SCRIPT=$(weechat_has_scripts) \
	-DENABLE_PERL=$(if $(CONFIG_WEECHAT_PERL),ON,OFF) \
	-DENABLE_PYTHON=$(if $(CONFIG_WEECHAT_PYTHON),ON,OFF) \
	-DENABLE_RUBY=$(if $(CONFIG_WEECHAT_RUBY),ON,OFF) \
	-DENABLE_LUA=$(if $(CONFIG_WEECHAT_LUA),ON,OFF) \
	-DENABLE_TCL=$(if $(CONFIG_WEECHAT_TCL),ON,OFF) \
	-DENABLE_GUILE=OFF \
	-DENABLE_JAVASCRIPT=OFF \
	-DENABLE_PHP=OFF \
	-DENABLE_SPELL=OFF \
	-DENABLE_ZSTD=$(if $(CONFIG_WEECHAT_ZSTD),ON,OFF) \
	-DENABLE_CJSON=$(if $(CONFIG_WEECHAT_CJSON),ON,OFF) \
	-DENABLE_NLS=$(if $(CONFIG_BUILD_NLS),ON,OFF)

ifneq ($(CONFIG_WEECHAT_PYTHON),)
include ../../lang/python/python3-version.mk
CMAKE_OPTIONS += \
	-DPython_EXECUTABLE=$(STAGING_DIR_HOSTPKG)/bin/python3 \
	-DPython_INCLUDE_DIR=$(STAGING_DIR)/usr/include/python$(PYTHON3_VERSION) \
	-DPython_LIBRARY=$(STAGING_DIR)/usr/lib/libpython$(PYTHON3_VERSION).so
endif

define Package/weechat-minimal/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/weechat-headless $(1)/usr/bin/weechat-headless
	$(LN) weechat-headless $(1)/usr/bin/weechat
	$(INSTALL_DIR) $(1)/usr/lib/weechat/plugins
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/weechat/plugins/*.so $(1)/usr/lib/weechat/plugins/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/weechat.init $(1)/etc/init.d/weechat
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/weechat.config $(1)/etc/config/weechat
	$(INSTALL_DIR) $(1)/etc/weechat
endef

define Package/weechat-full/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/weechat $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/weechat-headless $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib/weechat/plugins
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/weechat/plugins/*.so $(1)/usr/lib/weechat/plugins/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/weechat.init $(1)/etc/init.d/weechat
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/weechat.config $(1)/etc/config/weechat
	$(INSTALL_DIR) $(1)/etc/weechat
endef

$(eval $(call BuildPackage,weechat-minimal))
$(eval $(call BuildPackage,weechat-full))
