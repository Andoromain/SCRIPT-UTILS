# =============================================================================
# Alias et petites fonctions chargés par ~/.bashrc (via install.sh)
# Ajoute ici les raccourcis qui ne méritent pas un script complet.
# =============================================================================
alias ll='ls -lah'
alias gs='git status -sb'
alias art='php artisan'
alias dsize='du -sh -- * 2>/dev/null | sort -h'

# port 8000 -> quel processus écoute
port() { sudo ss -ltnp | grep ":$1\b"; }
