#!/bin/bash
echo "Sleep for waiting documentserver start"
let SEC=$[90]
echo seconds_left:
while( [ $SEC -gt 0 ] )
do
echo $SEC
let SEC--
sleep 1
done
echo "Waiting is end. Run tests"
exec rspec
