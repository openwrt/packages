# SPDX-License-Identifier: AGPL-3.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=lpac
PKG_VERSION:=2.3.0
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/estkme-group/lpac/tar.gz/refs/tags/v$(PKG_VERSION)?
PKG_HASH:=661dffbd1e9e5732dab4a0bb0a9837d4906c8c66bd748bda262fe3e8d3e420f6

PKG_MAINTAINER:=David Bauer <david.bauer@uniberg.com>
PKG_LICENSE:=AGPL-3.0-only LGPL-2.0-only

CMAKE_INSTALL:=1

PKG_CONFIG_DEPENDS:=CONFIG_LPAC_INSTALL_GSMA_CI_CERTS

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

ifdef CONFIG_LPAC_INSTALL_GSMA_CI_CERTS

define Download/lpac-gsma-ci-m2m
  URL:=https://www.gsma.com/solutions-and-impact/technologies/internet-of-things/wp-content/uploads/2017/03/
  URL_FILE:=Verizon_GSMA_M2M31-Root-CI21.crt_.txt
  FILE:=lpac-gsma-ci-m2m.der
  SPOOF_USER_AGENT:=Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:139.0) Gecko/20100101 Firefox/139.0
  HASH:=d0c6a93f278da530fba73d01b149ef2f780c65d595981bb107d1768a7aeab958
endef
$(eval $(call Download,lpac-gsma-ci-m2m))

define Download/lpac-gsma-ci-consumer
  URL:=https://www.gsma.com/solutions-and-impact/technologies/internet-of-things/wp-content/uploads/2017/03/
  URL_FILE:=Symantec_GSMA_RSPv2-Root-CI1.txt
  FILE:=lpac-gsma-ci-consumer.pem
  SPOOF_USER_AGENT:=Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:139.0) Gecko/20100101 Firefox/139.0
  HASH:=01374ed6bc89ffa446d9dd38d52a8280624c5add811ba9dee7bea0bdc14b26e9
endef
$(eval $(call Download,lpac-gsma-ci-consumer))

define Download/lpac-gsma-ci-oiste
  URL:=https://www.gsma.com/solutions-and-impact/technologies/esim/wp-content/uploads/2024/01/
  URL_FILE:=CERT_CI_SIG_OISTE.pem_.zip
  FILE:=lpac-gsma-ci-oiste.zip
  SPOOF_USER_AGENT:=Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:139.0) Gecko/20100101 Firefox/139.0
  HASH:=a258352482c5e7392ebed501a1479ff0bd07f9ef36417fe836aa22d02a84a4c1
endef
$(eval $(call Download,lpac-gsma-ci-oiste))

endif

define Package/lpac
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=eUICC eSIM LPA written in C
  DEPENDS:= \
    +libcurl \
    +LPAC_WITH_PCSC:libpcsclite \
    +LPAC_WITH_PCSC:pcscd \
    +LPAC_WITH_MBIM:libmbim \
    +LPAC_WITH_QMI:libqmi \
    +LPAC_WITH_UQMI:uqmi \
    +LPAC_INSTALL_GSMA_CI_CERTS:ca-bundle
  URL:=https://github.com/estkme-group/lpac
endef

define Package/lpac/description
  lpac is a eUICC eSIM LPA manager written in C. It allows to
  manage eSIM profiles on eUICC SIM cards or modules using multiple
  backends.
endef

define Package/lpac/config
  source "$(SOURCE)/Config.in"
endef

define Package/lpac/conffiles
/etc/config/lpac
endef

TARGET_CFLAGS += $(FPIC)

