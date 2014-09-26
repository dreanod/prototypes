#!/bin/bash

echo "Quiet mode disactivated"
psql -U postgres -d test -c "SELECT rid FROM myraster" | head -n 10

echo "Quiet mode activated"
psql -U postgres -d test -c "SELECT rid FROM myraster" > /dev/null 2>&1