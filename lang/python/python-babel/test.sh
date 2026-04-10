#!/bin/sh
[ "$1" = python3-babel ] || exit 0
python3 - << 'EOF'
import babel
assert babel.__version__, "babel version is empty"

from babel import Locale
from babel.dates import format_date, format_datetime
from babel.numbers import format_number, format_currency
import datetime

locale = Locale.parse("en_US")
assert locale.territory == "US"

d = datetime.date(2024, 1, 15)
formatted = format_date(d, locale="en_US")
assert "2024" in formatted, f"date format missing year: {formatted}"

n = format_number(1234567.89, locale="en_US")
assert "1,234,567" in n, f"number format unexpected: {n}"

c = format_currency(9.99, "USD", locale="en_US")
assert "$" in c or "USD" in c, f"currency format unexpected: {c}"
EOF
