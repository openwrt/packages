# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

GO_VERSION_MAJOR_MINOR:=1.25
GO_VERSION_PATCH:=5
PKG_HASH:=22a5fd0a91efcd28a1b0537106b9959b2804b61f59c3758b51e8e5429c1a954f

PKG_RELEASE:=2

BOOTSTRAP_VERSION_ID:=bootstrap

include ../golang-version.mk

$(eval $(call Go/AddVersion,$(BOOTSTRAP_VERSION_ID),$(GO_VERSION_MAJOR_MINOR),$(GO_VERSION_PATCH),$(PKG_HASH)))
$(eval $(call HostBuild))
$(eval $(call BuildPackage,golang$(GO_VERSION_MAJOR_MINOR)))
$(eval $(call BuildPackage,golang$(GO_VERSION_MAJOR_MINOR)-doc))
$(eval $(call BuildPackage,golang$(GO_VERSION_MAJOR_MINOR)-src))
