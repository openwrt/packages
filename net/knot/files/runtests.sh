#!/bin/sh

cd `dirname "$0"`/tests
../tap/runtests -b /tmp ./dnssec_test_* ./test_*
ret=$?
cd -

return $ret
