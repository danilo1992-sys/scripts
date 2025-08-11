#!/bin/bash

# --- Definiciones de Colores ---
cyan='\e[0;36m'
green='\e[0;32m'
red='\e[1;31m'
blue="\e[0;34m"
reset='\e[0m'

# --- Variable Global para la IP (si es válida) ---
ip="" # Inicializar como cadena vacía

# --- Funciones ---

# Función para validar una dirección IP
validar_ip() {
  local ip_a_validar="$1"
  if [[ "$ip_a_validar" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    IFS='.' read -r -a octets_array <<<"$ip_a_validar"
    for octeto in "${octets_array[@]}"; do
      if ((octeto < 0 || octeto > 255)); then
        return 1 # Rango de octeto inválido
      fi
    done
    return 0 # IP es válida
  else
    return 1 # No coincide con el patrón de IP
  fi
}

# Arte ASCII
print_ascii_art() {
  local ascii_art=" .    .
    .|    |.       _   _         _   _____
    ||    ||      | \\ | |   ___ | |_  | ____| __  __   ___   ___
    \\\\( )//       |  \\| |  / _ \\| __| | _|    \\ \\/ /  / _ \\ / __|
    .=[ ]=.       | |\\  | | __/ | |_  | |___    >  <  | __/ | (__
  / /˙-˙\\ \\     |_| \\_|  \\___| \\__| |_____| /_/\\_\\  \\___| \\___|
  ˙ \\    / ˙
    ˙    ˙"
  echo -e "${cyan}$ascii_art${reset}"
}

# Menú Principal
menu_opcion() {
  echo ""
  echo -e "${green} 1) SMB ${reset}"
  echo -e "${green} 2) FTP ${reset}"
  echo -e "${green} 0) Salir ${reset}" # Añadida una opción de salida explícita
  echo ""
}

# Submenú SMB
smb_menu() {
  echo -e "${blue}--SMB--${reset}"
  echo -e "${blue} 1) Enumeración ${reset}"
  echo -e "${blue} 2) Listar recursos compartidos ${reset}"
  echo -e "${blue} 3) Listar Usuarios ${reset}"
  echo -e "${blue} 4) Sesión nula ${reset}"
  echo -e "${green} 5) Volver al menú principal ${reset}"
  echo ""

  while true; do
    read -p "Seleccione una opción: " smb_choice
    case $smb_choice in
    1)
      echo "Ejecutando: nxc smb $ip"
      nxc smb "$ip"
      ;;
    2)
      echo "Ejecutando: nxc smb $ip -u '' -p '' --shares"
      nxc smb "$ip" -u '' -p '' --shares
      ;;
    3)
      echo "Ejecutando: nxc smb $ip -u '' -p '' --users"
      nxc smb "$ip" -u '' -p '' --users
      ;;
    4)
      echo "Ejecutando: nxc smb $ip -u '' -p ''"
      nxc smb "$ip" -u '' -p ''
      ;;
    5)
      echo -e "${green}Volviendo al menú principal ${reset}"
      sleep 1
      break # Sale de este bucle, regresa al bucle del menú principal
      ;;
    *)
      echo -e "${red}Opción no válida. Por favor, elija una opción correcta.${reset}"
      ;;
    esac
    echo "" # Agrega una nueva línea para mayor legibilidad después de la ejecución del comando
  done
}

# Submenú FTP
ftp_menu() {
  echo -e "${cyan} -- FTP --${reset}"
  echo -e "${cyan} 1) Enumeración ${reset}"
  echo -e "${cyan} 2) Listar Usuarios${reset}"
  echo -e "${cyan} 3) Listar Archivos ${reset}"
  echo -e "${cyan} 4) Listar Directorios ${reset}"
  echo -e "${green} 5) Volver al menú principal ${reset}" # Añadida opción para regresar
  echo ""

  while true; do
    read -p "Seleccione una opción: " ftp_choice
    case $ftp_choice in
    1)
      echo "Ejecutando: nxc ftp $ip"
      nxc ftp "$ip"
      ;;
    2)
      echo "Ejecutando: nxc ftp $ip -u '' -p '' --users"
      nxc ftp "$ip" -u '' -p '' --users
      ;;
    3)
      read -p "Ingrese el nombre de usuario: " user
      read -p "Ingrese la contraseña: " passwd
      echo "Ejecutando: nxc ftp $ip -u $user -p $passwd --ls"
      nxc ftp "$ip" -u "$user" -p "$passwd" --ls
      ;;
    4)
      read -p "Ingrese el nombre de usuario: " user
      read -p "Ingrese la contraseña: " passwd
      read -p "Ingrese el nombre de la carpeta: " folder
      echo "Ejecutando: nxc ftp $ip -u $user -p $passwd --ls $folder"
      nxc ftp "$ip" -u "$user" -p "$passwd" --ls "$folder"
      ;;
    5)
      echo -e "${green}Volviendo al menú principal ${reset}"
      sleep 1
      break # Sale de este bucle, regresa al bucle del menú principal
      ;;
    *)
      echo -e "${red}Opción no válida. Por favor, elija una opción correcta.${reset}"
      ;;
    esac
    echo "" # Agrega una nueva línea para mayor legibilidad después de la ejecución del comando
  done
}

# --- Lógica Principal del Script ---

# Validación inicial de IP y muestra de uso
if [[ $# -eq 0 ]]; then
  echo -e "${red}Error: No se proporcionó ninguna dirección IP.${reset}"
  echo "Uso: $0 [IP]"
  exit 1
elif ! validar_ip "$1"; then
  echo -e "${red}Error: La dirección IP '$1' no es válida.${reset}"
  echo "Uso: $0 [IP]"
  exit 1
else
  ip="$1" # Establece la variable global IP si es válida
fi

echo "IP válida: $ip"
sleep 1

# Bucle principal para el menú
while true; do
  print_ascii_art # Llama a la función para imprimir el arte ASCII
  menu_opcion     # Muestra las opciones del menú principal

  read -p "Elige una opción: " main_option
  case $main_option in
  1)
    smb_menu # Llama a la función del submenú SMB
    ;;
  2)
    ftp_menu # Llama a la función del submenú FTP
    ;;
  0)
    echo "Saliendo del programa..."
    break # Sale del bucle principal
    ;;
  *)
    echo -e "\n${red}[!] Opción no encontrada. Por favor, elija una opción válida.${reset}"
    sleep 1
    ;;
  esac
  echo "" # Agrega una nueva línea para un mejor espaciado entre las iteraciones del menú
done
