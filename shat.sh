#!/bin/bash
# Simple encrypted network chat
# license WTFPL

port=31415
ip="$1"
name="$USER"
read -s passwordshat


txt=Connected

encrypt () {
    echo -e  "\e[34m$name\e[0m: $1" | openssl enc -aes-256-cbc -a -salt -in /dev/stdin -out /dev/stdout -pass $passwordshat | sed ':a;N;$!ba;s/\n/;/g'
}

decrypt () {
    sed 's/;/\n/g' <<<"$1" | openssl enc -aes-256-cbc -d -a -in /dev/stdin -out /dev/stdout -pass $passwordshat
}

export -f decrypt

open=$(nmap -sT $ip -p $port  | grep "$port/tcp.*open")

if [ "$open" ]
then
    while true;
    do
        encrypt "$txt"
        read txt
    done | nc -l -p $port 2>&1 | xargs -I '{}' -n1 bash -c 'decrypt "{}"' 

else
    echo "waiting for user"
    nc -l -p $port 2> /dev/null
    sleep 0.5

    while true;
    do
        encrypt "$txt"
        read txt
    done | nc $ip $port 2>&1 | xargs -I '{}' -n1 bash -c 'decrypt "{}"'
fi


# vim: ai ts=4 sw=4 et sts=4 ft=sh
