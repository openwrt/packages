#
# Copyright (C) 2018, 2020-2021, 2023 Jeffery To
# Copyright (C) 2025-2026 George Sapkin
#
# SPDX-License-Identifier: GPL-2.0-only

ifeq ($(origin GO_INCLUDE_DIR),undefined)
  GO_INCLUDE_DIR:=$(dir $(lastword $(MAKEFILE_LIST)))
endif

include $(GO_INCLUDE_DIR)/golang-values.mk


# 1: valid GOOS_GOARCH combinations
# 2: go version id
define GoCompiler/Default/CheckHost
	$(if $(filter $(GO_HOST_OS_ARCH),$(1)),,$(error go-$(2) cannot be installed on $(GO_HOST_OS)/$(GO_HOST_ARCH)))
endef

# 1: source go root
# 2: additional environment variables (optional)
define GoCompiler/Default/Make
	cd "$(1)/src" ; \
	$(2) $(BASH) make.bash \
		$(if $(findstring s,$(OPENWRT_VERBOSE)),-v) \
		--no-banner
endef

# 1: destination prefix
# 2: go version id
define GoCompiler/Default/Install/make-dirs
	$(INSTALL_DIR) "$(1)/lib/go-$(2)"
endef

# 1: source go root
# 2: destination prefix
# 3: go version id
# 4: file/directory name
# 5: filter (optional)
define GoCompiler/Default/Install/install-lib-data

  ifeq ($(5),)
	$(CP) "$(1)/$(4)" "$(2)/lib/go-$(3)/"
  else
	$(INSTALL_DIR) "$(2)/lib/go-$(3)/$(4)"; \
	cd "$(1)/$(4)" && \
	$(FIND) . ! -type d -a \( $(5) \) -print0 | \
	cpio \
		--make-directories \
		--null \
		--pass-through \
		--unconditional \
		"$(2)/lib/go-$(3)/$(4)/"
  endif
endef

