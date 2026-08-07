# OpenWrt package for the wwand cellular connection manager.
# One source package; the ucode side is split into a backend-neutral base
# plus per-backend packages so an install carries only the control protocols
# it needs. A typical QMI router installs `wwand-qmi` (which pulls in the
# `wwand` base); add `wwand-mbim` / `wwand-ncm` for those modems.

include $(TOPDIR)/rules.mk

PKG_NAME:=wwand
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/ddimension/wwand/tar.gz/refs/tags/v$(PKG_VERSION)?
PKG_HASH:=34cbeadd6846a4c0f37f1a2beb6771dfa03dafbe9ec46ccb261a502f6d97bbba

PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=André Valentin <avalentin@marcant.net>

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

# The native module's cmake tree is the io/ subdir of the source tree; build
# out-of-tree so cmake artifacts stay out of the source checkout. The ucode
# side (src-ucode/, files/) installs straight from PKG_BUILD_DIR and needs no
# compile step.
CMAKE_SOURCE_SUBDIR:=io
CMAKE_BINARY_SUBDIR:=build

UCDIR:=/usr/share/ucode/wwand

# ---------------------------------------------------------------------------
# base: daemon + framework + codec/client + shared core. No backend on its own;
# the daemon loads whichever wwand-qmi/-mbim/-ncm package is present.
# ---------------------------------------------------------------------------
define Package/wwand
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=WWAN
  TITLE:=Event-driven cellular connection manager (backend-neutral core)
  DEPENDS:=+ucode +ucode-mod-fs +ucode-mod-struct +ucode-mod-uloop \
	+ucode-mod-ubus +ucode-mod-uci +ucode-mod-rtnl +ucode-mod-wwand-io
endef

define Package/wwand/description
  wwand is an event-driven connection manager daemon for cellular modems,
  supporting multiple modems and multiple parallel PDP contexts. This base
  package carries the daemon, the netifd proto shim, the QMI codec (qmux/tlv +
  service schemas), the generic service client, the SIM/APDU layer and the
  shared modem/context core. Install a backend package (wwand-qmi, wwand-mbim
  or wwand-ncm) for the control protocols your modems use.
endef

