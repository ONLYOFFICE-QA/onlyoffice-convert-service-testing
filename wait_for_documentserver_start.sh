#!/bin/bash
echo "Sleep for waiting documentserver start"
sleep 120
echo "Waiting is end. Run tests"
exec rspec