# 1: source go root
# 2: destination prefix
# 3: go version id
# 4: GOOS_GOARCH with / as a separator
# 5: install suffix (optional)
# 6: if target, package architecture-specific sources
define GoCompiler/Default/Install/Bin
	$(call GoCompiler/Default/Install/make-dirs,$(2),$(3))

	$(call GoCompiler/Default/Install/install-lib-data,$(1),$(2),$(3),api)

	$(INSTALL_DATA) -p "$(1)/go.env" "$(2)/lib/go-$(3)/"
	$(INSTALL_DATA) -p "$(1)/VERSION" "$(2)/lib/go-$(3)/"

	for file in $(strip $(if $(filter target,$(6)),$(GO_BIN_FILES),$(GO_LEGAL_FILES))); do \
		if [ -f "$(1)/$$$$file" ]; then \
			$(INSTALL_DATA) -p "$(1)/$$$$file" "$(2)/lib/go-$(3)/" ; \
		fi ; \
	done

	$(INSTALL_DIR) "$(2)/lib/go-$(3)/bin"

	$(eval GO_HOST_OS_ARCH_PATH:=$(subst /,_,$(4)))

  ifeq ($(4),$(GO_HOST_OS_ARCH))
	$(INSTALL_BIN) -p "$(1)/bin"/* "$(2)/lib/go-$(3)/bin/"
  else
	$(INSTALL_BIN) -p "$(1)/bin/$(GO_HOST_OS_ARCH_PATH)"/* "$(2)/lib/go-$(3)/bin/"
  endif

	if [ -d "$(1)/pkg/$(GO_HOST_OS_ARCH_PATH)$(if $(5),_$(5))" ]; then \
		$(INSTALL_DIR) "$(2)/lib/go-$(3)/pkg" ; \
		$(CP) "$(1)/pkg/$(GO_HOST_OS_ARCH_PATH)$(if $(5),_$(5))" "$(2)/lib/go-$(3)/pkg/" ; \
	fi

	$(INSTALL_DIR) "$(2)/lib/go-$(3)/pkg/tool/$(GO_HOST_OS_ARCH_PATH)"
	$(INSTALL_BIN) -p "$(1)/pkg/tool/$(GO_HOST_OS_ARCH_PATH)"/* "$(2)/lib/go-$(3)/pkg/tool/$(GO_HOST_OS_ARCH_PATH)/"
endef

# 1: destination prefix
# 2: go version id
define GoCompiler/Default/Install/BinLinks
	$(INSTALL_DIR) "$(1)/bin"
	$(LN) "../lib/go-$(2)/bin/go" "$(1)/bin/go$(2)"
	$(LN) "../lib/go-$(2)/bin/gofmt" "$(1)/bin/gofmt$(2)"
endef

# 1: source go root
# 2: destination prefix
# 3: go version id
define GoCompiler/Default/Install/Doc
	$(call GoCompiler/Default/Install/make-dirs,$(2),$(3))

	$(call GoCompiler/Default/Install/install-lib-data,$(1),$(2),$(3),doc)
endef

# 1: source go root
# 2: destination prefix
# 3: go version id
define GoCompiler/Default/Install/Misc
	$(call GoCompiler/Default/Install/make-dirs,$(2),$(3))
	$(call GoCompiler/Default/Install/install-lib-data,$(1),$(2),$(3),misc)
endef

# 1: source go root
# 2: destination prefix
# 3: go version id
# 4: if target, package architecture-specific sources
define GoCompiler/Default/Install/Src
	$(call GoCompiler/Default/Install/make-dirs,$(2),$(3))
	$(call GoCompiler/Default/Install/install-lib-data,$(1),$(2),$(3),src,$(strip \
		$(if $(filter target,$(4)), \
			$(GO_TARGET_SRC_FILTERS), \
			$(GO_HOST_SRC_FILTERS) \
		) \
	))

	if [ -d "$(1)/pkg/include" ]; then \
		$(INSTALL_DIR) "$(2)/lib/go-$(3)/pkg" ; \
		$(CP) "$(1)/pkg/include" "$(2)/lib/go-$(3)/pkg/" ; \
	fi
endef

# 1: source go root
# 2: destination prefix
# 3: go version id
define GoCompiler/Default/Install/Tests
	$(call GoCompiler/Default/Install/make-dirs,$(2),$(3))
	$(call GoCompiler/Default/Install/install-lib-data,$(1),$(2),$(3),lib)
	$(call GoCompiler/Default/Install/install-lib-data,$(1),$(2),$(3),src,$(GO_TARGET_TEST_FILTERS))
	$(call GoCompiler/Default/Install/install-lib-data,$(1),$(2),$(3),test)
endef

# 1: destination prefix
# 2: go version id
define GoCompiler/Default/Uninstall
	rm -rf "$(1)/lib/go-$(2)"
endef

# 1: destination prefix
# 2: go version id
define GoCompiler/Default/Uninstall/BinLinks
	rm -f "$(1)/bin/go$(2)"
	rm -f "$(1)/bin/gofmt$(2)"
endef


# 1: profile name
# 2: source go root
# 3: destination prefix
# 4: go version id
# 5: GOOS_GOARCH with / as a separator
# 6: install suffix (optional)
define GoCompiler/AddProfile

  # 1: valid GOOS_GOARCH combinations
  define GoCompiler/$(1)/CheckHost
	$$(call GoCompiler/Default/CheckHost,$$(1),$(4))
  endef

  # 1: additional environment variables (optional)
  define GoCompiler/$(1)/Make
	$$(call GoCompiler/Default/Make,$(2),$$(1))
  endef

  # 1: override install prefix (optional)
  # 2: if target, package architecture-specific sources
  define GoCompiler/$(1)/Install/Bin
	$$(call GoCompiler/Default/Install/Bin,$(2),$$(or $$(1),$(3)),$(4),$(5),$(6),$$(2))
  endef

  # 1: override install prefix (optional)
  define GoCompiler/$(1)/Install/BinLinks
	$$(call GoCompiler/Default/Install/BinLinks,$$(or $$(1),$(3)),$(4))
  endef

  # 1: override install prefix (optional)
  define GoCompiler/$(1)/Install/Doc
	$$(call GoCompiler/Default/Install/Doc,$(2),$$(or $$(1),$(3)),$(4))
  endef

  # 1: override install prefix (optional)
  define GoCompiler/$(1)/Install/Misc
	$$(call GoCompiler/Default/Install/Misc,$(2),$$(or $$(1),$(3)),$(4))
  endef

  # 1: override install prefix (optional)
  # 2: if target, package architecture-specific sources
  define GoCompiler/$(1)/Install/Src
	$$(call GoCompiler/Default/Install/Src,$(2),$$(or $$(1),$(3)),$(4),$$(2))
  endef

  # 1: override install prefix (optional)
  define GoCompiler/$(1)/Install/Tests
	$$(call GoCompiler/Default/Install/Tests,$(2),$$(or $$(1),$(3)),$(4),$$(2))
  endef

  # 1: override install prefix (optional)
  define GoCompiler/$(1)/Uninstall
	$$(call GoCompiler/Default/Uninstall,$$(or $$(1),$(3)),$(4))
  endef

  # 1: override install prefix (optional)
  define GoCompiler/$(1)/Uninstall/BinLinks
	$$(call GoCompiler/Default/Uninstall/BinLinks,$$(or $$(1),$(3)),$(4))
  endef

endef
