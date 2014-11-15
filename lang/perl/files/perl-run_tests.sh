#!/bin/sh

PERL_TESTSDIR="/usr/share/perl/perl-tests"
PERL_LIBDIR="/usr/lib/perl5/5.20/"
PERL_DISABLEDTESTS="%%PERL_DISABLEDTESTS%%"

if [ ! -f "$PERL_TESTSDIR/__prepared" ]; then
	ln -s "$PERL_LIBDIR" "$PERL_TESTSDIR/lib"
	ln -s /usr/bin/perl "$PERL_TESTSDIR/perl"
	ln -s /usr/bin/perl "$PERL_TESTSDIR/t/perl"
	touch "$PERL_TESTSDIR/__prepared"
	
	for i in $PERL_DISABLEDTESTS; do
		echo "Disabling $i tests"
		sed 's!^'$i'.*$!!' -i $PERL_TESTSDIR/MANIFEST
	done
	
	cat $PERL_TESTSDIR/MANIFEST | grep -v '^$' > $PERL_TESTSDIR/MANIFEST_NEW
	rm $PERL_TESTSDIR/MANIFEST
	mv $PERL_TESTSDIR/MANIFEST_NEW $PERL_TESTSDIR/MANIFEST
fi

cd "$PERL_TESTSDIR/t"
./perl TEST
