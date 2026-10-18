#!/bin/bash
set -e

echo "Starting FRRouting..."
service frr start

echo "FRRouting startup requested."
exec sleep infinity
