include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=oonf-init-scripts
PKG_VERSION:=0.9.1-r3
PKG_RELEASE:=1
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/oonf-init-scripts
	SECTION:=net
	CATEGORY:=Network
	MAINTAINER:=Henning Rogge <hrogge@gmail.com>
	SUBMENU:=OLSR.org network framework
	URL:=http://www.olsr.org/
	TITLE:= Common OONF startup scripts
	VERSION:=$(PKG_VERSION)
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/oonf-init-scripts/install
	$(INSTALL_BIN)  -D ./files/oonf_init.sh            $(1)/lib/functions/oonf_init.sh
	$(INSTALL_BIN)  -D ./files/oonf_hotplug.sh         $(1)/lib/functions/oonf_hotplug.sh
endef

$(eval $(call BuildPackage,oonf-init-scripts))
