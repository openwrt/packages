# OpenWrt package for the wwand cellular connection manager.
# One source package; the ucode side is split into a backend-neutral base plus
# per-backend packages so an install carries only the control protocols it
# needs:
#   wwand      - daemon + shared core + codec/client + native wwand_io.so
#                transport module (no backend on its own)
#   wwand-qmi  - QMI backend            (DEPENDS wwand)
#   wwand-mbim - MBIM backend           (DEPENDS wwand-qmi: the QMI-over-MBIM
#                                        passthrough reuses qmi_backend)
#   wwand-ncm  - NCM/ECM backend        (DEPENDS wwand)
#   wwand-mhi  - PCIe/MHI transport + drivers (DEPENDS wwand; add a backend)
#   wwand-esim - eSIM management        (DEPENDS wwand-qmi + lpac)
# A typical QMI router installs `wwand-qmi` (which pulls in `wwand`); add
# `wwand-mbim` / `wwand-ncm` for those modems, `wwand-mhi` for a PCIe/MHI modem.
# The ucode tree ships as SOURCE. It can be precompiled to bytecode (repo-root
# CMakeLists.txt, alongside wwand_io.so) via CONFIG_WWAND_UCODE_PRECOMPILE, but
# that is opt-in and only sound when ucode and wwand are built in the SAME tree:
# bytecode carries a format version (UCODE_BYTECODE_VERSION, ucode's
# include/ucode/vm.h) that an interpreter upgraded past it refuses to load. That
# version is independent of libucode's PKG_ABI_VERSION/SONAME, so no package
# relation — not even an ABI-versioned dependency — expresses the coupling. In a
# feed, where ucode is upgraded on its own, it must not be created.

include $(TOPDIR)/rules.mk

PKG_NAME:=wwand
PKG_VERSION:=1.6.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/ddimension/wwand/tar.gz/refs/tags/v$(PKG_VERSION)?
PKG_HASH:=c7d85b1d6c7f8b524b7eab3f1381b34961e6e22810852b122dcd00b890289d0c

PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=André Valentin <avalentin@marcant.net>

# host ucode is the bytecode compiler, needed ONLY on the opt-in precompile
# path — gated so a default build does not pay for a host ucode nothing
# consumes. Same-tree builds are also the only ones where the bytecode is
# guaranteed to match the target interpreter (see the note above).
#
# The SYMBOL:pkg form is required here: Build-Depends is emitted by the metadata
# scan, which runs with DUMP=1, and rules.mk skips $(TOPDIR)/.config in that
# case — so a $(if $(CONFIG_...),...) wrapper is always empty at scan time and
# would drop the dependency unconditionally. package-metadata.pl turns the
# prefix into the conditional instead.
PKG_BUILD_DEPENDS:=WWAND_UCODE_PRECOMPILE:ucode/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

# One cmake build (repo-root CMakeLists.txt) produces the native wwand_io.so
# (io/ subdir) and, ONLY when CONFIG_WWAND_UCODE_PRECOMPILE is set, the ucode
# tree compiled to bytecode — one compiler invocation per file with explicit
# source lists. On that opt-in path a configure-time capability probe checks the
# SDK's host ucode can actually emit a bytecode module; an older ucode that
# cannot falls back to shipping the ucode SOURCE instead of failing the build.
CMAKE_BINARY_SUBDIR:=build

CMAKE_OPTIONS += \
	-DUCODE_COMPILER=$(STAGING_DIR_HOSTPKG)/bin/ucode \
	-DUCODE_PRECOMPILE=$(if $(CONFIG_WWAND_UCODE_PRECOMPILE),ON,OFF)

# every install section takes the ucode tree from here: the plain sources, or
# the cmake bytecode output when CONFIG_WWAND_UCODE_PRECOMPILE is set.
WWAND_UCODE=$(if $(CONFIG_WWAND_UCODE_PRECOMPILE),$(CMAKE_BINARY_DIR)/ucode/wwand,$(PKG_BUILD_DIR)/src-ucode)

UCDIR:=/usr/share/ucode/wwand

