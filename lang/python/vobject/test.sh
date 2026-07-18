#!/bin/sh

[ "$1" = python3-vobject ] || exit 0

python3 - << 'EOF'
import vobject

# Upstream declares pytz and six as hard runtime requirements, so make sure
# both resolve; a missing pytz is what broke the change_tz console script.
import pytz
import six
from dateutil import tz

# Parse a simple vCard
vcard_text = """BEGIN:VCARD
VERSION:3.0
FN:John Doe
N:Doe;John;;;
EMAIL:john@example.com
END:VCARD
"""
vcard = vobject.readOne(vcard_text)
assert vcard.fn.value == "John Doe"
assert vcard.email.value == "john@example.com"

# Parse a simple iCalendar
ical_text = """BEGIN:VCALENDAR
VERSION:2.0
BEGIN:VEVENT
SUMMARY:Test Event
DTSTART:20260101T120000Z
DTEND:20260101T130000Z
END:VEVENT
END:VCALENDAR
"""
cal = vobject.readOne(ical_text)
events = list(cal.vevent_list)
assert len(events) == 1
assert events[0].summary.value == "Test Event"

# Verify change_tz imports (requires pytz)
from vobject.change_tz import change_tz

print("python3-vobject OK")
EOF
