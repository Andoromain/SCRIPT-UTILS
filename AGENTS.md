# Instructions pour les agents IA (Claude Code, Codex, Cursor…)

Ce dépôt est une boîte à outils personnelle de scripts Bash (Linux, poste de dev et serveurs).
Messages affichés, commentaires et documentation : **en français**.

## Organisation

| Dossier | Contenu |
|---|---|
| `scripts/web/` | vhosts Nginx / Apache |
| `scripts/laravel/` | outils Laravel / PHP |
| `scripts/system/` | administration système, surveillance |
| `scripts/<nouvelle-categorie>/` | créer une catégorie si aucune ne convient (docker, git, db…) |
| `systemd/` | services et timers **utilisateur** |
| `shell/aliases.sh` | alias et fonctions d'une ou deux lignes |
| `docs/aide-memoire.md` | commandes ponctuelles à copier-coller |
| `tools/check.sh` | vérification du dépôt |

## Ajouter un script : procédure obligatoire

1. **Choisir la bonne forme** : script complet → `scripts/<catégorie>/` ; une ligne → `shell/aliases.sh` ;
   commande à retenir → `docs/aide-memoire.md`. Ne pas créer un script pour une seule commande.
2. **Partir de `scripts/_template.sh`** (en-tête, `set -euo pipefail`, fonctions `log_*`, `usage`, `main "$@"`).
3. **Nom du fichier** : camelCase `.sh` (ex. `cleanOldLogs.sh`). **Nom de commande** : kebab-case (ex. `logs-clean`).
4. **Déclarer la commande** dans le tableau `COMMANDS` de `install.sh` :
   `"nom-commande:scripts/<catégorie>/fichier.sh"`.
5. **Documenter** : ajouter une ligne au tableau des commandes et une section dans `README.md`.
6. **Vérifier** : `./tools/check.sh` doit passer sans `FAIL`.
7. **Commit** en français, un script par commit : `Ajout de <commande> : <description courte>`.

## Règles de code

- `#!/usr/bin/env bash`, `set -euo pipefail`, variables entre guillemets (`"$var"`).
- Arguments avec valeur par défaut (`"${1:-80}"`) et `-h/--help`.
- Vérifier les dépendances avec `command -v` avant de les utiliser.
- Si le script a besoin de root : le vérifier au début (`$EUID`) et indiquer `sudo <commande>`.
  Les commandes sont installées dans `/usr/local/bin`, donc `sudo <commande>` fonctionne.
- Actions destructrices (suppression, écrasement) : demander confirmation ou proposer `--dry-run`.
- Scripts **idempotents** quand c'est possible (relancer ne casse rien).
- Pas de chemins en dur propres à une machine (`/home/user/...`) : utiliser `$HOME` ou des arguments.
- Exclure les systèmes de fichiers virtuels (tmpfs, squashfs, overlay) dans les scripts disque.
- Timer périodique : un `.service` + `.timer` dans `systemd/` (ExecStart=/usr/local/bin/<commande>),
  pas de cron (cron n'a pas accès à la session graphique pour `notify-send`).

## Interdit

- Mot de passe, token, clé API, IP ou nom de serveur en dur → `.env` (ignoré par git).
- Modifier le comportement des scripts existants sans le demander.
- Recopier tel quel du code d'un article ou d'un blog : réécrire dans le style du dépôt.
