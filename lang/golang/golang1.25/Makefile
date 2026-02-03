#
# Copyright (C) 2018-2023 Jeffery To
# Copyright (C) 2025-2026 George Sapkin
#
# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=golang1.25
GO_VERSION_MAJOR_MINOR:=1.25
GO_VERSION_PATCH:=6
GO_BOOTSTRAP_VERSION:=bootstrap
PKG_HASH:=58cbf771e44d76de6f56d19e33b77d745a1e489340922875e46585b975c2b059

PKG_VERSION:=$(GO_VERSION_MAJOR_MINOR)$(if $(GO_VERSION_PATCH),.$(GO_VERSION_PATCH))
PKG_RELEASE:=2

GO_SOURCE_URLS:=https://go.dev/dl/ \
                https://dl.google.com/go/ \
                https://golang.google.cn/dl/ \
                https://mirrors.nju.edu.cn/golang/ \
                https://mirrors.ustc.edu.cn/golang/

PKG_SOURCE:=go$(PKG_VERSION).src.tar.gz
PKG_SOURCE_URL:=$(GO_SOURCE_URLS)

PKG_MAINTAINER:=George Sapkin <george@sapk.in>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:golang:go

PKG_BUILD_DEPENDS:=$(PKG_NAME)/host
PKG_BUILD_DIR:=$(BUILD_DIR)/go-$(PKG_VERSION)
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

PKG_GO_PREFIX:=/usr
PKG_GO_VERSION_ID:=$(GO_VERSION_MAJOR_MINOR)

HOST_BUILD_DEPENDS:=golang$(if $(filter bootstrap,$(GO_BOOTSTRAP_VERSION)),-)$(GO_BOOTSTRAP_VERSION)/host
HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/go-$(PKG_VERSION)
HOST_BUILD_PARALLEL:=1

HOST_GO_VALID_OS_ARCH:= \
  android_386  android_amd64  android_arm  android_arm64 \
  freebsd_386  freebsd_amd64  freebsd_arm  freebsd_arm64 \
  linux_386    linux_amd64    linux_arm    linux_arm64 \
  openbsd_386  openbsd_amd64  openbsd_arm  openbsd_arm64 \
  netbsd_386   netbsd_amd64   netbsd_arm   netbsd_arm64 \
  windows_386  windows_amd64  windows_arm  windows_arm64 \
  \
  plan9_386    plan9_amd64    plan9_arm \
  \
  darwin_amd64 darwin_arm64 \
  ios_amd64    ios_arm64 \
  \
  dragonfly_amd64 \
  illumos_amd64 \
  solaris_amd64 \
  \
  aix_ppc64 \
  js_wasm \
  wasip1_wasm \
  \
  freebsd_riscv64 \
  openbsd_riscv64 \
  \
  linux_ppc64 linux_ppc64le \
  linux_mips linux_mipsle linux_mips64 linux_mips64le \
  linux_loong64 linux_riscv64 linux_s390x \
  \
  openbsd_mips64

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include ../golang-version.mk

$(eval $(call HostBuild))
$(eval $(call BuildPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)-doc))
$(eval $(call BuildPackage,$(PKG_NAME)-misc))
$(eval $(call BuildPackage,$(PKG_NAME)-src))
$(eval $(call BuildPackage,$(PKG_NAME)-tests))
