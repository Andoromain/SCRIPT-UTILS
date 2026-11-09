#!/usr/bin/env bash
# Vérifie tous les scripts du dépôt : syntaxe bash + shellcheck (si installé)
# et cohérence entre install.sh (COMMANDS) et les fichiers présents.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
status=0

echo "== Syntaxe bash =="
for f in install.sh tools/*.sh scripts/*/*.sh scripts/_template.sh; do
  if bash -n "$f"; then echo "ok   $f"; else echo "FAIL $f"; status=1; fi
done

echo "== shellcheck =="
if command -v shellcheck >/dev/null; then
  # On vérifie en priorité les scripts récents ; les anciens peuvent avoir des avertissements.
  shellcheck -S warning install.sh tools/*.sh scripts/_template.sh scripts/system/diskwatch.sh || status=1
else
  echo "shellcheck absent (sudo apt install shellcheck), étape ignorée"
fi

echo "== Commandes déclarées dans install.sh =="
while IFS= read -r path; do
  if [ -f "$path" ]; then echo "ok   $path"; else echo "FAIL $path introuvable"; status=1; fi
done < <(grep -oE '"[a-z0-9-]+:scripts/[^"]+"' install.sh | sed -E 's/"[^:]+:([^"]+)"/\1/')

echo "== Scripts non déclarés =="
for f in scripts/*/*.sh; do
  grep -q ":$f\"" install.sh || { echo "WARN $f n'est pas dans COMMANDS"; }
done

exit $status
