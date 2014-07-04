#!/bin/sh
#
# Generate perl base modules package definitions
#
# Copyright (C) 2007  Peter Colberg <peter@petercolberg.org>
# Licensed under the terms of the GNU General Public License.
#

if [ $# -lt 1 ]; then
    echo >&2 "Usage: $(basename $0) STAGING-DIR [OUTFILE]"
    exit 1
fi

STAGING_DIR="$1"
PERL_BIN="$STAGING_DIR/usr/bin/perl"
PERL_LIB="$STAGING_DIR/usr/lib/perl5/5.10"
INC_DIR="$(dirname $0)"
shift

"$PERL_BIN" -I"$INC_DIR" -I"$PERL_LIB" - "$PERL_LIB" "$@" <<'PERL_SCRIPT'
use strict;
use warnings;

use Module::ScanDeps;
use File::Find;
use File::Basename;

our $skipfiles = 'CORE vmsish.pm auto/sdbm';

our %defmodules = (
    'essential' => 'lib.pm vars.pm strict.pm warnings.pm warnings Carp Carp.pm Exporter Exporter.pm locale.pm subs.pm overload.pm constant.pm',
    'getoptpl' => 'getopt.pl getopts.pl',
    'utf8' => 'utf8_heavy.pl',
    'Getopt' => 'newgetopt.pl',
    'open' => 'open2.pl open3.pl',
    'Config' => 'Config_heavy.pl',
    'bytes' => 'bytes_heavy.pl',
);

our %defdepends = (
    'DB_File' => 'libdb1-compat',
    'GDBM_File' => 'libgdbm',
);

our $prefix = 'perlbase-';

sub template ($) {
    $_ = $_[0];
    return <<TEMPLATE;
define Package/$$_{package}
SECTION:=lang
CATEGORY:=Languages
URL:=http://www.cpan.org/
TITLE:=$$_{module} perl module
DEPENDS:=$$_{depends}
endef

define Package/$$_{package}/install
\$(call perlmod/Install,\$(1),$$_{files},$$_{exclude})
endef

\$(eval \$(call BuildPackage,$$_{package}))


TEMPLATE
}


sub scandeps ($) {
    my $sitedir = shift;
    my @result;

    my ($mod, $file, @deps, $dep, %depends, $parent, $pkg);
    our (%files, %modules);
    my (%packages, %excludes);

    for $mod (keys %defmodules) {
	($pkg = $prefix . $mod) =~ tr/A-Z_/a-z-/;
	$modules{$pkg} = $mod;
	for $file (split / /, $defmodules{$mod}) {
	    $files{$file} = $pkg;
	}
    }
    for $file ('pod', 'Pod', split(/ /, $skipfiles)) {
	$files{$file} = undef;
    }

    sub wanted {
	s/^\.\///;
	return if (/^(\.|auto)$/ or exists $files{$_});
	if (/\.pod$/) {
	    $files{$_} = undef;
	}
	elsif (exists $files{dirname($_)}) {
	    $files{$_} = $files{dirname($_)};
	}
	elsif (m!^(?:auto/)?([^./]+)(?:\.(?:pl|pm)|/|$)!) {
	    (my $pkg = $prefix . $1) =~ tr/A-Z_/a-z-/;
	    $modules{$pkg} = $1;
	    $files{$_} = $pkg;
	}
	else {
	    $files{$_} = undef;
	}
    }
    chdir($sitedir);
    find({ wanted => \&wanted, no_chdir => 1}, '.');

    for $pkg (keys %modules) {
	$packages{$pkg} = [];
	$excludes{$pkg} = [];
	$depends{$pkg} = {};
    }

    for $file (keys %files) {
	$mod = $files{$file};
	$parent = $files{dirname($file)};

	if (defined ($mod)) {
	    if (defined ($parent) and not ($parent eq $mod)) {
		push @{$packages{$mod}}, $file;
		push @{$excludes{$parent}}, $file;
	    }
	    elsif (not defined ($parent)) {
		push @{$packages{$mod}}, $file;
	    }
	}
	elsif (defined ($parent)) {
	    push @{$excludes{$parent}}, $file;
	}
    }

    for $mod (keys %defdepends) {
	($pkg = $prefix . $mod) =~ tr/A-Z_/a-z-/;
	for $dep (split / /, $defdepends{$mod}) {
	    ${$depends{$pkg}}{$dep} = 1;
	}
    }

    @INC = ('.');
    for $file (grep { -f $_ and defined $files{$_} } keys %files) {
	@deps = keys %{scan_deps(files => [ $file ], recurse => 0)};
	$pkg = $files{$file};

	for $dep (grep { not defined $files{$_} } @deps) {
	    warn "$file: could not resolve dependency: $dep\n";
	}
	for $dep (grep { defined $files{$_} } @deps) {
	    next if ($files{$dep} eq $pkg);
	    ${$depends{$pkg}}{$files{$dep}} = 1;
	}
    }

    for $pkg (sort keys %packages) {
	push @result, template({
	    package => $pkg,
	    module => $modules{$pkg},
	    depends => join(' ', 'perl', sort keys %{$depends{$pkg}}),
	    files => join(' ', sort @{$packages{$pkg}}),
	    exclude => join(' ', sort @{$excludes{$pkg}}),
	});
    }

    return join('', @result);
}


if (@ARGV > 1) {
    open FILE, ">$ARGV[1]" or die "$ARGV[1]: $!\n";
    print FILE scandeps($ARGV[0]);
    close FILE;
}
else {
    print scandeps($ARGV[0] or '.');
}
PERL_SCRIPT