# Base-package ucode set, listed explicitly per install dir. No glob-then-`rm`:
# every module is owned by exactly one package, so a new backend file can never
# silently ship in the base too. The per-backend install lists below carry the
# QMI/MBIM/NCM/eSIM modules; main.uc/wwandctl.uc install as executables.
WWAND_BASE_UC:=apndb.uc atcmd.uc atcmd_parse.uc atport.uc backend.uc board.uc \
	carrier_config.uc \
	client.uc config.uc config_check.uc context_common.uc context_monitor_qmi.uc \
	ctx_settings.uc daemon.uc discovery.uc hwops.uc log.uc modem_common.uc \
	modem_datapath_qmi.uc modem_init_qmi.uc modem_quirks.uc modeswitch.uc \
	ncm_vendors.uc netlink.uc netsel_ops.uc protocol_switch.uc reconnect.uc \
	recovery.uc regdetail.uc sim.uc sim_plmn.uc simops.uc sms.uc sms_pdu.uc \
	telemetry_mbim.uc telemetry_ncm.uc telemetry_qmi.uc transport.uc ubus.uc \
	version.uc
WWAND_BASE_CODEC:=arfcn_bands.uc hex.uc qmux.uc tlv.uc
WWAND_BASE_SCHEMA:=cat.uc ctl.uc dms.uc dsd.uc loc.uc loc_lazy.uc merge.uc nas.uc \
	pdc.uc rat.uc tmd.uc uim.uc wda.uc wds.uc wms.uc wms_lazy.uc

# Readable .uc source is what ships by default, so modules can be edited live
# under /usr/share/ucode/wwand and tracebacks carry source line numbers;
# bytecode tracebacks report offsets only.
PKG_CONFIG_DEPENDS:=CONFIG_WWAND_UCODE_PRECOMPILE

define Package/wwand/config
config WWAND_UCODE_PRECOMPILE
	bool "Precompile the ucode tree to bytecode"
	depends on PACKAGE_wwand
	default n
	help
	  Compile the ucode tree to bytecode instead of shipping the
	  readable sources, so the daemon starts without a parse step
	  (measured 41 ms -> 5 ms for the core imports on x86).

	  Only enable this when ucode and wwand come from the SAME build
	  tree, such as a self-built image. Bytecode carries a format
	  version that an interpreter upgraded past it refuses to load,
	  and nothing in the package metadata can express that dependency,
	  so a plain package upgrade of ucode would leave the daemon
	  unable to start.
endef

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
	+ucode-mod-ubus +ucode-mod-uci +ucode-mod-rtnl
  # the native wwand_io transport module ships inside this package (it is
  # wwand-private, always version-locked to the ucode side). PROVIDES keeps
  # configs/upgrades from the era of the separate ucode-mod-wwand-io working.
  PROVIDES:=ucode-mod-wwand-io
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
	# native transport module (built by the cmake step from io/)
	$(INSTALL_DIR) $(1)/usr/lib/ucode
	$(INSTALL_BIN) $(CMAKE_BINARY_DIR)/io/wwand_io.so $(1)/usr/lib/ucode/
	# base ucode tree — explicit per-file lists (see WWAND_BASE_* above), so the
	# base package owns exactly its own modules and nothing a backend ships.
	$(INSTALL_DIR) $(1)$(UCDIR)/codec/schema
	$(INSTALL_DATA) $(addprefix $(WWAND_UCODE)/,$(WWAND_BASE_UC)) $(1)$(UCDIR)/
	$(INSTALL_DATA) $(addprefix $(WWAND_UCODE)/codec/,$(WWAND_BASE_CODEC)) $(1)$(UCDIR)/codec/
	$(INSTALL_DATA) $(addprefix $(WWAND_UCODE)/codec/schema/,$(WWAND_BASE_SCHEMA)) $(1)$(UCDIR)/codec/schema/
	# daemon + CLI as executables (not under $(UCDIR))
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(WWAND_UCODE)/main.uc $(1)/usr/sbin/wwand
	# wwandctl: the human-friendly CLI front-end over the ubus API
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(WWAND_UCODE)/wwandctl.uc $(1)/usr/bin/wwandctl
	$(INSTALL_DIR) $(1)/lib/netifd/proto
	# the shim registers `wwand` and nothing else — the `qmi` proto name stays
	# uqmi's, so netifd's handler load order never decides ownership. Install
	# under the current name; the historical qmi.sh belongs to uqmi.
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/wwand-proto.sh $(1)/lib/netifd/proto/wwand.sh
	$(INSTALL_DIR) $(1)/usr/libexec/wwand
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/wwand-migrate $(1)/usr/libexec/wwand/migrate
	# Config migration is ALWAYS user-triggered: nothing is installed under
	# /etc/uci-defaults, so installing or upgrading wwand never rewrites an
	# existing configuration. The example below is shipped inert; copying it
	# into /etc/uci-defaults/ runs the same migration once, at the next boot.
	$(INSTALL_DIR) $(1)/usr/share/wwand/examples
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/examples/99-wwand-migrate \
		$(1)/usr/share/wwand/examples/99-wwand-migrate
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/wwand.init $(1)/etc/init.d/wwand
	# no /etc/config/wwand for new installs — all config lives in
	# /etc/config/network now (existing files survive upgrade and are still read).
	# files/wwand.config is kept in the source tree only as a documented example.
	$(INSTALL_DIR) $(1)/etc/hotplug.d/usbmisc
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/files/wwand.hotplug $(1)/etc/hotplug.d/usbmisc/20-wwand
	# net hotplug: NCM modems (no cdc-wdm) + re-enumeration after a mode switch
	$(INSTALL_DIR) $(1)/etc/hotplug.d/net
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/files/wwand.hotplug.net $(1)/etc/hotplug.d/net/20-wwand
	# tty hotplug: AT ports appearing after the datapath netdev (vendor-serial
	# new_id bind / late kmodloader) re-kick a modem parked in no_at_port backoff
	$(INSTALL_DIR) $(1)/etc/hotplug.d/tty
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/files/wwand.hotplug.tty $(1)/etc/hotplug.d/tty/20-wwand
	# NOTE: the kernel-wwan-subsystem hotplug (/etc/hotplug.d/wwan/20-wwand) is
	# NOT installed here — it belongs to wwand-mhi, which also pulls the MHI
	# drivers that create /sys/class/wwan in the first place (procd only arms a
	# subsystem whose hotplug dir exists). USB modems never need it.
