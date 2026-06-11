#!/bin/sh

[ "$1" = python3-idna ] || exit 0

python3 - << 'EOF'

import idna
import idna.codec

assert idna.encode('ドメイン.テスト') == b'xn--eckwd4c7c.xn--zckzah'
assert idna.decode('xn--eckwd4c7c.xn--zckzah') == 'ドメイン.テスト'

assert 'домен.испытание'.encode('idna2008') == b'xn--d1acufc.xn--80akhbyknj4f'
assert b'xn--d1acufc.xn--80akhbyknj4f'.decode('idna2008') == 'домен.испытание'

assert idna.alabel('测试') == b'xn--0zwm56d'

assert idna.encode('Königsgäßchen', uts46=True) == b'xn--knigsgchen-b4a3dun'
assert idna.decode('xn--knigsgchen-b4a3dun') == 'königsgäßchen'

assert idna.encode('Königsgäßchen', uts46=True, transitional=True) == b'xn--knigsgsschen-lcb0w'

EOF
