This package allows users to package python modules without creating package
Makefiles for each individual module and their dependencies.  It provides a
way making packaging python packages faster and may also facilitate the process
of developing Makefiles for new python packages

This is a raw DEVEL only package.  Using it may entail a lot of implementation
details and you may need to resolve target dependencies and package details on
your own

- Third party python packages may depend on features not included in e.g.
  python-light
- Some python modules may require host install of another module to progress,
  e.g. target cryptography requires host cffi
- Some python modules have external C library dependencies, e.g. pyOpenSSL
  requires openssl libs
- Some packages may have an autoconf configure script whose arguments we
  cannot control with pip and has to be passed on (hacked) by overriding some
  environment variables

## How it works

1. Install host modules required for building target modules
2. Install each target module to separate directories
3. Install another copy of modules for cleanup purposes to make list of
   installed files to be removed from target modules installed in step 2

Why should it be so

1. Installing target cryptography requires host installation of cffi module
2. cryptography requires setuptools and pip will install its own copy with
   --ignore-installed.  When PACKAGE_python-setuptools is also selected, opkg
   will complain of data file clashes if it was not removed here.

Pip will handle dependency requirements of python modules, but external
dependencies like c libraries has to be prepared by the build system.  The
issue is that there is currently no way to express such dependencies, thus may
cause build failure, e.g. pycrypto requires the presence of libgmp to build
successfully.

## Tips

If something goes wrong, we can add additional arguments to pip command
line to check the detailed build process.  Some useful arguments may be

- -v, for verbose output.  Repeat this option if the current level of
  verbosity is not enough
- --no-clean, for preserving pip build dir on build failure

## Examples

tornado (python-only module)

	CONFIG_PACKAGE_python-packages=y
	CONFIG_PACKAGE_python-packages-list="tornado==4.4.2"

cryptography (requires installation of host modules and cleanup on target modules)

	CONFIG_PACKAGE_python-packages=y
	CONFIG_PACKAGE_python-packages-list-host="cffi"
	CONFIG_PACKAGE_python-packages-list="cryptography"
	CONFIG_PACKAGE_python-packages-list-cleanup="setuptools"

pycrypto 2.7a1 (python module with autoconf configure script; depends on
libgmp; broken wmmintrin.h).  2.6.1 does not work because of a flaw in
the setup.py hardcoding host include directory

	CONFIG_PACKAGE_libgmp=y
	CONFIG_PACKAGE_python-packages=y
	CONFIG_PACKAGE_python-packages-list="https://github.com/dlitz/pycrypto/archive/v2.7a1.tar.gz"
	CONFIG_PACKAGE_python-packages-envs="ac_cv_header_wmmintrin_h=no build_alias=$(GNU_HOST_NAME) host_alias=$(GNU_TARGET_NAME) target_alias=$(GNU_TARGET_NAME)"
	CONFIG_PACKAGE_python-packages-extra-deps="libgmp.so.10"

