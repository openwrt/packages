#!/bin/sh

[ "$1" = "python3-schedule" ] || exit 0

python3 - << EOF
import sys
import schedule

if schedule.__version__ != "$2":
    print("Wrong version: " + schedule.__version__)
    sys.exit(1)

# Verify core scheduling API
results = []

def job():
    results.append(1)

# Schedule a job and verify it is registered
schedule.every(1).hours.do(job)
assert len(schedule.jobs) == 1, "expected 1 job"

# run_pending should not call the job (not yet due)
schedule.run_pending()
assert len(results) == 0, "job should not have run yet"

# run_all forces all jobs to run regardless of schedule
schedule.run_all()
assert len(results) == 1, "job should have run via run_all"

schedule.clear()
assert len(schedule.jobs) == 0, "jobs should be cleared"

sys.exit(0)
EOF
