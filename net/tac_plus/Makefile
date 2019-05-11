include $(TOPDIR)/rules.mk

PKG_NAME:=tac_plus
PKG_VERSION:=4.0.4.28
PKG_REV:=259251e6f1c2d5c98081a43c6f66d9eb2989cfd8
PKG_RELEASE:=2

PKG_SOURCE_VERSION:=$(PKG_REV)
PKG_SOURCE_DATE:=2019.02.11
PKG_SOURCE_URL:=https://codeload.github.com/facebook/tac_plus/tar.gz/$(PKG_SOURCE_VERSION)?
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_DATE)-$(PKG_SOURCE_VERSION).tar.gz
PKG_HASH:=3c37d6a8acf66cac4a95558bf3e29686ef3be505a1638e2ef788a7ece41d1b01

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_SUBDIR:=tacacs-F$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

MAKE_PATH:=$(PKG_BUILD_SUBDIR)
CONFIGURE_PATH:=$(PKG_BUILD_SUBDIR)

CONFIGURE_ARGS += \
	--disable-shared \
	--without-libwrap

CONFIGURE_VARS += \
	ac_cv_lib_pam_pam_start=no

define Package/tac_plus
	SECTION:=net
	CATEGORY:=Network
	TITLE:=TACACS+ daemon
	URL:=https://github.com/facebook/tac_plus/
endef

define Package/tac_plus/description
TACACS+ is a protocol (not TACACS or XTACACS) for authentication,
authorization and accounting (AAA) services for routers and network devices.
endef

define Package/tac_plus/conffiles
/etc/tac_plus.conf
endef

define Package/tac_plus/install
	$(INSTALL_DIR) $(1)/etc/init.d $(1)/usr/sbin
	$(INSTALL_CONF) ./files/tac_plus.conf $(1)/etc/tac_plus.conf
	$(INSTALL_BIN) ./files/tac_plus.init $(1)/etc/init.d/tac_plus
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(PKG_BUILD_SUBDIR)/tac_plus $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,tac_plus))
