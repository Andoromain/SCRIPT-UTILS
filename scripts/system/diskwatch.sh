#!/usr/bin/env bash
# =============================================================================
# Nom du script : diskwatch.sh  (commande : diskwatch)
# Description   : Alerte quand une partition dépasse un seuil d'utilisation
# Usage         : diskwatch [seuil%]   (défaut : 80)
# =============================================================================
limit="${1:-80}"
df -h --output=target,pcent -x tmpfs -x devtmpfs -x squashfs -x overlay -x efivarfs \
  | tail -n +2 | while read -r mount pct; do
  used="${pct%\%}"
  if [ "$used" -ge "$limit" ]; then
    echo "AVERTISSEMENT  $mount est à $pct, la limite est de $limit%"
    notify-send -u critical "Disque presque plein" "$mount est à $pct" 2>/dev/null
  else
    echo "ok             $mount est à $pct"
  fi
done
