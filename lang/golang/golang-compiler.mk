#
# Copyright (C) 2018, 2020-2021, 2023 Jeffery To
#
# SPDX-License-Identifier: GPL-2.0-only

ifeq ($(origin GO_INCLUDE_DIR),undefined)
  GO_INCLUDE_DIR:=$(dir $(lastword $(MAKEFILE_LIST)))
endif

include $(GO_INCLUDE_DIR)/golang-values.mk


# $(1) valid GOOS_GOARCH combinations
# $(2) go version id
define GoCompiler/Default/CheckHost
	$(if $(filter $(GO_HOST_OS_ARCH),$(1)),,$(error go-$(2) cannot be installed on $(GO_HOST_OS)/$(GO_HOST_ARCH)))
endef

# $(1) source go root
# $(2) additional environment variables (optional)
define GoCompiler/Default/Make
	( \
		cd "$(1)/src" ; \
		$(2) \
		$(BASH) make.bash \
		$(if $(findstring s,$(OPENWRT_VERBOSE)),-v) \
		--no-banner \
		; \
	)
endef

# $(1) destination prefix
# $(2) go version id
define GoCompiler/Default/Install/make-dirs
	$(INSTALL_DIR) "$(1)/lib/go-$(2)"
	$(INSTALL_DIR) "$(1)/share/go-$(2)"
endef

# $(1) source go root
# $(2) destination prefix
# $(3) go version id
# $(4) file/directory name
define GoCompiler/Default/Install/install-share-data
	$(CP) "$(1)/$(4)" "$(2)/share/go-$(3)/"
	$(LN) "../../share/go-$(3)/$(4)" "$(2)/lib/go-$(3)/"
endef

