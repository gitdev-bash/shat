#!/bin/bash
# Simple encrypted network chat
# license WTFPL
# Check for dependency
check_nc=$(which nc)
[ -z "$check_nc" ] && echo "You don`t have nc installed.Install nc and try again" && c1="false" || c1="true"
check_nmap=$(which nmap)
[ -z "$check_nmap" ] && echo "You don`t have nmap installed.Install nmap and try again" && c2="false" || c2="true"
check_openssl=$(which openssl)
[ -z "$check_openssl" ] && echo "You don`t have openssl installed.Install openssl and try again" && c3="false" || c3="true"
[ "$c1" == "true" -a "$c2" == "true" -a "$c3" == "true" ] && exit
port="31415"
ip="$1"
name="$USER"
read -s "enter password" pass
#enter password

txt="$USER has joined"

encrypt () {
    echo -e  "\e[34m$name\e[0m: $1" | openssl enc -aes-256-cbc -a -salt -in /dev/stdin -out /dev/stdout -pass $pass | sed ':a;N;$!ba;s/\n/;/g'
}

decrypt () {
    sed 's/;/\n/g' <<<"$1" | openssl enc -aes-256-cbc -d -a -in /dev/stdin -out /dev/stdout -pass $pass
}

export -f decrypt

open=$(nmap -sT $ip -p $port  | grep "$port/tcp.*open")
#nmap is not instaled by default on manny systems

if [ "$open" ]
then
    while [ true ];
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
