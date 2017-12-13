include $(TOPDIR)/rules.mk

PKG_NAME:=oonf-olsrd2
PKG_VERSION:=0.14.1-1
PKG_REV:=d86825c0bdf144db706da444be7b0a2e8722b54d
PKG_RELEASE:=$(PKG_REV)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://github.com/OLSR/OONF.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_REV)

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

SPACE:=
SPACE+=
CMAKE_OPTIONAL_PLUGINS:= $(subst $(SPACE),;,$(strip \
        $(if $(filter y,$(CONFIG_OONF_NHDP_AUTOLL4)),auto_ll4,) \
        $(if $(filter y,$(CONFIG_OONF_OLSRV2_LAN_IMPORT)),lan_import,) \
        $(if $(filter y,$(CONFIG_OONF_OLSRV2_ROUTE_MODIFIER)),route_modifier,) \
        $(if $(filter y,$(CONFIG_OONF_GENERIC_DLEP_ROUTER)),dlep_router,) \
        $(if $(filter y,$(CONFIG_OONF_GENERIC_REMOTECONTROL)),remotecontrol,) \
        $(if $(filter y,$(CONFIG_OONF_OLSRV2_MPR)),mpr,) \
        $(if $(filter y,$(CONFIG_OONF_GENERIC_HTTP)),http,) \
    ))

BUILD_TYPE:= $(if $(filter y,$(CONFIG_DEBUG)),Debug,Release)

CMAKE_OPTIONS=-D CMAKE_BUILD_TYPE:String=$(BUILD_TYPE) \
              -D OONF_NO_WERROR:Bool=true \
              -D OONF_LOGGING_LEVEL:String=debug \
              -D OONF_NO_TESTING:Bool=true \
              -D UCI:Bool=true \
              -D OONF_APP_DEFAULT_CFG_HANDLER:String=uci \
              -D OONF_STATIC_PLUGINS:String="class;clock;duplicate_set;layer2;packet_socket;rfc5444;socket;stream_socket;telnet;timer;viewer;os_clock;os_fd;os_interface;os_routing;os_system;nhdp;olsrv2;ff_dat_metric;neighbor_probing;nl80211_listener;link_config;layer2info;systeminfo;cfg_uciloader;cfg_compact;nhdpinfo;olsrv2info;netjsoninfo;${CMAKE_OPTIONAL_PLUGINS}" \
              -D OONF_LIB_GIT:String=v$(PKG_VERSION)-archive \
              -D OONF_VERSION:String=$(PKG_VERSION) \
              -D INSTALL_LIB_DIR:Path=lib/oonf \
              -D INSTALL_INCLUDE_DIR:Path=include/oonf \
              -D INSTALL_CMAKE_DIR:Path=lib/oonf \
              -D CMAKE_PREFIX_PATH=$(STAGING_DIR)/usr

define Package/oonf-git/template
	SECTION:=net
	CATEGORY:=Network
	MAINTAINER:=Henning Rogge <hrogge@gmail.com>
	SUBMENU:=OLSR.org network framework
	URL:=http://www.olsr.org/
	MENU:=1
endef

define Package/oonf-olsrd2
	$(call Package/oonf-git/template)
	TITLE:= Build Olsrd V2 Routing Agent
	DEPENDS:=+librt +libnl-tiny +libuci +oonf-init-scripts
	VERSION:=$(PKG_VERSION)
endef

define Package/oonf-olsrd2/config
	source "$(SOURCE)/Config.in"
endef

Build/Compile=$(call Build/Compile/Default,olsrd2_static)
Build/Install=

define Build/Install
	$(INSTALL_BIN) -D $(PKG_BUILD_DIR)/$(MAKE_PATH)/olsrd2_static $(PKG_INSTALL_DIR)/usr/sbin/olsrd2;
endef

TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include -I${STAGING_DIR}/usr/include/libnl-tiny

define Package/oonf-olsrd2/install
	$(INSTALL_BIN)  -D $(PKG_BUILD_DIR)/olsrd2_static $(1)/usr/sbin/olsrd2
	$(INSTALL_BIN)  -D ./files/olsrd2.init            $(1)/etc/init.d/olsrd2
	$(INSTALL_BIN)  -D ./files/olsrd2.hotplug         $(1)/etc/hotplug.d/iface/50-olsrd2
	$(INSTALL_DATA) -D ./files/olsrd2.uci             $(1)/etc/config/olsrd2
endef

define Package/oonf-olsrd2/conffiles
/etc/config/olsrd2
endef

$(eval $(call BuildPackage,oonf-olsrd2))
