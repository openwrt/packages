include $(TOPDIR)/rules.mk

PKG_NAME:=freeipmi
PKG_VERSION:=1.6.15
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://ftp.gnu.org/gnu/$(PKG_NAME)
PKG_HASH:=d6929c354639f5ce75b5b1897e8b366eb63625c23e5c4590a7aea034fe2b8caf
PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_DEPENDS:=!USE_GLIBC:argp-standalone
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libfreeipmi/Default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=GNU implementation of the IPMI protocol
  URL:=https://www.gnu.org/software/freeipmi/
  MAINTAINER:=Bjørn Mork <bjorn@mork.no>
endef

define Package/libfreeipmi
  $(call Package/libfreeipmi/Default)
  DEPENDS:=+libgcrypt +libpthread
  TITLE+= (libfreeipmi)
endef

define Package/libfreeipmi/description
OpenIPMI, KCS, SMIC, SSIF, LAN drivers, and an IPMI API in a C Library.
endef

define Package/freeipmi-tools
  $(call Package/libfreeipmi/Default)
  DEPENDS:=+libipmiconsole +libipmidetect
  TITLE+= (tools)
endef

define Package/freeipmi-tools/description
Assorted IPMI-related tools:
 * bmc-config - configure BMC values
 * bmc-info - display BMC information
 * ipmi-chassis - IPMI chassis management utility
 * ipmi-fru - display FRU information
 * ipmi-locate - IPMI probing utility
 * ipmi-oem - IPMI OEM utility
 * ipmi-pet - decode Platform Event Traps
 * ipmi-raw - IPMI raw communication utility
 * ipmi-sel - display SEL entries
 * ipmi-sensors - display IPMI sensor information
 * ipmi-sensors-config - configure sensors
 * ipmiconsole - IPMI console utility
 * ipmiping - send IPMI Get Authentication Capability request
 * ipmipower - IPMI power control utility
 * pef-config - configure PEF values
 * rmcpping - send RMCP Ping to network hosts
endef

define Package/libipmiconsole
  $(call Package/libfreeipmi/Default)
  DEPENDS:=+libfreeipmi
  TITLE+= (libipmiconsole)
endef

define Package/libipmiconsole/description
A library for Serial-over-Lan (SOL).
endef

define Package/libipmidetect
  $(call Package/libfreeipmi/Default)
  DEPENDS:=+libfreeipmi
  TITLE+= (libipmidetect)
endef

define Package/libipmidetect/description
A library for IPMI node detection.
endef

CONFIGURE_ARGS += \
	--disable-doc \
	--disable-static

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
endef

define Package/libfreeipmi/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libfreeipmi.so.* $(1)/usr/lib/
endef

define Package/freeipmi-tools/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/bmc-config $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/bmc-info $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ipmi-chassis $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ipmi-fru $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ipmi-locate $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ipmi-oem $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ipmi-pet $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ipmi-raw $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ipmi-sel $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ipmi-sensors $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ipmi-sensors-config $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ipmiping $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ipmi-pef-config $(1)/usr/sbin/pef-config
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/rmcpping $(1)/usr/sbin/
endef

define Package/libipmiconsole/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libipmiconsole.so.* $(1)/usr/lib/
endef

define Package/libipmidetect/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libipmidetect.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libfreeipmi))
$(eval $(call BuildPackage,freeipmi-tools))
$(eval $(call BuildPackage,libipmiconsole))
$(eval $(call BuildPackage,libipmidetect))
