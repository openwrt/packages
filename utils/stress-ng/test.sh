#!/bin/sh -e

# Run a single CPU operation and exit; validates the stressor infrastructure
stress-ng --cpu 1 --cpu-ops 1 --metrics-brief
