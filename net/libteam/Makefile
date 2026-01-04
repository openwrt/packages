include $(TOPDIR)/rules.mk

PKG_NAME:=libteam
PKG_VERSION:=1.32
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/jpirko/libteam/tar.gz/refs/tags/v$(PKG_VERSION)?
PKG_HASH:=7ad90555db8aecdcaf002f543d330408501600edf7065e0ca398fce9b1e64820

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=lto

PKG_MAINTAINER:=Qingfang Deng <dqfext@gmail.com>
PKG_LICENSE:=LGPL-2.1-only
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS+=--disable-static

define Package/libteam/default
  SECTION:=libs
  CATEGORY:=Libraries
  URL:=https://github.com/jpirko/libteam
endef

define Package/libteam
  $(call Package/libteam/default)
  TITLE:=Team common library
  DEPENDS:=+kmod-team +libnl-cli \
	   +kmod-team-mode-activebackup \
	   +kmod-team-mode-broadcast \
	   +kmod-team-mode-loadbalance \
	   +kmod-team-mode-random \
	   +kmod-team-mode-roundrobin
  ABI_VERSION:=5
endef

define Package/libteam/description
  Libteam lib is a userspace wrapper of Team Netlink communication.
endef

define Package/libteamdctl
  $(call Package/libteam/default)
  TITLE:=Team daemon control library
  ABI_VERSION:=0
endef

define Package/libteamdctl/description
  Common library for teamdctl.
endef

define Package/teamd/default
  SECTION:=net
  CATEGORY:=Network
  URL:=https://github.com/jpirko/libteam
endef

define Package/teamd
  $(call Package/teamd/default)
  TITLE:=Team daemon
  DEPENDS:=+libteam +libdaemon +jansson
endef

define Package/teamd/description
  teamd is a daemon to control a given team network device, during runtime,
  as a puppeteer controls a puppet. It uses libteam to communicate with the
  kernel team device instance via Netlink sockets. The behaviour depends on
  the selected runner and its configuration.
endef

define Package/teamdctl
  $(call Package/teamd/default)
  TITLE:=Team daemon control tool
  DEPENDS:=+teamd +libteamdctl
endef

define Package/teamdctl/description
  teamdctl is a tool that allows a user to interact with a running teamd instance.
endef

define Package/teamnl
  $(call Package/teamd/default)
  TITLE:=Team Netlink interface tool
  DEPENDS:=+libteam
endef

define Package/teamnl/description
  teamnl is a tool enabling interaction with a team device via the team driver
  Netlink interface. This tools serves mainly for debugging purposes. Note that
  it makes no sense to use this tool to change options on team device controlled
  by a teamd instance.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr
	$(CP) $(PKG_INSTALL_DIR)/usr/include $(1)/usr
	$(CP) $(PKG_INSTALL_DIR)/usr/lib $(1)/usr
endef

define Package/libteam/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libteam.so.$(ABI_VERSION)* $(1)/usr/lib/
endef

define Package/libteamdctl/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libteamdctl.so.$(ABI_VERSION)* $(1)/usr/lib/
endef

define Package/teamd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/teamd $(1)/usr/bin/
endef

define Package/teamdctl/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/teamdctl $(1)/usr/bin/
endef

define Package/teamnl/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/teamnl $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libteam))
$(eval $(call BuildPackage,libteamdctl))
$(eval $(call BuildPackage,teamd))
$(eval $(call BuildPackage,teamdctl))
$(eval $(call BuildPackage,teamnl))
