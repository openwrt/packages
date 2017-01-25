#!/bin/sh

cd `dirname "$0"`/tests
../tap/runtests -b /tmp ./contrib/test_* ./dnssec/test_* ./libknot/test_* ./modules/test_* ./utils/test_* ./test_*
ret=$?
cd -

return $ret
