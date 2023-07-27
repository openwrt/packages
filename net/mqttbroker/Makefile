include $(TOPDIR)/rules.mk

PKG_NAME:=mqttbroker
PKG_VERSION:=0.99
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/VolkerChristian/mqttbroker.git
#PKG_SOURCE_VERSION:=ca59421e796d4bb56d92062a01c30967f15fd7d6
PKG_SOURCE_VERSION:=HEAD
PKG_SOURCE_DATE:=2023-07-02
#PKG_MIRROR_HASH:=cc81b7858173c649c2b4756a186df044e4d5d72a7c98db05327a41fba89c4eeb
PKG_MIRROR_HASH:=skip

PKG_MAINTAINER:=Volker Christian <me@vchrist.at>

PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=+snode.c

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/mqttbroker
  SECTION:=net
  CATEGORY:=Network
  TITLE:=A very lightweight MQTT-Integration System
  URL:=https://github.com/VolkerChristian/mqttbroker
  DEPENDS:=+snode.c-net-in-stream-legacy +snode.c-net-in-stream-tls +snode.c-net-un-stream-legacy +snode.c-http-server-express +snode.c-http-client +snode.c-websocket-server +snode.c-websocket-client +snode.c-mqtt-server +snode.c-mqtt-client
endef

define Package/mqttbroker/description
  The MQTT-Broker project consist of three applications mqttbroker,
  mqttintegrator and wsmqttintegrator powered by SNode.C, a single
  threaded, single tasking framework for networking applications
  written entirely in C++. Due to it's little resource usage it is
  especially usable on resource limited systems.
endef

define remove_rpath_prefix
	echo "Package install root: $(1)"; \
	find $(1) -type f -a -exec file {} \; | \
		sed -n -e 's/^\(.*\):.*ELF.*\(executable\|relocatable\|shared object\).*,.*/\1:\2/p' | \
	( \
		IFS=":"; \
		while read F S; do \
			echo "$$$$F: $$$$S"; \
			b=$$$$(stat -c '%a' $$$$F); \
			cur_rpath="$$$$($(STAGING_DIR_HOST)/bin/patchelf --print-rpath $$$$F)"; \
			new_rpath=""; \
			echo "Current RPATH: $$$$cur_rpath"; \
			for path in $$$$cur_rpath; do \
				case "$$$$path" in \
					$(STAGING_DIR)/[^/]*) \
						path_stripped=$$$$(echo $$$$path | sed "s|$(STAGING_DIR)||"); \
						new_rpath="$$$${new_rpath:+$$$$new_rpath:}$$$$path_stripped"; \
						;; \
					*) \
						new_rpath="$$$${new_rpath:+$$$$new_rpath:}$$$$path"; \
						;; \
				esac; \
			done; \
			echo "Final RPATH: $$$$new_rpath"; \
			[ "$$$$new_rpath" = "$$$$cur_rpath" ] || $(STAGING_DIR_HOST)/bin/patchelf --set-rpath "$$$$new_rpath" $$$$F; \
			a=$$$$(stat -c '%a' $$$$F); \
			[ "$$$$a" = "$$$$b" ] || chmod $$$$b $$$$F; \
		done; \
		true; \
	)
endef

define Package/mqttbroker/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
	find $(1)/usr/lib -name "*.so"  -exec rm {} ";"
	$(call remove_rpath_prefix,$(1)/usr)
endef

$(eval $(call BuildPackage,mqttbroker))