# $(1) source go root
# $(2) destination prefix
# $(3) go version id
# $(4) GOOS_GOARCH
# $(5) install suffix (optional)
define GoCompiler/Default/Install/Bin
	$(call GoCompiler/Default/Install/make-dirs,$(2),$(3))

	$(call GoCompiler/Default/Install/install-share-data,$(1),$(2),$(3),api)

	$(INSTALL_DATA) -p "$(1)/go.env" "$(2)/lib/go-$(3)/"
	$(INSTALL_DATA) -p "$(1)/VERSION" "$(2)/lib/go-$(3)/"

	for file in CONTRIBUTING.md LICENSE PATENTS README.md SECURITY.md; do \
		if [ -f "$(1)/$$$$file" ]; then \
			$(INSTALL_DATA) -p "$(1)/$$$$file" "$(2)/share/go-$(3)/" ; \
		fi ; \
	done

	$(INSTALL_DIR) "$(2)/lib/go-$(3)/bin"

  ifeq ($(4),$(GO_HOST_OS_ARCH))
	$(INSTALL_BIN) -p "$(1)/bin"/* "$(2)/lib/go-$(3)/bin/"
  else
	$(INSTALL_BIN) -p "$(1)/bin/$(4)"/* "$(2)/lib/go-$(3)/bin/"
  endif

	if [ -d "$(1)/pkg/$(4)$(if $(5),_$(5))" ]; then \
		$(INSTALL_DIR) "$(2)/lib/go-$(3)/pkg" ; \
		$(CP) "$(1)/pkg/$(4)$(if $(5),_$(5))" "$(2)/lib/go-$(3)/pkg/" ; \
	fi

	$(INSTALL_DIR) "$(2)/lib/go-$(3)/pkg/tool/$(4)"
	$(INSTALL_BIN) -p "$(1)/pkg/tool/$(4)"/* "$(2)/lib/go-$(3)/pkg/tool/$(4)/"
endef

# $(1) destination prefix
# $(2) go version id
define GoCompiler/Default/Install/BinLinks
	$(INSTALL_DIR) "$(1)/bin"
	$(LN) "../lib/go-$(2)/bin/go" "$(1)/bin/go"
	$(LN) "../lib/go-$(2)/bin/gofmt" "$(1)/bin/gofmt"
endef

# $(1) source go root
# $(2) destination prefix
# $(3) go version id
define GoCompiler/Default/Install/Doc
	$(call GoCompiler/Default/Install/make-dirs,$(2),$(3))

	$(call GoCompiler/Default/Install/install-share-data,$(1),$(2),$(3),doc)
endef

# $(1) source go root
# $(2) destination prefix
# $(3) go version id
define GoCompiler/Default/Install/Src
	$(call GoCompiler/Default/Install/make-dirs,$(2),$(3))

	$(call GoCompiler/Default/Install/install-share-data,$(1),$(2),$(3),lib)
	$(call GoCompiler/Default/Install/install-share-data,$(1),$(2),$(3),misc)
	$(call GoCompiler/Default/Install/install-share-data,$(1),$(2),$(3),src)
	$(call GoCompiler/Default/Install/install-share-data,$(1),$(2),$(3),test)

	$(FIND) \
		"$(2)/share/go-$(3)/src/" \
		\! -type d -a \( -name "*.bat" -o -name "*.rc" \) \
		-delete

	if [ -d "$(1)/pkg/include" ]; then \
		$(INSTALL_DIR) "$(2)/lib/go-$(3)/pkg" ; \
		$(INSTALL_DIR) "$(2)/share/go-$(3)/pkg" ; \
		$(CP) "$(1)/pkg/include" "$(2)/share/go-$(3)/pkg/" ; \
		$(LN) "../../../share/go-$(3)/pkg/include" "$(2)/lib/go-$(3)/pkg/" ; \
	fi
endef

# $(1) destination prefix
# $(2) go version id
define GoCompiler/Default/Uninstall
	rm -rf "$(1)/lib/go-$(2)"
	rm -rf "$(1)/share/go-$(2)"
endef

# $(1) destination prefix
define GoCompiler/Default/Uninstall/BinLinks
	rm -f "$(1)/bin/go"
	rm -f "$(1)/bin/gofmt"
endef


# $(1) profile name
# $(2) source go root
# $(3) destination prefix
# $(4) go version id
# $(5) GOOS_GOARCH
# $(6) install suffix (optional)
define GoCompiler/AddProfile

  # $$(1) valid GOOS_GOARCH combinations
  define GoCompiler/$(1)/CheckHost
	$$(call GoCompiler/Default/CheckHost,$$(1),$(4))
  endef

  # $$(1) additional environment variables (optional)
  define GoCompiler/$(1)/Make
	$$(call GoCompiler/Default/Make,$(2),$$(1))
  endef

  # $$(1) override install prefix (optional)
  define GoCompiler/$(1)/Install/Bin
	$$(call GoCompiler/Default/Install/Bin,$(2),$$(or $$(1),$(3)),$(4),$(5),$(6))
  endef

  # $$(1) override install prefix (optional)
  define GoCompiler/$(1)/Install/BinLinks
	$$(call GoCompiler/Default/Install/BinLinks,$$(or $$(1),$(3)),$(4))
  endef

  # $$(1) override install prefix (optional)
  define GoCompiler/$(1)/Install/Doc
	$$(call GoCompiler/Default/Install/Doc,$(2),$$(or $$(1),$(3)),$(4))
  endef

  # $$(1) override install prefix (optional)
  define GoCompiler/$(1)/Install/Src
	$$(call GoCompiler/Default/Install/Src,$(2),$$(or $$(1),$(3)),$(4))
  endef

  # $$(1) override install prefix (optional)
  define GoCompiler/$(1)/Uninstall
	$$(call GoCompiler/Default/Uninstall,$$(or $$(1),$(3)),$(4))
  endef

  # $$(1) override install prefix (optional)
  define GoCompiler/$(1)/Uninstall/BinLinks
	$$(call GoCompiler/Default/Uninstall/BinLinks,$$(or $$(1),$(3)))
  endef

endef
