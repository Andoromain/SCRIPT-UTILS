#!/bin/bash
# filepath: /home/user/SCRIPT/createNewProjet.sh

# =============================================================================
# Project Creation Script - v1.0
# Author: Ando Romain
# Description: Automated project setup with virtual host configuration
# =============================================================================

set -e  # Exit on error
readonly SCRIPT_NAME=$(basename "$0")
readonly LOG_FILE="/tmp/${SCRIPT_NAME%.*}.log"

# Color codes for output formatting
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[0;33m'
readonly NC='\033[0m' # No Color

# Project types array
readonly PROJECT_TYPES=("Laravel" "React" "Vue")
readonly CONFIG_FILE="${HOME}/.config/project-creator.conf"

# Default values
projectName=""
projectUrl=""
projectType=""
projectDirectory=""
projectPhpVersion=""
projectEnvironment=""
projectPort=""

# ==================================
# Logging functions
# ==================================
log() {
  local message="$1"
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo -e "[${timestamp}] ${message}" | tee -a "$LOG_FILE"
}

log_info() {
  log "${BLUE}INFO:${NC} $1"
}

log_success() {
  log "${GREEN}SUCCESS:${NC} $1"
}

log_warning() {
  log "${YELLOW}WARNING:${NC} $1"
}

log_error() {
  log "${RED}ERROR:${NC} $1"
}

# ==================================
# Utility functions
# ==================================
check_dependencies() {
  log_info "Checking dependencies..."
  for cmd in nginx sudo; do
    if ! command -v "$cmd" &> /dev/null; then
      log_error "$cmd is required but not installed."
      exit 1
    fi
  done
}

print_banner() {
  clear
  cat << "EOF"
 _____           _           _     _____                _             
|  _  |___ ___  |_|___ ___ _| |_  |     |___ ___ ___  _| |___ ___ ___ 
|   __|  _| . | | | -_|  _| . | |_|   --| -_| .'| . || . | -_|  _|_ -|
|__|  |_| |___|_| |___|___|___|_|_|_____|___|__,|  _||___|___|_| |___|
              |___|                             |_|                    

EOF
  echo -e "${BLUE}Project Environment Configuration Tool${NC}\n"
}

# ==================================
# Configuration functions
# ==================================
load_config() {
  if [[ -f "$CONFIG_FILE" ]]; then
    log_info "Loading configuration from $CONFIG_FILE"
    source "$CONFIG_FILE"
  else
    log_info "No configuration file found at $CONFIG_FILE"
  fi
}

save_config() {
  log_info "Saving configuration preferences..."
  mkdir -p "$(dirname "$CONFIG_FILE")"
  
  cat > "$CONFIG_FILE" << EOF
# Project Creator Configuration
# Last updated: $(date)
DEFAULT_PHP_VERSION="$projectPhpVersion"
DEFAULT_ENVIRONMENT="$projectEnvironment"
DEFAULT_PROJECT_DIR="$projectDirectory"
EOF

  log_success "Configuration saved to $CONFIG_FILE"
}

# ==================================
# Input processing functions
# ==================================
process_arguments() {
  if [ $# -ge 1 ]; then
    projectName="$1"
  fi
  if [ $# -ge 2 ]; then
    projectUrl="$2"
  fi
  if [ $# -ge 3 ]; then
    projectDirectory="$3"
  fi
  if [ $# -ge 4 ]; then
    projectType="$4"
  fi
  if [ $# -ge 5 ]; then
    projectPhpVersion="$5"
  fi
  if [ $# -ge 6 ]; then
    projectEnvironment="$6"
  fi
  if [ $# -ge 7 ]; then
    projectPort="$7"
  fi
}

print_tab() {
  index=1
  local table=("$@")
  for element in "${table[@]}"; do
    echo -e "${GREEN}$index${NC} - $element"
    ((index++))
  done
}

validate_input() {
  local input="$1"
  local prompt="$2"
  local error_msg="$3"
  
  while [[ -z "$input" ]]; do
    read -p "$prompt: " input
    if [[ -z "$input" ]]; then
      echo -e "${RED}$error_msg${NC}"
    fi
  done
  
  echo "$input"
}

read_project_structure() {
  echo -e "${BLUE}Collecte des informations du projet${NC}\n"
  
  if [ -z "$projectName" ]; then
    projectName=$(validate_input "$projectName" "Nom du projet" "Le nom du projet est obligatoire")
  else
    echo -e "${YELLOW}Nom du projet (par défaut)${NC}: $projectName"
  fi

  if [ -z "$projectUrl" ]; then
    projectUrl=$(validate_input "$projectUrl" "URL du projet (sans http://)" "L'URL du projet est obligatoire")
  else
    echo -e "${YELLOW}URL du projet (par défaut)${NC}: $projectUrl"
  fi

  if [ -z "$projectDirectory" ]; then
    if [[ -n "$DEFAULT_PROJECT_DIR" ]]; then
      echo -e "${YELLOW}Chemin par défaut disponible${NC}: $DEFAULT_PROJECT_DIR"
      read -p "Chemin du projet [laisser vide pour utiliser le chemin par défaut]: " projectDirectory
      
      if [ -z "$projectDirectory" ]; then
        projectDirectory="$DEFAULT_PROJECT_DIR"
      fi
    else
      projectDirectory=$(validate_input "$projectDirectory" "Chemin du projet" "Le chemin du projet est obligatoire")
    fi
  else
    echo -e "${YELLOW}Chemin du projet (par défaut)${NC}: $projectDirectory"
  fi

  echo -e "\n${BLUE}Choisir le type de projet:${NC}"
  print_tab "${PROJECT_TYPES[@]}"
  
  if [ -z "$projectType" ]; then
    read -p "Choix: " choice
    
    # Convert numerical choice to project type
    if [ "$choice" = "1" ]; then
      projectType="Laravel"
    elif [ "$choice" = "2" ]; then
      projectType="React"
    elif [ "$choice" = "3" ]; then
      projectType="Vue"
    else
      log_error "Choix non valide. Veuillez sélectionner un numéro entre 1 et ${#PROJECT_TYPES[@]}."
      projectType=""
      read_project_structure
      return
    fi
  else
    echo -e "${YELLOW}Type du projet (par défaut)${NC}: $projectType"
    # Convert if projectType is a number
    if [ "$projectType" = "1" ]; then
      projectType="Laravel"
    elif [ "$projectType" = "2" ]; then
      projectType="React"
    elif [ "$projectType" = "3" ]; then
      projectType="Vue"
    fi
  fi

  if [ "$projectType" = "Laravel" ]; then
    if [ -z "$projectPhpVersion" ]; then
      if [[ -n "$DEFAULT_PHP_VERSION" ]]; then
        read -p "Version de PHP [${DEFAULT_PHP_VERSION}]: " projectPhpVersion
        if [ -z "$projectPhpVersion" ]; then
          projectPhpVersion="$DEFAULT_PHP_VERSION"
        fi
      else
        read -p "Version de PHP (ex: 8.2): " projectPhpVersion
      fi
    else
      echo -e "${YELLOW}Version de PHP (par défaut)${NC}: $projectPhpVersion"
    fi
    
    # Validate PHP version format (simple check for N.N format)
    if ! [[ "$projectPhpVersion" =~ ^[0-9]+\.[0-9]+$ ]]; then
      log_error "Format de version PHP non valide. Utilisation du format X.Y (ex: 8.2)"
      projectPhpVersion=""
      read_project_structure
      return
    fi
  fi

  if [ -z "$projectEnvironment" ]; then
    if [[ -n "$DEFAULT_ENVIRONMENT" ]]; then
      read -p "Environnement (dev, prod) [${DEFAULT_ENVIRONMENT}]: " projectEnvironment
      if [ -z "$projectEnvironment" ]; then
        projectEnvironment="$DEFAULT_ENVIRONMENT"
      fi
    else
      read -p "Environnement (dev, prod): " projectEnvironment
    fi
    
    while [ "$projectEnvironment" != "dev" ] && [ "$projectEnvironment" != "prod" ]; do
      log_error "Environnement non reconnu. Veuillez choisir entre dev ou prod."
      read -p "Environnement (dev, prod): " projectEnvironment
    done
  else
    echo -e "${YELLOW}Environnement (par défaut)${NC}: $projectEnvironment"
  fi

  # Handle port for React/Vue projects in dev
  if [[ ( "$projectType" == "React" || "$projectType" == "Vue" ) && "$projectEnvironment" == "dev" ]]; then 
    if [ -z "$projectPort" ]; then
      read -p "Port (entre 3000 et 9000): " projectPort
      
      # Validate port is a number between 1024 and 65535
      while ! [[ "$projectPort" =~ ^[0-9]+$ ]] || [ "$projectPort" -lt 1024 ] || [ "$projectPort" -gt 65535 ]; do
        log_error "Veuillez saisir un numéro de port valide (entre 1024 et 65535)"
        read -p "Port: " projectPort
      done
    else
      echo -e "${YELLOW}Port (par défaut)${NC}: $projectPort"
    fi
  fi
}

# ==================================
# Project setup functions
# ==================================
create_virtual_url() {
  log_info "Ajout de l'entrée dans /etc/hosts pour $projectUrl"
  
  if grep -q "^127.0.0.1 $projectUrl$" /etc/hosts; then
    log_warning "L'entrée pour $projectUrl existe déjà dans /etc/hosts"
  else
    echo "127.0.0.1 $projectUrl" | sudo tee -a /etc/hosts >/dev/null
    log_success "Entrée ajoutée à /etc/hosts"
  fi
}

create_virtual_host_nginx() {
  log_info "Création du virtual host pour $projectUrl ($projectType)"

  configFile="/etc/nginx/sites-available/$projectUrl.conf"

  # Check if file already exists
  if [ -f "$configFile" ]; then
    log_error "Le fichier $configFile existe déjà. Opération annulée."
    return 1
  fi

  log_info "Création du fichier de configuration Nginx..."
  sudo touch "$configFile"

  case "$projectType" in
  Laravel)
    cat <<EOF | sudo tee "$configFile" > /dev/null
# Virtual Host for Laravel project: $projectName
# Created: $(date)
server {
    listen 80;
    server_name $projectUrl;
    root /var/www/$projectName/public;
    
    index index.php index.html index.htm;
    
    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php$projectPhpVersion-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
    
    # Add headers to serve security related headers
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
}
EOF
    ;;

  React | Vue)
    if [ "$projectEnvironment" = "dev" ] && [ -n "$projectPort" ]; then
      # Configuration for development environment with proxy pass
      cat <<EOF | sudo tee "$configFile" > /dev/null
# Virtual Host for $projectType project in development: $projectName
# Created: $(date)
server {
    listen 80;
    server_name $projectUrl;
    
    location / {
        proxy_pass http://localhost:$projectPort;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_read_timeout 86400; # Increased timeout for development
    }
    
    # Add headers to serve security related headers
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
}
EOF
    else
      # Configuration for production environment
      cat <<EOF | sudo tee "$configFile" > /dev/null
# Virtual Host for $projectType project in production: $projectName
# Created: $(date)
server {
    listen 80;
    server_name $projectUrl;
    root /var/www/$projectUrl/build;
    
    index index.html;
    
    location / {
        try_files \$uri \$uri/ /index.html;
    }
    
    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 30d;
        add_header Cache-Control "public, no-transform";
    }
    
    # Add headers to serve security related headers
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
}
EOF
    fi
    ;;

  *)
    log_error "Type de projet non reconnu. Veuillez choisir entre Laravel, React ou Vue."
    return 1
    ;;
  esac

  # Enable site and reload Nginx
  log_info "Activation du virtual host..."
  sudo ln -sf "$configFile" "/etc/nginx/sites-enabled/"
  
  log_info "Test de la configuration Nginx..."
  if sudo nginx -t; then
    log_info "Redémarrage de Nginx..."
    sudo systemctl reload nginx
    log_success "Virtual Host créé et activé pour $projectUrl ($projectType)"
  else
    log_error "La configuration Nginx contient des erreurs. Veuillez vérifier le fichier $configFile."
    return 1
  fi
}

setup_project_directory() {
  log_info "Configuration du répertoire du projet..."
  
  # Create project directory if it doesn't exist
  if [ ! -d "$projectDirectory" ]; then
    log_info "Création du répertoire $projectDirectory..."
    mkdir -p "$projectDirectory"
  fi
  
  log_success "Répertoire du projet configuré"
}

create_summary() {
  echo -e "\n${GREEN}=== Résumé de la configuration ===${NC}"
  echo -e "${BLUE}Nom du projet:${NC} $projectName"
  echo -e "${BLUE}URL du projet:${NC} $projectUrl"
  echo -e "${BLUE}Type de projet:${NC} $projectType"
  echo -e "${BLUE}Répertoire:${NC} $projectDirectory"
  
  if [ "$projectType" = "Laravel" ]; then
    echo -e "${BLUE}Version PHP:${NC} $projectPhpVersion"
  fi
  
  echo -e "${BLUE}Environnement:${NC} $projectEnvironment"
  
  if [[ ( "$projectType" == "React" || "$projectType" == "Vue" ) && "$projectEnvironment" == "dev" ]]; then
    echo -e "${BLUE}Port:${NC} $projectPort"
  fi
  
  echo -e "\n${GREEN}Configuration NGINX:${NC} /etc/nginx/sites-available/$projectUrl.conf"
  
  if [ "$projectType" = "Laravel" ]; then
    echo -e "\n${YELLOW}Pour finaliser l'installation Laravel:${NC}"
    echo "cd $projectDirectory"
    echo "composer create-project laravel/laravel $projectName"
  elif [ "$projectType" = "React" ]; then
    echo -e "\n${YELLOW}Pour finaliser l'installation React:${NC}"
    echo "cd $projectDirectory"
    echo "npx create-react-app $projectName"
  elif [ "$projectType" = "Vue" ]; then
    echo -e "\n${YELLOW}Pour finaliser l'installation Vue:${NC}"
    echo "cd $projectDirectory"
    echo "npm init vue@latest $projectName"
  fi
}

# ==================================
# Main function
# ==================================
main() {
  print_banner
  check_dependencies
  load_config
  process_arguments "$@"
  read_project_structure
  
  echo -e "\n${BLUE}Résumé de la configuration:${NC}"
  echo -e "Nom: $projectName, URL: $projectUrl, Type: $projectType"
  if [ "$projectType" = "Laravel" ]; then 
    echo -e "PHP: $projectPhpVersion"
  fi
  echo -e "Environnement: $projectEnvironment"
  
  read -p "Confirmez-vous ces informations ? (o/n): " confirmation
  if [[ "$confirmation" != "o" && "$confirmation" != "O" ]]; then
    log_warning "Configuration annulée par l'utilisateur."
    return 0
  fi
  
  setup_project_directory
  create_virtual_host_nginx
  create_virtual_url
  save_config
  create_summary
  
  log_success "Configuration terminée avec succès !"
}

# Initialize log file
> "$LOG_FILE"
log_info "Démarrage du script $(basename "$0")"

# Run the main function with all arguments
main "$@"