endef

# ---------------------------------------------------------------------------
# wwand-qmi: the QMI backend (native qmux over /dev/cdc-wdmX).
# ---------------------------------------------------------------------------
define Package/wwand-qmi
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=WWAN
  TITLE:=QMI backend for wwand
  # kmod-rmnet is the QMAP demuxer and is needed on BOTH transports (an MHI
  # modem multiplexes through it too); only the USB glue is conditional, so a
  # target built without USB support can still select this backend and drive a
  # PCIe/MHI modem. On a USB target nothing changes.
  DEPENDS:=+wwand +USB_SUPPORT:kmod-usb-net-qmi-wwan +kmod-rmnet
  # coexists with the stock OpenWrt QMI stack (uqmi): wwand claims only
  # `proto wwand` interfaces, so both can be installed and exactly one owns a
  # given interface. Hand one over by migrating it (LuCI modem list,
  # /usr/libexec/wwand/migrate, or the example uci-defaults script), which
  # rewrites it in place to `proto wwand`.
endef

define Package/wwand-qmi/description
  QMI control backend for wwand: talks QMI natively over /dev/cdc-wdmX (qmi_wwan
  driver) with QMAP multiplexing (rmnet), without spawning uqmi/qmicli. This is
  the common case for most cellular routers. Pair with wwand-mhi for modems
  attached over PCIe/MHI.
endef

define Package/wwand-qmi/install
	$(INSTALL_DIR) $(1)$(UCDIR)
	$(INSTALL_DATA) $(WWAND_UCODE)/modem.uc $(1)$(UCDIR)/
	$(INSTALL_DATA) $(WWAND_UCODE)/context.uc $(1)$(UCDIR)/
	$(INSTALL_DATA) $(WWAND_UCODE)/qmi_backend.uc $(1)$(UCDIR)/
	$(INSTALL_DATA) $(WWAND_UCODE)/callend.uc $(1)$(UCDIR)/
	$(INSTALL_DATA) $(WWAND_UCODE)/qmi_lazy.uc $(1)$(UCDIR)/
	# Datapath plug-ins for the two VENDOR QMAP drivers (qmi_wwan_q on USB,
	# pcie_mhi on PCIe/MHI). Neither driver is in the kernel tree, so on an
	# OpenWrt kernel these are inert: each probe() looks for the QMAP children
	# its driver would have registered, finds none, and declines — the built-in
	# rmnet/qmimux datapaths are chosen exactly as before. They live here rather
	# than in packages of their own because they declare `proto: [ 'qmi' ]` and
	# are useless without this backend, and because two ucode files do not earn
	# two more packages. On a vendor kernel they are what keeps Qualcomm NSS
	# offload working, by adopting the driver's own children instead of building
	# new ones on a parent that already demuxes QMAP.
	$(INSTALL_DATA) $(WWAND_UCODE)/datapath_rmnet_nss.uc $(1)$(UCDIR)/
	$(INSTALL_DATA) $(WWAND_UCODE)/datapath_rmnet_nss_mhi.uc $(1)$(UCDIR)/
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
  # conditional for the same reason as wwand-qmi: the ucode side is
  # transport-neutral, and on MHI the transport is kmod-mhi-wwan-mbim, which
  # wwand-mhi already pulls
  DEPENDS:=+wwand-qmi +USB_SUPPORT:kmod-usb-net-cdc-mbim
  # coexists with the stock OpenWrt MBIM stack (netifd `mbim` proto, package
  # umbim): wwand manages a cdc_mbim modem only once its interface has been
  # migrated to `proto wwand` (LuCI modem list / migrate CLI), so both stacks can
  # be installed side by side.
