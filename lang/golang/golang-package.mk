#
# Copyright (C) 2018 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

ifeq ($(origin GO_INCLUDE_DIR),undefined)
  GO_INCLUDE_DIR:=$(dir $(lastword $(MAKEFILE_LIST)))
endif

include $(GO_INCLUDE_DIR)/golang-values.mk


# Variables (all optional, except GO_PKG) to be set in package
# Makefiles:
#
# GO_PKG (required) - name of Go package
#
#   Go name of the package.
#
#   e.g. GO_PKG:=golang.org/x/text
#
#
# GO_PKG_INSTALL_EXTRA - list of regular expressions, default empty
#
#   Additional files/directories to install. By default, only these
#   files are installed:
#
#   * Files with one of these extensions:
#     .go, .c, .cc, .cpp, .h, .hh, .hpp, .proto, .s
#
#   * Files in any 'testdata' directory
#
#   * go.mod and go.sum, in any directory
#
#   e.g. GO_PKG_INSTALL_EXTRA:=example.toml marshal_test.toml
#
#
# GO_PKG_INSTALL_ALL - boolean (0 or 1), default false
#
#   If true, install all files regardless of extension or directory.
#
#   e.g. GO_PKG_INSTALL_ALL:=1
#
#
# GO_PKG_SOURCE_ONLY - boolean (0 or 1), default false
#
#   If true, 'go install' will not be called. If the package does not
#   (or should not) build any binaries, then specifying this option will
#   save build time.
#
#   e.g. GO_PKG_SOURCE_ONLY:=1
#
#
# GO_PKG_BUILD_PKG - list of build targets, default GO_PKG/...
#
#   Build targets for compiling this Go package, i.e. arguments passed
#   to 'go install'
#
#   e.g. GO_PKG_BUILD_PKG:=github.com/debian/ratt/cmd/...
#
#
# GO_PKG_EXCLUDES - list of regular expressions, default empty
#
#   Patterns to exclude from the build targets expanded from
#   GO_PKG_BUILD_PKG.
#
#   e.g. GO_PKG_EXCLUDES:=examples/
#
#
# GO_PKG_GO_GENERATE - boolean (0 or 1), default false
#
#   If true, 'go generate' will be called on all build targets (as
#   determined by GO_PKG_BUILD_PKG and GO_PKG_EXCLUDES). This is usually
#   not necessary.
#
#   e.g. GO_PKG_GO_GENERATE:=1
#
#
# GO_PKG_GCFLAGS - list of arguments, default empty
#
#   Additional go tool compile arguments to use when building targets.
#
#   e.g. GO_PKG_GCFLAGS:=-N -l
#
#
# GO_PKG_LDFLAGS - list of arguments, default empty
#
#   Additional go tool link arguments to use when building targets.
#
#   e.g. GO_PKG_LDFLAGS:=-s -w
#
#
# GO_PKG_LDFLAGS_X - list of string variable definitions, default empty
#
#   Each definition will be passed as the parameter to the -X go tool
#   link argument, i.e. -ldflags "-X importpath.name=value"
#
#   e.g. GO_PKG_LDFLAGS_X:=main.Version=$(PKG_VERSION) main.BuildStamp=$(SOURCE_DATE_EPOCH)

# Credit for this package build process (GoPackage/Build/Configure and
# GoPackage/Build/Compile) belong to Debian's dh-golang completely.
# https://salsa.debian.org/go-team/packages/dh-golang


# for building packages, not user code
GO_PKG_PATH:=/usr/share/gocode

GO_PKG_BUILD_PKG?=$(GO_PKG)/...

GO_PKG_WORK_DIR_NAME:=.go_work
GO_PKG_WORK_DIR:=$(PKG_BUILD_DIR)/$(GO_PKG_WORK_DIR_NAME)

GO_PKG_BUILD_DIR:=$(GO_PKG_WORK_DIR)/build
GO_PKG_CACHE_DIR:=$(GO_PKG_WORK_DIR)/cache

GO_PKG_BUILD_BIN_DIR:=$(GO_PKG_BUILD_DIR)/bin$(if \
  $(GO_HOST_TARGET_DIFFERENT),/$(GO_OS)_$(GO_ARCH))

GO_PKG_BUILD_DEPENDS_SRC:=$(STAGING_DIR)$(GO_PKG_PATH)/src

# sstrip causes corrupted section header size
ifneq ($(CONFIG_USE_SSTRIP),)
  ifneq ($(CONFIG_DEBUG),)
    GO_PKG_STRIP_ARGS:=--strip-unneeded --remove-section=.comment --remove-section=.note
  else
    GO_PKG_STRIP_ARGS:=--strip-all
  endif
  STRIP:=$(TARGET_CROSS)strip $(GO_PKG_STRIP_ARGS)
  RSTRIP= \
    export CROSS="$(TARGET_CROSS)" \
		$(if $(PKG_BUILD_ID),KEEP_BUILD_ID=1) \
		$(if $(CONFIG_KERNEL_KALLSYMS),NO_RENAME=1) \
		$(if $(CONFIG_KERNEL_PROFILING),KEEP_SYMBOLS=1); \
    NM="$(TARGET_CROSS)nm" \
    STRIP="$(STRIP)" \
    STRIP_KMOD="$(SCRIPT_DIR)/strip-kmod.sh" \
    PATCHELF="$(STAGING_DIR_HOST)/bin/patchelf" \
    $(SCRIPT_DIR)/rstrip.sh
