#!/bin/bash


echo "start time"
StartTime=$(date +%s)
sleep 3
EndTime=$(date +%s)
echo "end time"
echo "It takes $(($EndTime - $StartTime)) seconds to complete this task."



