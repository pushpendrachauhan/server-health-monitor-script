#!/bin/bash

ADMIN="pushpendra.singh@cerridsolutions.com"


hostIp=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')

mem_status="safe"

disk_status="safe"


DISK_ALERT=90
MEM_ALERT=90
TOTALMEM=`free -m | head -2 | tail -1| awk '{print $2}'`

FREEMEM=`free -m | head -2 | tail -1| awk '{print $4}'`


totalmempercent=$(($FREEMEM * 100 / $TOTALMEM  ))

#echo $totalmempercent
memory="safe"

if [ $totalmempercent -ge $MEM_ALERT ]; then
    mem_status="unsafe"
    memory="Runing out of memory $totalmempercent% on $(hostname) on $(date)"

fi


#echo $memory

body=""

df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }' |{ while read output;
do

  usep=$(echo $output | awk '{ print $1}' | cut -d'%' -f1  )

  partition=$(echo $output | awk '{ print $2 }' )
  if [ $usep -ge $DISK_ALERT ]; then
    disk_status="unsafe"
    c="Running out of space \"$partition ($usep%)\" on $(hostname) as on $(date)"
    body+="\n$c"
                                                                                                                                                         19,0-1        Top
  fi
done


if [ "$mem_status" == "unsafe" ] ||  [ "$disk_status" == "unsafe" ]; then
  echo "boom"
  body+="\n\n$memory"
  echo -e $body | mail -s "$hostIp Server DISK & MEMORY report" "pushpendra.singh@cerridsolutions.com"
fi
echo $memory
}







