#!/usr/bin/env bash
# =============================================================================
# Nom du script : NOM_DU_SCRIPT.sh  (commande : nom-commande)
# Description   : Ce que fait le script, en une phrase
# Usage         : nom-commande [argument] [--option]
# Auteur        : Ando Romain
# Version       : 1.0
# =============================================================================
set -euo pipefail

readonly SCRIPT_NAME="$(basename "$0")"

# Couleurs
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCÈS]${NC} $*"; }
log_warning() { echo -e "${YELLOW}[ATTENTION]${NC} $*"; }
log_error()   { echo -e "${RED}[ERREUR]${NC} $*" >&2; }

usage() {
  cat << USAGE
Usage : $SCRIPT_NAME [argument]

  argument   Description (défaut : valeur)
  -h, --help Affiche cette aide
USAGE
}

# Décommenter si le script doit tourner en root
# if [[ $EUID -ne 0 ]]; then
#   log_error "Ce script nécessite les droits administrateur : sudo $SCRIPT_NAME"
#   exit 1
# fi

main() {
  case "${1:-}" in
    -h|--help) usage; exit 0 ;;
  esac

  local arg="${1:-valeur_par_defaut}"

  # Vérifier les dépendances
  for cmd in df; do
    command -v "$cmd" >/dev/null || { log_error "Commande manquante : $cmd"; exit 1; }
  done

  log_info "Traitement de : $arg"
  # ... logique du script ...
  log_success "Terminé"
}

main "$@"
