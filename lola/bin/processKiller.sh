#!/bin/bash

while true
do
        dateTime=`date '+%Y-%m-%d-%H:%M:%S'`
        echo "$dateTime processKiller is running"
	
	# Get sara processes belongig to the parent id = 1
        saraProcess=`ps -eo ppid,comm,pid,user,vsz,start,time | sed 's/^ *//' | grep '^1 sara' | tail -n 1`

        if [ "$saraProcess" ]
        then
                echo "$dateTime Following sara process will be killed: $saraProcess"
                kill -9 `echo $saraProcess | awk '{print $3}'`
        fi
	
	# Get lola processes
        lolaProcess=`ps -eo ppid,comm,pid,user,vsz,start,time | sed 's/^ *//' | grep '^1 lola' | tail -n 1`

        if [ "$lolaProcess" ]
        then
                echo "$dateTime Following LoLA process will be killed: $lolaProcess"
                kill -9 `echo $lolaProcess | awk '{print $3}'`
        fi

        sleep 5
done