endef

define Package/wwand-mbim/description
  MBIM control backend for wwand (cdc_mbim driver): native MS Basic Connect (+
  Extensions v2/v3) plus a QMI-over-MBIM passthrough that tunnels the whole QMI
  stack over the open MBIM channel for full CDC-level telemetry/config. The
  passthrough reuses qmi_backend, hence the dependency on wwand-qmi. Pair
  with wwand-mhi for modems attached over PCIe/MHI.
endef

define Package/wwand-mbim/install
	$(INSTALL_DIR) $(1)$(UCDIR)/codec/mbim_schema
	$(INSTALL_DATA) $(WWAND_UCODE)/modem_mbim.uc $(1)$(UCDIR)/
	$(INSTALL_DATA) $(WWAND_UCODE)/context_mbim.uc $(1)$(UCDIR)/
	$(INSTALL_DATA) $(WWAND_UCODE)/mbim_backend.uc $(1)$(UCDIR)/
	$(INSTALL_DATA) $(WWAND_UCODE)/mbim_client.uc $(1)$(UCDIR)/
	$(INSTALL_DATA) $(WWAND_UCODE)/qmi_over_mbim.uc $(1)$(UCDIR)/
	$(INSTALL_DATA) $(WWAND_UCODE)/mbim_lazy.uc $(1)$(UCDIR)/
	$(INSTALL_DATA) $(WWAND_UCODE)/atcmd_mbim.uc $(1)$(UCDIR)/
	$(INSTALL_DATA) $(WWAND_UCODE)/atcmd_mbim_lazy.uc $(1)$(UCDIR)/
	$(INSTALL_DATA) $(WWAND_UCODE)/codec/mbim.uc $(1)$(UCDIR)/codec/
	$(INSTALL_DATA) $(WWAND_UCODE)/codec/mbim_schema/*.uc $(1)$(UCDIR)/codec/mbim_schema/
endef

# ---------------------------------------------------------------------------
# wwand-ncm: the NCM/ECM backend (cdc_ncm / cdc_ether, AT-controlled).
# ---------------------------------------------------------------------------
define Package/wwand-ncm
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=WWAN
  TITLE:=NCM/ECM backend for wwand
  # +kmod-usb-net-rndis: the RNDIS datapath (rndis_host) used by e.g. the
  # Fibocom FM350-GL (MediaTek T700) — same AT-driven backend, RNDIS netdev.
  #
  # These three stay UNCONDITIONAL, unlike the USB kmods of wwand-qmi and
  # wwand-mbim. Those two have a non-USB transport to fall back on — QMI keeps
  # +kmod-rmnet unconditional and reaches a modem over MHI, MBIM gets
  # kmod-mhi-wwan-mbim through wwand-mhi — so gating their USB kmod still
  # leaves a package that works on a PCIe-only target. NCM has no such path:
  # the backend drives a single cdc_ncm/cdc_ether netdev and the only variant
  # it recognises is rndis_host, all of them USB. Gating these on USB_SUPPORT
  # would leave the package selectable on a !USB_SUPPORT target while pulling
  # no datapath driver at all — installable and inert. The hard dependency is
  # what keeps it unselectable there, which is the honest result.
  DEPENDS:=+wwand +kmod-usb-net-cdc-ncm +kmod-usb-net-cdc-ether \
	+kmod-usb-net-rndis
  # coexists with the stock OpenWrt NCM stack (netifd `ncm` proto, package
  # comgt-ncm): wwand drives an AT/NCM modem only once its interface has been
  # migrated to `proto wwand` (LuCI modem list / migrate CLI), so both stacks can
  # be installed side by side.
endef

define Package/wwand-ncm/description
  NCM/ECM control backend for wwand: an AT-controlled datapath over a plain
  cdc_ncm / cdc_ether netdev, for modems that expose no cdc-wdm control device.
endef

define Package/wwand-ncm/install
	$(INSTALL_DIR) $(1)$(UCDIR)
	$(INSTALL_DATA) $(WWAND_UCODE)/modem_ncm.uc $(1)$(UCDIR)/
	$(INSTALL_DATA) $(WWAND_UCODE)/context_ncm.uc $(1)$(UCDIR)/
	$(INSTALL_DATA) $(WWAND_UCODE)/ncm_lazy.uc $(1)$(UCDIR)/
endef

# ---------------------------------------------------------------------------
# wwand-mhi: PCIe/MHI transport bundle. Modems on the kernel `wwan` subsystem
# (Foxconn T99W175/SDX, Quectel RM5xx-AE, Telit FN990, …) expose their QMI/MBIM
# control port under /sys/class/wwan — not usbmisc/cdc-wdm — and need the MHI
# driver stack instead of the USB kmods. This package pulls those drivers and
# ships the wwan-subsystem hotplug that binds such a modem on cold-plug. It is
# transport-only and backend-neutral: install ALONGSIDE wwand-qmi (QMI over MHI,
# rmnet data) or wwand-mbim (MBIM over MHI) for the control protocol.
# ---------------------------------------------------------------------------
define Package/wwand-mhi
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=WWAN
  TITLE:=PCIe/MHI transport + drivers for wwand
  DEPENDS:=+wwand +kmod-mhi-pci-generic +kmod-mhi-wwan-ctrl \
	+kmod-mhi-wwan-mbim +kmod-mhi-net
endef

define Package/wwand-mhi/description
  Support for cellular modems attached over PCIe/MHI (Foxconn T99W175 and
  similar), whose control ports appear on the kernel wwan subsystem. Pulls the
  MHI bus/PCI/control/data drivers and installs the wwan-subsystem hotplug so
  wwand binds these modems on boot. Install together with a control backend
  (wwand-qmi or wwand-mbim).

  Adding wwand-mbim is worth weighing on a QMI-driven MHI modem: many of them
  expose no DUN channel and therefore no AT port at all, and wwand can then
  carry AT over the modem's MBIM channel instead (Quectel QDU). It costs
  nothing on this path any more: the USB glue of every backend is now a
  USB_SUPPORT-conditional dependency, so on a PCIe-only target the backends are
  selectable and pull no USB stack, while a USB target gets exactly what it did
  before. Without wwand-mbim the capability is simply absent — vendor AT
  commands, the protocol switch and AT telemetry are unavailable, which is a
  limitation rather than a failure.
endef

define Package/wwand-mhi/install
	# wwan-subsystem hotplug: MHI modems expose their control port under
	# /sys/class/wwan (/dev/wwanXqmiN|mbimN). procd only dispatches the `wwan`
	# subsystem once this directory exists — so it ships with the MHI drivers,
	# not with the base package.
	$(INSTALL_DIR) $(1)/etc/hotplug.d/wwan
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/files/wwand.hotplug.wwan $(1)/etc/hotplug.d/wwan/20-wwand
endef

# ---------------------------------------------------------------------------
# wwand-esim: eSIM (eUICC) profile management. Needs a QMI UIM/APDU channel.
# ---------------------------------------------------------------------------
define Package/wwand-esim
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=WWAN
  TITLE:=eSIM (eUICC) profile management for wwand
  # Needs an lpac binary at /usr/bin/lpac (the +lpac dependency). lpac drives the
  # SM-DP+ download/notification (ES9+ HTTPS on the router); the daemon bridges
  # its stdio APDU protocol inline. APDU access uses the modem UIM channel, so it
  # also needs the QMI backend.
  DEPENDS:=+wwand-qmi +lpac
endef

define Package/wwand-esim/description
  Optional ES10c (SGP.22) profile management for wwand: EID, profile list,
  enable/disable/delete over the modem UIM APDU channel. SM-DP+ profile
  downloads and notification acknowledgements are driven by lpac: its ES10
  APDUs are relayed through wwand's own APDU channel (ubus modem_apdu) by the
  stdio bridge, so wwand stays the sole owner of the modem — no separate AT
  port. lpac runs the ES9+ HTTPS on the router; no dedicated modem APN is
  required. The stdio APDU bridge needs lpac >= 2.3.0.
endef

define Package/wwand-esim/install
	$(INSTALL_DIR) $(1)$(UCDIR)
	$(INSTALL_DATA) $(WWAND_UCODE)/esim.uc $(1)$(UCDIR)/
	$(INSTALL_DATA) $(WWAND_UCODE)/esim_bridge.uc $(1)$(UCDIR)/
endef

$(eval $(call BuildPackage,wwand))
$(eval $(call BuildPackage,wwand-qmi))
$(eval $(call BuildPackage,wwand-mbim))
$(eval $(call BuildPackage,wwand-ncm))
$(eval $(call BuildPackage,wwand-mhi))
$(eval $(call BuildPackage,wwand-esim))
