# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

GO_VERSION_MAJOR_MINOR:=1.23
GO_VERSION_PATCH:=12
PKG_HASH:=e1cce9379a24e895714a412c7ddd157d2614d9edbe83a84449b6e1840b4f1226

PKG_RELEASE:=1

BOOTSTRAP_VERSION_ID:=bootstrap

include ../golang-version.mk

$(eval $(call Go/AddVersion,$(BOOTSTRAP_VERSION_ID),$(GO_VERSION_MAJOR_MINOR),$(GO_VERSION_PATCH),$(PKG_HASH)))
$(eval $(call HostBuild))
$(eval $(call BuildPackage,golang$(GO_VERSION_MAJOR_MINOR)))
$(eval $(call BuildPackage,golang$(GO_VERSION_MAJOR_MINOR)-doc))
$(eval $(call BuildPackage,golang$(GO_VERSION_MAJOR_MINOR)-src))
