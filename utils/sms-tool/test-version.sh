#!/bin/sh

# sms_tool has no version option; check that it runs and prints its usage.
sms_tool -? 2>&1 | grep "usage:"
