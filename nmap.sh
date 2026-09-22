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
  local ip="$1"
  local regex='^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'

  if [[ $ip =~ $regex ]]; then
    return 0
  else
    return 1
  fi
}

if ! validar_ip "$ip"; then
  echo -e "${red}La ip no es valida ${ip}${reset}" >&2
  exit 1
fi

validar_carpeta() {
  if [[ ! -d "$folder/nmap" ]]; then
    echo -e "${red} El directorio no existe ${reset}" >&2
    exit 1
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
  validar_carpeta
  sleep 1
  cd "$folder/nmap"
}

ping() {
  echo -e "[-]${blue} Haciendo Ping ${reset}"
  sleep 1
  nmap -sn $ip | pv >/dev/null
}

escaneo_puertos() {
  echo -e "${blue}[-] Escaneando puertos${reset}"
  sleep 1
  nmap -p- --open -sS --min-rate 5000 -vvv -n -Pn $ip -oG allports | pv >/dev/null
  ports=$(cat allports | grep -oP '\d{1,5}/open' | awk '{print $1}' FS='/' | xargs | tr ' ' ',')
}

escaneo_servicios() {
  echo -e "${blue}[-] Escaneando Servicios ${reset}"
  sleep 1
  nmap -p$ports -sCV $ip -oN targeted | pv >/dev/null
}

escaneo_de_vulneravilidades() {
  echo -e "${cyan}[-] Escaneo de Vulneravildades${reset}"
  sleep 1
  nmap --script vuln $ip -v | pv >/dev/null
}

nmap_ascii
validar_ip
ingresar
ping
escaneo_puertos
escaneo_servicios
escaneo_de_vulneravilidades
echo ""
sleep 1
echo -e "
${green}[-] Escaneo finalizado ${reset}"