# libqmi 1.35.4 or newer is required for QMI over QRTR
CMAKE_OPTIONS += \
  -DLPAC_WITH_APDU_PCSC=$(if $(CONFIG_LPAC_WITH_PCSC),ON,OFF) \
  -DLPAC_WITH_APDU_AT=$(if $(CONFIG_LPAC_WITH_AT),ON,OFF) \
  -DLPAC_WITH_APDU_UQMI=$(if $(CONFIG_LPAC_WITH_UQMI),ON,OFF) \
  -DLPAC_WITH_APDU_MBIM=$(if $(CONFIG_LPAC_WITH_MBIM),ON,OFF) \
  -DLPAC_WITH_APDU_QMI=$(if $(CONFIG_LPAC_WITH_QMI),ON,OFF) \
  -DLPAC_WITH_APDU_QMI_QRTR=OFF

define Package/lpac/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/lpac.sh $(1)/usr/bin/lpac

	$(INSTALL_DIR) $(1)/etc/config
	$(CP) ./files/lpac.uci $(1)/etc/config/lpac

	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/lpac $(1)/usr/lib/lpac

	ifdef CONFIG_LPAC_INSTALL_GSMA_CI_CERTS
		$(INSTALL_DIR) $(1)/usr/share/lpac/ca

		# Verizon/M2M31 Root CI is distributed as raw DER despite the
		# .txt extension; convert it to PEM.
		openssl x509 -inform DER -outform PEM \
			-in $(DL_DIR)/lpac-gsma-ci-m2m.der \
			-out $(1)/usr/share/lpac/ca/gsma-m2m-root-ci.pem

		# Symantec/RSPv2 Root CI is already PEM.
		$(INSTALL_DATA) $(DL_DIR)/lpac-gsma-ci-consumer.pem \
			$(1)/usr/share/lpac/ca/gsma-consumer-root-ci.pem

		# CI SIG OISTE is shipped as a zip; extract the included PEM.
		mkdir -p $(PKG_BUILD_DIR)/.gsma-ci-oiste
		unzip -o -j -d $(PKG_BUILD_DIR)/.gsma-ci-oiste \
			$(DL_DIR)/lpac-gsma-ci-oiste.zip
		$(INSTALL_DATA) $(PKG_BUILD_DIR)/.gsma-ci-oiste/CERT_CI_SIG_OISTE.pem \
			$(1)/usr/share/lpac/ca/gsma-oiste-root-ci.pem
	endif
endef

define Package/lpac/postinst
#!/bin/sh
CA_DIR="$${IPKG_INSTROOT}/usr/share/lpac/ca"
CA_BUNDLE="$${IPKG_INSTROOT}/etc/ssl/certs/ca-certificates.crt"

[ -d "$$CA_DIR" ] || exit 0
[ -f "$$CA_BUNDLE" ] || exit 0

for cert in "$$CA_DIR"/*.pem; do
	[ -f "$$cert" ] || continue
	name="$$(basename "$$cert")"
	marker_begin="# BEGIN lpac-gsma-ci $$name (auto-generated, do not edit)"
	marker_end="# END lpac-gsma-ci $$name"
	if ! grep -qF "$$marker_begin" "$$CA_BUNDLE" 2>/dev/null; then
		{
			echo "$$marker_begin"
			cat "$$cert"
			echo "$$marker_end"
		} >> "$$CA_BUNDLE"
	fi
done

exit 0
endef

define Package/lpac/postrm
#!/bin/sh
CA_BUNDLE="$${IPKG_INSTROOT}/etc/ssl/certs/ca-certificates.crt"

[ -f "$$CA_BUNDLE" ] || exit 0

for name in gsma-m2m-root-ci.pem gsma-consumer-root-ci.pem gsma-oiste-root-ci.pem; do
	marker_begin="# BEGIN lpac-gsma-ci $$name (auto-generated, do not edit)"
	marker_end="# END lpac-gsma-ci $$name"
	if grep -qF "$$marker_begin" "$$CA_BUNDLE" 2>/dev/null; then
		sed -i "/^$${marker_begin}$$/,/^$${marker_end}$$/d" "$$CA_BUNDLE"
	fi
done

exit 0
endef

$(eval $(call BuildPackage,lpac))
