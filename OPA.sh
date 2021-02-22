#!/bin/bash

if [ "$1" == "-h" ] ; then
    echo 
    echo "Usage:"
    echo 
    echo "-H: Host to fuzz"
    echo "-W: Wordlist"
    echo "--hw: Hide words, from wfuzz"
    echo 
    echo "WORDLISTS: BIG, DIR, FILES, VHOSTS"
    echo
    echo "Example:"
    echo
    echo "OPA -H passage.htb -W vhosts -IP 10.10.10.206 --HW 955"
    echo "OPA -W files -IP 10.10.10.220:5080 --HC 401 --HW 302"
    echo   
    exit 0  
fi

big="/usr/share/wfuzz/wordlist/general/big.txt"
dir="/usr/share/wordlists/SecLists/Discovery/Web-Content/raft-large-directories.txt"
files="/usr/share/wordlists/SecLists/Discovery/Web-Content/raft-large-files.txt"
vhosts="/usr/share/wordlists/SecLists/Discovery/DNS/subdomains-top1million-110000.txt"

# A string with all the options
options=$@
 
# An array with all the arguments
arguments=($options)
 
# Loop index
index=0
HW=0
HC=0

for argument in $options
  do
    # Incrementing index
    index=`expr $index + 1`
 
    # The conditions
    case $argument in
      -IP) IP="${arguments[index]}";;
      -H) HOST="${arguments[index]}";;  
      -W) WORDLIST="${arguments[index]}";;
      --HW) HW="${arguments[index]}";;
      --HC) HC="${arguments[index]}";;
    esac
  done

if [ "$WORDLIST" == "vhosts" ]; then
     if [ "$IP" == "" ] && [ "$HOST" == "" ]; then
         echo "Type the Host: (Ex: -H academy.htb)"
         echo "Type the IP addresst: (Ex: -IP 10.10.10.10)" 
         exit
     elif [ "$IP" == "" ]; then
         echo "Type the IP address: (Ex: -IP 10.10.10.10)"
         exit
     elif [ "$HOST" == "" ]; then
         echo "Type the Host: (Ex: -H academy.htb)"
         exit 
     fi 

     wfuzz -w $vhosts --hw $HW -H 'Host: FUZZ.$HOST' -t 10 $IP    
elif [ "$WORDLIST" == "big" ]; then
     wfuzz -c -z file,$big --hc $HC --hw $HW http://$IP/FUZZ
elif [ "$WORDLIST" == "files" ]; then
     wfuzz -c -z file,$files --hc $HC --hw $HW http://$IP/FUZZ
elif [ "$WORDLIST" == "dir" ]; then
     wfuzz -c -z file,$dir --hc $HC --hw $HW http://$IP/FUZZ
fi
