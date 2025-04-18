#!/bin/bash

# =============================================================================
# Nom du script : install.sh
# Description   : Installation des alias pour les scripts d'administration système
# Auteur        : Ando Romain
# Version       : 1.0
# =============================================================================

# Couleurs pour l'affichage terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Obtenir le chemin absolu du répertoire courant
SCRIPT_DIR=$(pwd)

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          INSTALLATION DES SCRIPTS          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo -e "\n"

# Vérifier si les scripts requis existent
required_scripts=(
  "createLaravelProject.sh"
  "createNewVhostNginx.sh"
  "deleteVhostNginx.sh"
  "createNewVhostApache.sh"
  "deleteVhostApache.sh"
  "adminsys.sh"
)

missing_scripts=0
for script in "${required_scripts[@]}"; do
  if [ ! -f "$SCRIPT_DIR/$script" ]; then
    echo -e "${RED}[ERREUR]${NC} Script requis '$script' non trouvé dans $SCRIPT_DIR"
    missing_scripts=1
  fi
done

if [ $missing_scripts -eq 1 ]; then
  echo -e "${RED}[ERREUR]${NC} Installation annulée. Veuillez vous assurer que tous les scripts requis existent."
  exit 1
fi

# Rendre tous les scripts exécutables
echo -e "${YELLOW}[INFO]${NC} Rendre les scripts exécutables (nécessite des droits administrateur)..."
sudo chmod +x "$SCRIPT_DIR"/*.sh
echo -e "${GREEN}[SUCCÈS]${NC} Les scripts sont maintenant exécutables"

# Définir les alias à ajouter
declare -A aliases=(
  ["laravel-new"]="$SCRIPT_DIR/createLaravelProject.sh"
  ["nginx-new"]="$SCRIPT_DIR/createNewVhostNginx.sh"
  ["nginx-delete"]="$SCRIPT_DIR/deleteVhostNginx.sh"
  ["apache-new"]="$SCRIPT_DIR/createNewVhostApache.sh"
  ["apache-delete"]="$SCRIPT_DIR/deleteVhostApache.sh"
  ["adminsys"]="$SCRIPT_DIR/adminsys.sh"
)

# Fonction pour ajouter un alias s'il n'existe pas déjà
add_alias_if_not_exists() {
  local alias_name=$1
  local script_path=$2
  
  if grep -q "alias $alias_name=" ~/.bashrc; then
    echo -e "${YELLOW}[INFO]${NC} Alias '$alias_name' existe déjà dans ~/.bashrc. Mise à jour..."
    # Supprimer l'alias existant
    sed -i "/alias $alias_name=/d" ~/.bashrc
  fi
  
  echo "alias $alias_name=\"$script_path\"" >> ~/.bashrc
  echo -e "${GREEN}[SUCCÈS]${NC} Ajout de l'alias: $alias_name -> $script_path"
}

# Ajouter les alias à .bashrc
echo -e "\n${BLUE}[TRAITEMENT]${NC} Ajout des alias à ~/.bashrc..."
for alias_name in "${!aliases[@]}"; do
  add_alias_if_not_exists "$alias_name" "${aliases[$alias_name]}"
done

echo -e "\n${GREEN}=== Installation terminée avec succès ! ===${NC}"
echo -e "Les alias suivants sont maintenant disponibles:"

for alias_name in "${!aliases[@]}"; do
  echo -e "  ${YELLOW}$alias_name${NC}"
done

echo -e "\n${BLUE}[ACTION]${NC} Chargement des alias dans la session courante..."
source ~/.bashrc
echo -e "${GREEN}[SUCCÈS]${NC} Les alias sont maintenant prêts à être utilisés !"