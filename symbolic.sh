#!/usr/bin/env bash

ruta="$1"

red='\e[0;31m'
reset='\e[0m'

if [ "$EUID" -ne 0 ]; then
  echo -e "${red}[!] Tiene que ser usuario root para ejecutar el script ${reset}"
  exit 1
fi

symbolic() {
  resultado="${ruta##*/}"
  ln -s $ruta /usr/bin/$resultado

}


symbolic
