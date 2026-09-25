#!/bin/sh

[ "$1" = python3-pika ] || exit 0

python3 - << 'EOF'

import pika

# No broker required: parse an AMQP URL and build message properties, which
# exercises the URL parameter parser and the pika.spec frame classes.
p = pika.URLParameters("amqp://user:pass@host:5672/vhost")
assert p.host == "host" and p.port == 5672
assert p.credentials.username == "user"

props = pika.BasicProperties(content_type="text/plain", delivery_mode=2)
assert props.content_type == "text/plain" and props.delivery_mode == 2

EOF
