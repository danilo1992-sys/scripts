#!/usr/bin/env bash

red='\e[1;31m'
blue='\e[1;34m'
reset='\e[0m'

function uso() {
  echo -e "${blue}decript.sh <Hash>${reset}"
  echo -e "${red}Ingrese un hash valido ${reset}"
  exit 1
}

[[ $# == 1 ]] && HASH="$1" || uso

function menu() {
  echo -e "${blue}===============================${reset}"
  echo -e "${red} Selecione una opcion para decencryptar ${reset}"
  echo -e "${blue}===============================${reset}"
  echo -e "${blue}1) Rot13 ${reset}"
  echo -e "${blue}2) MD5 ${reset}"
  echo -e "${blue}3) SHA256 ${reset}"
  echo -e "${red}---------------------------------${reset}"
}

function Rot13() {
  result=$(echo "$HASH" | tr 'A-Za-z' 'N-ZA-Mn-za-m')
  echo -e "${blue}[*] El mensaje es:${reset}"
  echo -e "${blue}$result${reset}"
}

function MD5() {
  result=$(echo -n "$HASH" | md5sum)
  echo -e "${blue}[*] El mensaje es:${reset}"
  echo -e "${blue}$result${reset}"
}

function SHA256() {
  dic=/usr/share/wordlists/rockyou.txt

  while IFS= read -r palabra; do
    RESULTADO= &
    (echo -n "$HASH" | sha256sum | awk '{print $1}')
    if ["$HASH" == "$RESULTADO"]; then
      echo -e "${blue}[*] El mensaje es:${reset}"
      echo -e "${blue}$palabra${reset}"
      exit 0
    fi
  done <"$dic"
}
while true; do
  menu
  read -p "Selecione una opcion: " op

  case $op in
  1)
    Rot13
    exit 0
    ;;
  2)
    MD5
    exit 0
    ;;
  3)
    SHA256
    exit 0
    ;;
  *) echo "opcion incorrecta, Selecione una opcion valida" ;;
  esac

done
