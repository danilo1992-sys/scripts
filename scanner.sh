#!/usr/bin/env bash

red='\e[1;31m'
blue='\e[1;34m'
green='\e[0;32m'
reset='\e[0m'

function usage() {
  echo -e "${green} Scanner.sh <IP> ${reset}"
  echo -e "${red} Ingrese una ip ${reset}"
  exit 1
}

[[ $# == 1 ]] && IP="$1" || usage

for i in {1..65535}; do
  (
    bash -c "echo > /dev/tcp/$IP/$i" 2>/dev/null
    if [[ $? == 0 ]]; then
      echo -e "${green}[+] Puerto $i activo en la ip $IP ${reset}"
    fi
  ) &
done

wait

echo -e "${green} Escaneo Finalizado ${reset}"
