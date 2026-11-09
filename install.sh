#!/usr/bin/env bash
# =============================================================================
# Nom du script : install.sh
# Description   : Installe les commandes de SCRIPT-UTILS dans /usr/local/bin
#                 (liens symboliques), les alias shell et les timers systemd.
#                 Relançable sans risque après chaque ajout de script.
# Auteur        : Ando Romain
# Version       : 2.0
# =============================================================================
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Dossier du dépôt, quel que soit l'endroit d'où on lance le script
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="/usr/local/bin"

# -----------------------------------------------------------------------------
# Commandes installées : "nom-de-commande:chemin/relatif/au/depot"
# Pour ajouter un script : le mettre dans scripts/<categorie>/ puis ajouter
# une ligne ici, et relancer ./install.sh
# -----------------------------------------------------------------------------
COMMANDS=(
  "laravel-new:scripts/laravel/createLaravelProject.sh"
  "nginx-new:scripts/web/createNewVhostNginx.sh"
  "nginx-delete:scripts/web/deleteVhostNginx.sh"
  "apache-new:scripts/web/createNewVhostApache.sh"
  "apache-delete:scripts/web/deleteVhostApache.sh"
  "adminsys:scripts/system/adminsys.sh"
  "diskwatch:scripts/system/diskwatch.sh"
)

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          INSTALLATION SCRIPT-UTILS         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}\n"

# 1. Liens symboliques dans /usr/local/bin ------------------------------------
echo -e "${BLUE}[1/4]${NC} Commandes dans $BIN_DIR (sudo requis)"
for entry in "${COMMANDS[@]}"; do
  name="${entry%%:*}"
  target="$REPO/${entry#*:}"
  if [ ! -f "$target" ]; then
    echo -e "  ${RED}[ERREUR]${NC} $target introuvable, ignoré"
    continue
  fi
  chmod +x "$target"
  sudo ln -sfn "$target" "$BIN_DIR/$name"
  echo -e "  ${GREEN}✓${NC} $name -> ${entry#*:}"
done

# 2. Suppression des anciens alias (version 1.0 de install.sh) -----------------
# Ils pointaient vers les anciens chemins à la racine du dépôt et
# masqueraient les nouvelles commandes.
echo -e "\n${BLUE}[2/4]${NC} Nettoyage des anciens alias dans ~/.bashrc"
touch ~/.bashrc
for entry in "${COMMANDS[@]}"; do
  name="${entry%%:*}"
  if grep -q "^alias $name=" ~/.bashrc; then
    sed -i "/^alias $name=/d" ~/.bashrc
    echo -e "  ${YELLOW}-${NC} alias $name supprimé"
  fi
done

# 3. Alias personnels -----------------------------------------------------------
echo -e "\n${BLUE}[3/4]${NC} Chargement de shell/aliases.sh"
LINE="[ -f \"$REPO/shell/aliases.sh\" ] && source \"$REPO/shell/aliases.sh\"  # SCRIPT-UTILS"
if ! grep -qF "# SCRIPT-UTILS" ~/.bashrc; then
  echo "$LINE" >> ~/.bashrc
  echo -e "  ${GREEN}✓${NC} ligne ajoutée à ~/.bashrc"
else
  sed -i "\|# SCRIPT-UTILS\$|c\\$LINE" ~/.bashrc
  echo -e "  ${GREEN}✓${NC} déjà présent (chemin mis à jour)"
fi

# 4. Units systemd utilisateur ------------------------------------------------
echo -e "\n${BLUE}[4/4]${NC} Timers systemd utilisateur"
if command -v systemctl >/dev/null && systemctl --user show-environment >/dev/null 2>&1; then
  mkdir -p ~/.config/systemd/user
  for unit in "$REPO"/systemd/*; do
    [ -f "$unit" ] || continue
    ln -sfn "$unit" ~/.config/systemd/user/"$(basename "$unit")"
    echo -e "  ${GREEN}✓${NC} $(basename "$unit")"
  done
  systemctl --user daemon-reload
  echo -e "  Pour activer : ${YELLOW}systemctl --user enable --now diskwatch.timer${NC}"
else
  echo -e "  ${YELLOW}[INFO]${NC} systemd utilisateur indisponible, étape ignorée"
fi

echo -e "\n${GREEN}=== Installation terminée ===${NC}"
echo -e "Recharge ton shell : ${YELLOW}source ~/.bashrc${NC}"
