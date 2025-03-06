#!/bin/bash

# =============================================================================
# Nom du script : deleteNewProject.sh
# Description   : Outil de gestion pour supprimer des configurations Nginx
# Auteur        : Ando Romain
# Version       : 1.0
# =============================================================================

# Couleurs pour l'affichage terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NGINX_AVAILABLE_DIR="/etc/nginx/sites-available"
NGINX_ENABLED_DIR="/etc/nginx/sites-enabled"
HOSTS_FILE="/etc/hosts"

# Vérifier si l'utilisateur a les privilèges sudo
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}[ERREUR]${NC} Ce script nécessite des privilèges administrateur"
   echo -e "Utilisation: ${YELLOW}sudo $0${NC}"
   exit 1
fi

# Fonction pour afficher un message de bienvenue
function print_welcome() {
  clear
  echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║       GESTION DES VIRTUAL HOSTS NGINX      ║${NC}"
  echo -e "${BLUE}║              MODULE SUPPRESSION            ║${NC}"
  echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
  echo -e "\n"
}

# Fonction pour lister les configurations Nginx disponibles
function list_nginx_configs() {
  echo -e "${BLUE}Configurations disponibles :${NC}"
  echo -e "${BLUE}───────────────────────────${NC}"
  
  local sites=($(ls -1 ${NGINX_AVAILABLE_DIR}/ 2>/dev/null | sort))
  
  if [ ${#sites[@]} -eq 0 ]; then
    echo -e "${YELLOW}[INFO]${NC} Aucune configuration trouvée."
    return 0
  fi

  # Afficher les sites avec des numéros
  for i in "${!sites[@]}"; do
    local site_status=""
    # Vérifier si le site est activé
    if [ -L "${NGINX_ENABLED_DIR}/${sites[$i]}" ]; then
      site_status="${GREEN} [ACTIVÉ]${NC}"
    fi
    echo -e " ${YELLOW}$((i+1)).${NC} ${sites[$i]}$site_status"
  done
  
  return ${#sites[@]}
}

# Fonction pour supprimer un virtual host
function delete_virtual_host() {
  local config_name="$1"
  local sites_available="${NGINX_AVAILABLE_DIR}/$config_name"
  local sites_enabled="${NGINX_ENABLED_DIR}/$config_name"
  
  echo -e "\n${BLUE}[TRAITEMENT]${NC} Suppression de la configuration '$config_name'..."
  
  # Extraire le nom du serveur pour la recherche dans /etc/hosts
  local server_name=$(grep -E "server_name" "$sites_available" 2>/dev/null | head -1 | sed -E 's/.*server_name\s+([^; ]+).*/\1/')
  
  # Supprimer le lien symbolique si existant
  if [ -L "$sites_enabled" ]; then
    rm "$sites_enabled"
    echo -e "  ${GREEN}✓${NC} Désactivation du site"
  fi
  
  # Supprimer le fichier de configuration
  if [ -f "$sites_available" ]; then
    rm "$sites_available"
    echo -e "  ${GREEN}✓${NC} Suppression du fichier de configuration"
  fi
  
  # Supprimer l'entrée dans /etc/hosts si elle existe
  if [ -n "$server_name" ] && grep -q "$server_name" ${HOSTS_FILE}; then
    sed -i "/$server_name/d" ${HOSTS_FILE}
    echo -e "  ${GREEN}✓${NC} Suppression de l'entrée DNS locale: $server_name"
  else
    echo -e "  ${YELLOW}!${NC} Aucune entrée correspondante trouvée dans ${HOSTS_FILE}"
  fi
  
  # Recharger Nginx
  echo -e "\n${BLUE}[SYSTÈME]${NC} Rechargement de la configuration Nginx..."
  if systemctl reload nginx; then
    echo -e "${GREEN}[SUCCÈS]${NC} Virtual host '$config_name' supprimé avec succès."
  else
    echo -e "${RED}[ERREUR]${NC} Problème lors du rechargement de Nginx. Vérifiez manuellement."
  fi
}

# Fonction principale
function main() {
  print_welcome
  
  # Lister les configurations et récupérer le nombre total
  list_nginx_configs
  local total_sites=$?
  
  if [ $total_sites -eq 0 ]; then
    exit 0
  fi
  
  echo -e "\n${BLUE}Action :${NC} Entrez le numéro de la configuration à supprimer (ou '${YELLOW}q${NC}' pour quitter)"
  read -p "> " choice
  
  # Quitter si l'utilisateur entre 'q'
  if [[ "$choice" == "q" ]]; then
    echo -e "${YELLOW}[INFO]${NC} Opération annulée par l'utilisateur."
    exit 0
  fi
  
  # Vérifier que le choix est valide
  if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt $total_sites ]; then
    echo -e "${RED}[ERREUR]${NC} Choix non valide. Veuillez entrer un numéro entre 1 et $total_sites."
    exit 1
  fi
  
  # Récupérer le nom du fichier de configuration sélectionné
  local selected_config=$(ls -1 ${NGINX_AVAILABLE_DIR}/ | sort | sed -n "${choice}p")
  
  echo -e "\n${YELLOW}[ATTENTION]${NC} Vous avez sélectionné: ${BLUE}$selected_config${NC}"
  echo -e "Cette action va ${RED}supprimer définitivement${NC} cette configuration."
  read -p "Confirmer la suppression? (o/N): " confirm
  
  if [[ "$confirm" == "o" || "$confirm" == "O" ]]; then
    delete_virtual_host "$selected_config"
  else
    echo -e "${YELLOW}[INFO]${NC} Opération annulée."
  fi
}

# Exécuter la fonction principale
main