endif

define GoPackage/GoSubMenu
  SUBMENU:=Go
  SECTION:=lang
  CATEGORY:=Languages
endef

define GoPackage/Environment/Default
	GOOS=$(GO_OS) \
	GOARCH=$(GO_ARCH) \
	GO386=$(GO_386) \
	GOARM=$(GO_ARM) \
	GOMIPS=$(GO_MIPS) \
	GOMIPS64=$(GO_MIPS64) \
	CGO_ENABLED=1 \
	CGO_CFLAGS="$(filter-out $(GO_CFLAGS_TO_REMOVE),$(TARGET_CFLAGS))" \
	CGO_CPPFLAGS="$(TARGET_CPPFLAGS)" \
	CGO_CXXFLAGS="$(filter-out $(GO_CFLAGS_TO_REMOVE),$(TARGET_CXXFLAGS))"
endef

GoPackage/Environment=$(call GoPackage/Environment/Default,)

# false if directory does not exist
GoPackage/is_dir_not_empty=$$$$($(FIND) $(1) -maxdepth 0 -type d \! -empty 2>/dev/null)

GoPackage/has_binaries=$(call GoPackage/is_dir_not_empty,$(GO_PKG_BUILD_BIN_DIR))

define GoPackage/Build/Configure
	( \
		cd $(PKG_BUILD_DIR) ; \
		mkdir -p $(GO_PKG_BUILD_DIR)/bin $(GO_PKG_BUILD_DIR)/src $(GO_PKG_CACHE_DIR) ; \
		\
		files=$$$$($(FIND) ./ \
			-type d -a \( -path './.git' -o -path './$(GO_PKG_WORK_DIR_NAME)' \) -prune -o \
			\! -type d -print | \
			sed 's|^\./||') ; \
		\
		if [ "$(GO_PKG_INSTALL_ALL)" != 1 ]; then \
			code=$$$$(echo "$$$$files" | grep '\.\(c\|cc\|cpp\|go\|h\|hh\|hpp\|proto\|s\)$$$$') ; \
			testdata=$$$$(echo "$$$$files" | grep '\(^\|/\)testdata/') ; \
			gomod=$$$$(echo "$$$$files" | grep '\(^\|/\)go\.\(mod\|sum\)$$$$') ; \
			\
			for pattern in $(GO_PKG_INSTALL_EXTRA); do \
				extra=$$$$(echo "$$$$extra"; echo "$$$$files" | grep "$$$$pattern") ; \
			done ; \
			\
			files=$$$$(echo "$$$$code"; echo "$$$$testdata"; echo "$$$$gomod"; echo "$$$$extra") ; \
			files=$$$$(echo "$$$$files" | grep -v '^[[:space:]]*$$$$' | sort -u) ; \
		fi ; \
		\
		IFS=$$$$'\n' ; \
		\
		echo "Copying files from $(PKG_BUILD_DIR) into $(GO_PKG_BUILD_DIR)/src/$(GO_PKG)" ; \
		for file in $$$$files; do \
			echo $$$$file ; \
			dest=$(GO_PKG_BUILD_DIR)/src/$(GO_PKG)/$$$$file ; \
			mkdir -p $$$$(dirname $$$$dest) ; \
			$(CP) $$$$file $$$$dest ; \
		done ; \
		echo ; \
		\
		link_contents() { \
			local src=$$$$1 ; \
			local dest=$$$$2 ; \
			local dirs dir base ; \
			\
			if [ -n "$$$$($(FIND) $$$$src -mindepth 1 -maxdepth 1 -name '*.go' \! -type d)" ]; then \
				echo "$$$$src is already a Go library" ; \
				return 1 ; \
			fi ; \
			\
			dirs=$$$$($(FIND) $$$$src -mindepth 1 -maxdepth 1 -type d) ; \
			for dir in $$$$dirs; do \
				base=$$$$(basename $$$$dir) ; \
				if [ -d $$$$dest/$$$$base ]; then \
					case $$$$dir in \
					*$(GO_PKG_PATH)/src/$(GO_PKG)) \
						echo "$(GO_PKG) is already installed. Please check for circular dependencies." ;; \
					*) \
						link_contents $$$$src/$$$$base $$$$dest/$$$$base ;; \
					esac ; \
				else \
					echo "...$$$${src#$(GO_PKG_BUILD_DEPENDS_SRC)}/$$$$base" ; \
					$(LN) $$$$src/$$$$base $$$$dest/$$$$base ; \
				fi ; \
			done ; \
		} ; \
		\
		if [ "$(GO_PKG_SOURCE_ONLY)" != 1 ]; then \
			if [ -d $(GO_PKG_BUILD_DEPENDS_SRC) ]; then \
				echo "Symlinking directories from $(GO_PKG_BUILD_DEPENDS_SRC) into $(GO_PKG_BUILD_DIR)/src" ; \
				link_contents $(GO_PKG_BUILD_DEPENDS_SRC) $(GO_PKG_BUILD_DIR)/src ; \
			else \
				echo "$(GO_PKG_BUILD_DEPENDS_SRC) does not exist, skipping symlinks" ; \
			fi ; \
		else \
			echo "Not building binaries, skipping symlinks" ; \
		fi ; \
		echo ; \
	)
