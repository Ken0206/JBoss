#!/bin/bash

typeset -i loop_no

  up_time=$(uptime | awk '{print $3$4}')
  while [ "${up_time}" == "0min," -o "${up_time}" == "1min," -o "${up_time}" == "2min," -o "${up_time}" == "3min," ] ; do
    loop_no=${loop_no}+1
    echo "${loop_no} uptime=${up_time} $(date +%Y/%m/%d-%H:%M:%S)"
    sleep 1
    up_time=$(uptime | awk '{print $3$4}')
  done
echo ''
echo "uptime=${up_time} $(date +%Y/%m/%d-%H:%M:%S)"
echo ''

