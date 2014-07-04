#!/bin/sh
#
# Generate perl module package dependencies
#
# Copyright (C) 2007  Peter Colberg <peter@petercolberg.org>
# Licensed under the terms of the GNU General Public License.
#

if [ $# -lt 3 ]; then
    echo >&2 "Usage: $(basename $0) STAGING-DIR PERL-BUILD-DIR [FILES...] [DIRECTORIES...]"
    exit 1
fi

STAGING_DIR="$1"
PERL_BIN="$STAGING_DIR/usr/bin/perl"
PERL_LIB="$STAGING_DIR/usr/lib/perl5/5.10"
INC_DIR="$(dirname $0)"
shift

"$PERL_BIN" -I"$INC_DIR" -I"$PERL_LIB" - "$@" <<'PERL_SCRIPT'
use strict;
use warnings;

use Module::ScanDeps;
use File::Find;
use Cwd;

our $sitelib = "/usr/lib/perl5/5.10";

sub scandeps {
    my $builddir = Cwd::abs_path(shift);
    my @scanpaths = @_;
    my ($curdir, @pkgdirs, $dir, @deps, %depends, $file);
    our ($pkg, %bundles, $path, @files);

    @pkgdirs = glob($builddir . "/*/ipkg");
    $curdir = getcwd();
    @INC = ();
    for $dir (@pkgdirs) {
	chdir($dir) or die "$dir: $!";
	for $pkg (glob("*")) {
	    chdir($dir . "/" . $pkg . $sitelib) or next;
	    push @INC, getcwd();
	    sub wanted {
		return unless (-f $_);
		s/^\.\///;
		$bundles{$_} = $pkg;
	    }
	    find({ wanted => \&wanted, no_chdir => 1 }, ".");
	}
    }
    chdir($curdir) or die "$curdir: $!\n";

    for $path (@scanpaths) {
	sub scan_wanted {
	    return unless (-f $_ and /\.(pl|pm)$/);
	    push @files, $_;
	}
	if (-f $path) {
	    push @files, $path;
	}
	elsif (-d $path) {
	    find({ wanted => \&scan_wanted, no_chdir => 1 }, $path);
	}
    }

    @deps = keys %{scan_deps(files => \@files, recurse => 0)};
    for $file (grep { not exists $bundles{$_} } @deps) {
	warn "could not resolve dependency: $file\n";
    }
    %depends = map { $bundles{$_}, 1 } grep { exists $bundles{$_} } @deps;

    if (%depends) {
	print join(' ', 'perl', sort keys %depends), "\n";
    }
}

if (@ARGV > 1) {
    scandeps(@ARGV);
}
PERL_SCRIPT
