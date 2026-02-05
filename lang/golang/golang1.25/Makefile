#
# Copyright (C) 2018-2023 Jeffery To
# Copyright (C) 2025-2026 George Sapkin
#
# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=golang1.25
GO_VERSION_MAJOR_MINOR:=1.25
GO_VERSION_PATCH:=7
GO_VERSION_RC:=
GO_BOOTSTRAP_VERSION:=bootstrap
PKG_HASH:=178f2832820274b43e177d32f06a3ebb0129e427dd20a5e4c88df2c1763cf10a

PKG_VERSION:=$(GO_VERSION_MAJOR_MINOR)$(if $(GO_VERSION_RC),.0)$(if $(GO_VERSION_PATCH),.$(GO_VERSION_PATCH))
PKG_FILE_VERSION:=$(GO_VERSION_MAJOR_MINOR)$(if $(GO_VERSION_RC),rc$(GO_VERSION_RC))$(if $(GO_VERSION_PATCH),.$(GO_VERSION_PATCH))
PKG_RELEASE:=1

GO_SOURCE_URLS:=https://go.dev/dl/ \
                https://dl.google.com/go/ \
                https://golang.google.cn/dl/ \
                https://mirrors.nju.edu.cn/golang/ \
                https://mirrors.ustc.edu.cn/golang/

PKG_SOURCE:=go$(PKG_FILE_VERSION).src.tar.gz
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

# From go tool dist list
HOST_GO_VALID_OS_ARCH:= \
  aix/ppc64 \
  android/386 \
  android/amd64 \
  android/arm \
  android/arm64 \
  darwin/amd64 \
  darwin/arm64 \
  dragonfly/amd64 \
  freebsd/386 \
  freebsd/amd64 \
  freebsd/arm \
  freebsd/arm64 \
  freebsd/riscv64 \
  illumos/amd64 \
  ios/amd64 \
  ios/arm64 \
  js/wasm \
  linux/386 \
  linux/amd64 \
  linux/arm \
  linux/arm64 \
  linux/loong64 \
  linux/mips \
  linux/mips64 \
  linux/mips64le \
  linux/mipsle \
  linux/ppc64 \
  linux/ppc64le \
  linux/riscv64 \
  linux/s390x \
  netbsd/386 \
  netbsd/amd64 \
  netbsd/arm \
  netbsd/arm64 \
  openbsd/386 \
  openbsd/amd64 \
  openbsd/arm \
  openbsd/arm64 \
  openbsd/ppc64 \
  plan9/386 \
  plan9/amd64 \
  plan9/arm \
  solaris/amd64 \
  wasip1/wasm \
  windows/386 \
  windows/amd64 \
  windows/arm \
  windows/arm64

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include ../golang-version.mk

$(eval $(call HostBuild))
$(eval $(call BuildPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)-doc))
$(eval $(call BuildPackage,$(PKG_NAME)-misc))
$(eval $(call BuildPackage,$(PKG_NAME)-src))
$(eval $(call BuildPackage,$(PKG_NAME)-tests))
