#!/bin/sh
[ "$1" = python3-xmltodict ] || exit 0

python3 - << 'EOF'
import xmltodict

# Basic XML to dict conversion
xml = """<root>
    <name>test</name>
    <value>42</value>
    <items>
        <item>a</item>
        <item>b</item>
    </items>
</root>"""
data = xmltodict.parse(xml)
assert data['root']['name'] == 'test'
assert data['root']['value'] == '42'
assert isinstance(data['root']['items']['item'], list)
assert data['root']['items']['item'] == ['a', 'b']

# Dict to XML conversion
d = {'doc': {'title': 'Hello', 'body': 'World'}}
result = xmltodict.unparse(d)
assert '<title>Hello</title>' in result
assert '<body>World</body>' in result

print("xmltodict OK")
EOF
