#!/bin/bash

blue='\e[0;34m'
red='\e[0;31m'
cyan='\e[0;36m'
green='\e[0;32m'
reset='\e[0m'

ip="$1"
folder="$2"
ports=""

validar_ip() {
  local ip_validar="$1"
  if [[ "$ip_validar" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    IFS='.' read -r -a octets_array <<<"$ip_validar"
    for octeto in "${octets_array[@]}"; do
      if ((octeto < 0 || octeto > 255)); then
        return 1
      fi
    done
    return 0
  else
    return 1
  fi
}

nmap_ascii() {
  echo -e "${blue}"
  cat <<'EOF_ASCII_ART'
                    ___.-------.___
                _.-' ___.--;--.___ `-._
             .-' _.-'  /  .+.  \  `-._ `-.
           .' .-'      |-|-o-|-|      `-. `.
          (_ <O__      \  `+'  /      __O> _)
            `--._``-..__`._|_.'__..-''_.--'
                  ``--._________.--''
   ____  _____  ____    ____       _       _______
  |_   \|_   _||_   \  /   _|     / \     |_   __ \
    |   \ | |    |   \/   |      / _ \      | |__) |
    | |\ \| |    | |\  /| |     / ___ \     |  ___/
   _| |_\   |_  _| |_\/_| |_  _/ /   \ \_  _| |_
  |_____|\____||_____||_____||____| |____||_____|
EOF_ASCII_ART
  echo -e "${reset}"
}

ingresar() {
  sleep 1
  echo ""
  cd $folder/nmap
}

ping() {
  echo -e "[-]${blue} Haciendo Ping ${reset}"
  sleep 1
  nmap -sn $ip
}

escaneo_puertos() {
  echo -e "${blue}[-] Escaneando puertos${reset}"
  sleep 1
  nmap -p- --open -sS --min-rate 5000 -vvv -n -Pn $ip -oG allports
  ports=$(cat allports | grep -oP '\d{1,5}/open' | awk '{print $1}' FS='/' | xargs | tr ' ' ',')
}

escaneo_servicios() {
  echo -e "${blue}[-] Escaneando Servicios ${reset}"
  sleep 1
  nmap -p$ports -sCV $ip -oN targeted
}

escaneo_de_vulneravilidades() {
  echo -e "${cyan}[-] Escaneo de Vulneravildades${reset}"
  sleep 1
  nmap --script vuln $ip -v
}

if [[ $# -eq 0 ]]; then
  echo -e "${red} [!] Debe de proporcionar una dirección ip ${reset}"
  echo -e "${green}Uso: $0 [ip] ${reset}"
elif validar_ip "$ip"; then
  echo -e "${red}[!] La ip '$ip' no es valida${reset}"
  echo -e "${green}Uso: $0 [ip] ${reset}"
else
  ip="$1"
fi

nmap_ascii
ingresar
ping
escaneo_puertos
escaneo_servicios
escaneo_de_vulneravilidades
echo ""
sleep 1
echo -e "${green}[-] Escaneo finalizado ${reset}"
