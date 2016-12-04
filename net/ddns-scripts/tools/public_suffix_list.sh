#!/bin/sh

URL="https://publicsuffix.org/list/public_suffix_list.dat"
TMPFILE=$(dirname $0)/public_suffix_list.tmp
DATFILE=$(dirname $0)/public_suffix_list.dat

wget -O $TMPFILE $URL || exit 1

# there might be backslashes (at line end they produce problems)
sed -i 's/\\//g' $TMPFILE

# clear DATFILE if exist
printf %s "" > $DATFILE
L=0; M=0
export CHARSET=UTF-8	# needed for idn
cat ${TMPFILE} | while read LINE; do
	L=$(( L + 1 ))
	printf "\\r\\t%s\\t%s" "in: $L   " "out: $(( $L + $M ))   "
	printf %s\\n "$LINE" | grep -E "^\/\/" >/dev/null 2>&1 && {
		# do not modify lines beginning with "//"
		printf %s\\n "$LINE" >> $DATFILE
		continue
	}
	printf %s\\n "$LINE" | grep -E "^$" >/dev/null 2>&1 && {
		# do not modify empty lines
		printf %s\\n "$LINE" >> $DATFILE
		continue
	}
	ASCII=$(idn -a "$LINE")	# write ASCII and UTF-8
	if [ "$ASCII" != "$LINE" ]; then
		printf %s\\n "$ASCII" >> $DATFILE
		printf "\\t%s\\n" "add: $ASCII"
		M=$(( M + 1 ))
	fi
	printf %s\\n "$LINE" >> $DATFILE
done
rm -f $TMPFILE
gzip -f9 $DATFILE

