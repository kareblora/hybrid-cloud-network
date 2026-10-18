#!/bin/bash
set -e

echo "Starting FRRouting..."
service frr start

echo "Router container ready."
exec tail -f /dev/null
