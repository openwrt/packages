#!/bin/sh

[ "$1" = python3-pyasn1 ] || exit 0

python3 - << 'EOF'

from collections import OrderedDict

from pyasn1.type import namedtype
from pyasn1.type import tag
from pyasn1.type import univ
from pyasn1.codec.der.encoder import encode as derEncode
from pyasn1.codec.der.decoder import decode as derDecode
from pyasn1.codec.native.encoder import encode as nativeEncode
from pyasn1.codec.native.decoder import decode as nativeDecode

class Record(univ.Sequence):
    componentType = namedtype.NamedTypes(
        namedtype.NamedType('id', univ.Integer()),
        namedtype.OptionalNamedType(
            'room', univ.Integer().subtype(
                implicitTag=tag.Tag(tag.tagClassContext, tag.tagFormatSimple, 0)
            )
        ),
        namedtype.DefaultedNamedType(
            'house', univ.Integer(0).subtype(
                implicitTag=tag.Tag(tag.tagClassContext, tag.tagFormatSimple, 1)
            )
        )
    )

# encoding modifies the object (https://github.com/pyasn1/pyasn1/issues/53)
# so test decoding before encoding

record = Record()
record['id'] = 123
record['room'] = 321
assert str(record) == 'Record:\n id=123\n room=321\n'

substrate = b'0\x07\x02\x01{\x80\x02\x01A'

received_record, _ = derDecode(substrate, asn1Spec=Record())
assert received_record == record

dict_record = nativeDecode({'id': 123, 'room': 321}, asn1Spec=Record())
assert dict_record == record

assert derEncode(record) == substrate
assert nativeEncode(record) == OrderedDict([('id', 123), ('room', 321), ('house', 0)])

EOF