define Package/wwand/install
	$(INSTALL_DIR) $(1)$(UCDIR)/codec/schema
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src-ucode/*.uc $(1)$(UCDIR)/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src-ucode/codec/*.uc $(1)$(UCDIR)/codec/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src-ucode/codec/schema/*.uc $(1)$(UCDIR)/codec/schema/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src-ucode/main.uc $(1)/usr/sbin/wwand
	# strip out the files that belong to the per-backend + esim packages
	rm -f $(1)$(UCDIR)/main.uc
	# QMI backend -> wwand-qmi
	rm -f $(1)$(UCDIR)/modem.uc $(1)$(UCDIR)/context.uc \
		$(1)$(UCDIR)/qmi_backend.uc $(1)$(UCDIR)/callend.uc $(1)$(UCDIR)/qmi_lazy.uc
	# MBIM backend -> wwand-mbim (incl. the MBIM codec + schema)
	rm -f $(1)$(UCDIR)/modem_mbim.uc $(1)$(UCDIR)/context_mbim.uc \
		$(1)$(UCDIR)/mbim_backend.uc $(1)$(UCDIR)/mbim_client.uc \
		$(1)$(UCDIR)/qmi_over_mbim.uc $(1)$(UCDIR)/mbim_lazy.uc \
		$(1)$(UCDIR)/codec/mbim.uc
	# NCM backend -> wwand-ncm
	rm -f $(1)$(UCDIR)/modem_ncm.uc $(1)$(UCDIR)/context_ncm.uc $(1)$(UCDIR)/ncm_lazy.uc
	# eSIM -> wwand-esim
	rm -f $(1)$(UCDIR)/esim.uc $(1)$(UCDIR)/esim_bridge.uc
	$(INSTALL_DIR) $(1)/lib/netifd/proto
	# the shim registers both `wwand` (current) and `qmi` (legacy alias); install
	# under the current name — the historical qmi.sh belonged to uqmi/qmi-advanced
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/wwand-proto.sh $(1)/lib/netifd/proto/wwand.sh
	$(INSTALL_DIR) $(1)/usr/libexec/wwand
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/wwand-migrate $(1)/usr/libexec/wwand/migrate
	# one-time auto-migration to the network-native config model on install/upgrade
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/wwand.defaults $(1)/etc/uci-defaults/99-wwand-migrate
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/wwand.init $(1)/etc/init.d/wwand
	# no /etc/config/wwand for new installs — all config lives in
	# /etc/config/network now (existing files survive upgrade and are still read;
	# the uci-defaults migrator converts them). files/wwand.config is kept in the
	# source tree only as a documented network-model example.
	$(INSTALL_DIR) $(1)/etc/hotplug.d/usbmisc
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/files/wwand.hotplug $(1)/etc/hotplug.d/usbmisc/20-wwand
	# net hotplug: NCM modems (no cdc-wdm) + re-enumeration after a mode switch
	$(INSTALL_DIR) $(1)/etc/hotplug.d/net
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/files/wwand.hotplug.net $(1)/etc/hotplug.d/net/20-wwand
	# tty hotplug: AT ports appearing after the datapath netdev (vendor-serial
	# new_id bind / late kmodloader) re-kick a modem parked in no_at_port backoff
	$(INSTALL_DIR) $(1)/etc/hotplug.d/tty
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/files/wwand.hotplug.tty $(1)/etc/hotplug.d/tty/20-wwand
endef

# ---------------------------------------------------------------------------
# wwand-qmi: the QMI backend (native qmux over /dev/cdc-wdmX).
# ---------------------------------------------------------------------------
define Package/wwand-qmi
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=WWAN
  TITLE:=QMI backend for wwand
  DEPENDS:=+wwand +kmod-usb-net-qmi-wwan +kmod-rmnet
  # replaces the stock OpenWrt QMI stack (uqmi + the qmi-advanced dialer): wwand
  # talks QMI natively, so they must not both claim the modem.
  CONFLICTS:=uqmi qmi-advanced
endef

define Package/wwand-qmi/description
  QMI control backend for wwand: talks QMI natively over /dev/cdc-wdmX (qmi_wwan
  driver) with QMAP multiplexing (rmnet), without spawning uqmi/qmicli. This is
  the common case for most cellular routers.
endef

define Package/wwand-qmi/install
	$(INSTALL_DIR) $(1)$(UCDIR)
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src-ucode/modem.uc $(1)$(UCDIR)/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src-ucode/context.uc $(1)$(UCDIR)/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src-ucode/qmi_backend.uc $(1)$(UCDIR)/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src-ucode/callend.uc $(1)$(UCDIR)/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src-ucode/qmi_lazy.uc $(1)$(UCDIR)/
endef

# ---------------------------------------------------------------------------
# wwand-mbim: the MBIM backend. Depends on wwand-qmi because the QMI-over-MBIM
# passthrough runs the QMI stack (qmi_backend) over the open MBIM channel.
# ---------------------------------------------------------------------------
define Package/wwand-mbim
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=WWAN
  TITLE:=MBIM backend for wwand
  DEPENDS:=+wwand-qmi +kmod-usb-net-cdc-mbim
  # replaces the stock OpenWrt MBIM stack (netifd `mbim` proto, package umbim):
  # wwand manages cdc_mbim modems itself, so the two must not both claim them.
  CONFLICTS:=umbim
endef

define Package/wwand-mbim/description
  MBIM control backend for wwand (cdc_mbim driver): native MS Basic Connect (+
  Extensions v2/v3) plus a QMI-over-MBIM passthrough that tunnels the whole QMI
  stack over the open MBIM channel for full CDC-level telemetry/config. The
  passthrough reuses qmi_backend, hence the dependency on wwand-qmi.
endef

define Package/wwand-mbim/install
	$(INSTALL_DIR) $(1)$(UCDIR)/codec/mbim-schema
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src-ucode/modem_mbim.uc $(1)$(UCDIR)/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src-ucode/context_mbim.uc $(1)$(UCDIR)/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src-ucode/mbim_backend.uc $(1)$(UCDIR)/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src-ucode/mbim_client.uc $(1)$(UCDIR)/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src-ucode/qmi_over_mbim.uc $(1)$(UCDIR)/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src-ucode/mbim_lazy.uc $(1)$(UCDIR)/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src-ucode/codec/mbim.uc $(1)$(UCDIR)/codec/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src-ucode/codec/mbim-schema/*.uc $(1)$(UCDIR)/codec/mbim-schema/
endef

# ---------------------------------------------------------------------------
# wwand-ncm: the NCM/ECM backend (cdc_ncm / cdc_ether, AT-controlled).
# ---------------------------------------------------------------------------
define Package/wwand-ncm
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=WWAN
  TITLE:=NCM/ECM backend for wwand
  DEPENDS:=+wwand +kmod-usb-net-cdc-ncm +kmod-usb-net-cdc-ether
  # replaces the stock OpenWrt NCM stack (netifd `ncm` proto, package comgt-ncm):
  # wwand drives the AT/NCM modem itself, so the two must not both claim it.
  CONFLICTS:=comgt-ncm
endef

define Package/wwand-ncm/description
  NCM/ECM control backend for wwand: an AT-controlled datapath over a plain
  cdc_ncm / cdc_ether netdev, for modems that expose no cdc-wdm control device.
endef

define Package/wwand-ncm/install
	$(INSTALL_DIR) $(1)$(UCDIR)
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src-ucode/modem_ncm.uc $(1)$(UCDIR)/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src-ucode/context_ncm.uc $(1)$(UCDIR)/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src-ucode/ncm_lazy.uc $(1)$(UCDIR)/
endef

# ---------------------------------------------------------------------------
# ucode-mod-wwand-io: native C transport module.
# ---------------------------------------------------------------------------
define Package/ucode-mod-wwand-io
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=ucode
  TITLE:=Message-oriented cdc-wdm/tty I/O module for wwand
  DEPENDS:=+libucode
endef

define Package/ucode-mod-wwand-io/description
  Minimal native ucode extension providing non-blocking, message-oriented
  I/O on QMI control devices (/dev/cdc-wdmX) and raw tty access for AT
  commands. Used by the wwand connection manager.
endef

define Package/ucode-mod-wwand-io/install
	$(INSTALL_DIR) $(1)/usr/lib/ucode
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/build/wwand_io.so $(1)/usr/lib/ucode/
endef

# ---------------------------------------------------------------------------
# wwand-esim: eSIM (eUICC) profile management. Needs a QMI UIM/APDU channel.
# ---------------------------------------------------------------------------
define Package/wwand-esim
  SECTION:=net
  CATEGORY:=Network
  TITLE:=eSIM (eUICC) profile management for wwand
  # lpac drives the SM-DP+ download/notification (ES9+ HTTPS on the router);
  # the daemon bridges its stdio APDU protocol inline. APDU access uses the
  # modem UIM channel, so it also needs the QMI backend.
  DEPENDS:=+wwand-qmi +lpac
endef

define Package/wwand-esim/description
  Optional ES10c (SGP.22) profile management for wwand: EID, profile list,
  enable/disable/delete over the modem UIM APDU channel. SM-DP+ profile
  downloads and notification acknowledgements are driven by lpac: its ES10
  APDUs are relayed through wwand's own APDU channel (ubus modem_apdu) by the
  stdio bridge, so wwand stays the sole owner of the modem — no separate AT
  port. lpac runs the ES9+ HTTPS on the router; no dedicated modem APN is
  required.

  The download itself is handled by the lpac package; the stdio APDU bridge
  needs lpac >= 2.3.0.
endef

define Package/wwand-esim/install
	$(INSTALL_DIR) $(1)$(UCDIR)
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src-ucode/esim.uc $(1)$(UCDIR)/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src-ucode/esim_bridge.uc $(1)$(UCDIR)/
endef

$(eval $(call BuildPackage,wwand))
$(eval $(call BuildPackage,wwand-qmi))
$(eval $(call BuildPackage,wwand-mbim))
$(eval $(call BuildPackage,wwand-ncm))
$(eval $(call BuildPackage,ucode-mod-wwand-io))
$(eval $(call BuildPackage,wwand-esim))