endef

# $(1) additional arguments for go command line (optional)
define GoPackage/Build/Compile
	( \
		cd $(GO_PKG_BUILD_DIR) ; \
		export GOPATH=$(GO_PKG_BUILD_DIR) \
			GOCACHE=$(GO_PKG_CACHE_DIR) \
			GOENV=off \
			GOROOT_FINAL=$(GO_TARGET_ROOT) \
			CC=$(TARGET_CC) \
			CXX=$(TARGET_CXX) \
			$(call GoPackage/Environment) ; \
		\
		echo "Finding targets" ; \
		targets=$$$$(go list $(GO_PKG_BUILD_PKG)) ; \
		for pattern in $(GO_PKG_EXCLUDES); do \
			targets=$$$$(echo "$$$$targets" | grep -v "$$$$pattern") ; \
		done ; \
		echo ; \
		\
		if [ "$(GO_PKG_GO_GENERATE)" = 1 ]; then \
			echo "Calling go generate" ; \
			go generate -v $(1) $$$$targets ; \
			echo ; \
		fi ; \
		\
		if [ "$(GO_PKG_SOURCE_ONLY)" != 1 ]; then \
			echo "Building targets" ; \
			case $(GO_ARCH) in \
			arm)             installsuffix="v$(GO_ARM)" ;; \
			mips|mipsle)     installsuffix="$(GO_MIPS)" ;; \
			mips64|mips64le) installsuffix="$(GO_MIPS64)" ;; \
			esac ; \
			ldflags="-linkmode external -extldflags '$(TARGET_LDFLAGS:-z%=-Wl,-z,%)'" ; \
			pkg_gcflags="$(GO_PKG_GCFLAGS)" ; \
			pkg_ldflags="$(GO_PKG_LDFLAGS)" ; \
			for def in $(GO_PKG_LDFLAGS_X); do \
				pkg_ldflags="$$$$pkg_ldflags -X $$$$def" ; \
			done ; \
			go install \
				$$$${installsuffix:+-installsuffix $$$$installsuffix} \
				-trimpath \
				-ldflags "all=$$$$ldflags" \
				-v \
				$$$${pkg_gcflags:+-gcflags "$$$$pkg_gcflags"} \
				$$$${pkg_ldflags:+-ldflags "$$$$pkg_ldflags $$$$ldflags"} \
				$(1) \
				$$$$targets ; \
			retval=$$$$? ; \
			echo ; \
			\
			if [ "$$$$retval" -eq 0 ] && [ -z "$(call GoPackage/has_binaries)" ]; then \
				echo "No binaries were generated, consider adding GO_PKG_SOURCE_ONLY:=1 to Makefile" ; \
				echo ; \
			fi ; \
			\
			echo "Cleaning module download cache (golang/go#27455)" ; \
			go clean -modcache ; \
			echo ; \
		fi ; \
		exit $$$$retval ; \
	)
endef

define GoPackage/Build/InstallDev
	$(call GoPackage/Package/Install/Src,$(1))
endef

define GoPackage/Package/Install/Bin
	if [ -n "$(call GoPackage/has_binaries)" ]; then \
		$(INSTALL_DIR) $(1)/usr/bin ; \
		$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/* $(1)/usr/bin/ ; \
	fi
endef

define GoPackage/Package/Install/Src
	dir=$$$$(dirname $(GO_PKG)) ; \
	$(INSTALL_DIR) $(1)$(GO_PKG_PATH)/src/$$$$dir ; \
	$(CP) $(GO_PKG_BUILD_DIR)/src/$(GO_PKG) $(1)$(GO_PKG_PATH)/src/$$$$dir/
endef

define GoPackage/Package/Install
	$(call GoPackage/Package/Install/Bin,$(1))
	$(call GoPackage/Package/Install/Src,$(1))
endef


ifneq ($(GO_PKG),)
  Build/Configure=$(call GoPackage/Build/Configure)
  Build/Compile=$(call GoPackage/Build/Compile)
  Build/InstallDev=$(call GoPackage/Build/InstallDev,$(1))
endif

define GoPackage
  ifndef Package/$(1)/install
    Package/$(1)/install=$$(call GoPackage/Package/Install,$$(1))
  endif
endef

define GoBinPackage
  ifndef Package/$(1)/install
    Package/$(1)/install=$$(call GoPackage/Package/Install/Bin,$$(1))
  endif
endef

define GoSrcPackage
  ifndef Package/$(1)/install
    Package/$(1)/install=$$(call GoPackage/Package/Install/Src,$$(1))
  endif
endef
