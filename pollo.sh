#!/usr/bin/bash
#Carlos Peralta
#2023
#GPL3

# text color params
error=`tput setaf 1`
info=`tput setaf 2`
warn=`tput setaf 3`
colorbg=`tput setab 1`

# config file reading
if [ -f ./pollo.conf ]; then
    echo -e "${info}[info] Config file found: $(pwd)/pollo.conf ${reset}\n"
    source ./pollo.conf
elif [ -f /etc/pollo.conf ]; then
    echo -e "${info}[info] Config file found: /etc ${reset}\n"
    source /etc/pollo.conf
else
    echo "${error}[error] ./pollo.conf not found...bye${reset}"
    exit
fi

# basic metrics
(timeout 3s free -m || echo "timeout" > free.tmp ) | tr -s ' ' > free.tmp
totmem=$((grep -i 'mem' free.tmp || echo "fail" ) | cut -f 2 -d ' ')
usemem=$((grep -i 'mem' free.tmp || echo "fail" ) | cut -f 3 -d ' ')
availablemem=$((grep -i 'mem' free.tmp || echo "fail")  | cut -f 7 -d ' ')
totswa=$((grep -i 'swa' free.tmp || echo "fail") | cut -f 2 -d ' ')
useswa=$((grep -i 'swa' free.tmp || echo "fail" ) | cut -f 3 -d ' ') # uso de swap
freswa=$((grep -i 'swa' free.tmp || echo "fail" )| cut -f 4 -d ' ')
rm free.tmp

# extra metrics
if [ $availablemem != "fail" ] && [ $totmem != "fail" ]; then
    availableMemPerc=$(($availablemem *100 / $totmem)) # esta es la buena para saber cuanta memoria queda libre
else
    availableMemPerc="fail"
fi

if [ $freswa != "fail" ] && [ $totswa != "fail" ]; then
    freeSwapPerc=$(($freswa *100 / $totswa)) # esta es para el porcentaje del swap libre
else
    freeSwapPerc="fail"
fi


# system snapshot

logincontrol=$(loginctl)


# report

echo "POLLO INFORMA"
echo "Cliente $(hostname)"
echo "-------------------------"
echo "RAM"
echo "Disponible $availableMemPerc % de $totmem MB"
echo "SWAP libre $freeSwapPerc % de $totswa MB"
echo
echo "$logincontrol"
