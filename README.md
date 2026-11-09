# SCRIPT-UTILS

Une collection complète de scripts utilitaires pour automatiser la gestion des hôtes virtuels NGINX/Apache et simplifier les workflows de configuration de projets.

## Présentation

Ce dépôt contient des scripts professionnels conçus pour améliorer la productivité des développeurs en automatisant la création et la gestion d'hôtes virtuels NGINX et Apache. Ces utilitaires permettent une mise en place rapide d'environnements pour différents types de projets, notamment Laravel, React et Vue.

## Structure

```
SCRIPT-UTILS/
├── scripts/
│   ├── web/        # vhosts Nginx / Apache (création, suppression)
│   ├── laravel/    # création de projets Laravel
│   └── system/     # administration système, surveillance disque
├── systemd/        # services et timers utilisateur (ex. diskwatch)
├── shell/
│   └── aliases.sh  # alias et petites fonctions bash
├── docs/
│   └── aide-memoire.md  # commandes ponctuelles à copier-coller
├── tools/check.sh  # vérification du dépôt
├── AGENTS.md       # règles pour les assistants IA
└── install.sh
```

## Installation

```bash
git clone git@github.com:Andoromain/SCRIPT-UTILS.git
cd SCRIPT-UTILS
./install.sh
source ~/.bashrc
```

`install.sh` crée des liens symboliques dans `/usr/local/bin`. Les commandes sont donc
disponibles partout, y compris avec `sudo` (`sudo apache-delete`, `sudo adminsys`), et
toute modification d'un script dans le dépôt est prise en compte immédiatement.
Il supprime aussi les anciens alias de la v1 dans `~/.bashrc` et charge `shell/aliases.sh`.
On peut le relancer autant de fois que nécessaire.

| Commande | Script | Description |
|----------|--------|-------------|
| `laravel-new` | `scripts/laravel/createLaravelProject.sh` | Crée un nouveau projet Laravel |
| `nginx-new` | `scripts/web/createNewVhostNginx.sh` | Crée un hôte virtuel Nginx |
| `nginx-delete` | `scripts/web/deleteVhostNginx.sh` | Supprime un hôte virtuel Nginx |
| `apache-new` | `scripts/web/createNewVhostApache.sh` | Crée un hôte virtuel Apache |
| `apache-delete` | `scripts/web/deleteVhostApache.sh` | Supprime un hôte virtuel Apache (sudo) |
| `adminsys` | `scripts/system/adminsys.sh` | Outil d'administration système (sudo) |
| `diskwatch` | `scripts/system/diskwatch.sh` | Alerte si une partition dépasse un seuil |

## Ajouter une commande

1. **Script complet** : le placer dans `scripts/<catégorie>/`, ajouter une ligne
   `"nom-commande:scripts/<catégorie>/fichier.sh"` dans le tableau `COMMANDS` de
   `install.sh`, puis relancer `./install.sh`.
2. **Raccourci** : l'ajouter dans `shell/aliases.sh` (actif au prochain `source ~/.bashrc`).
3. **Commande à retenir** : la noter dans `docs/aide-memoire.md`.

### Avec un assistant IA

Les règles du dépôt sont dans `AGENTS.md` (lu par Codex, Cursor… et par Claude Code via `CLAUDE.md`).
Il suffit de demander, depuis le dépôt : *« ajoute un script qui nettoie les logs de plus de 7 jours »*.
L'agent part de `scripts/_template.sh`, déclare la commande dans `install.sh`, met à jour ce README
et valide avec `./tools/check.sh`.

Ne jamais committer de mot de passe, token ou IP de serveur : utiliser un `.env` (ignoré par git).

## Scripts disponibles

### `createLaravelProject.sh` (alias: `laravel-new`)

Ce script automatise la création d'un nouveau projet Laravel avec différentes options.

**Fonctionnalités :**
- Création d'un projet Laravel (version spécifique ou dernière version)
- Installation optionnelle de kits de démarrage (Breeze ou Jetstream)
- Configuration de différentes stacks (Blade, Livewire, Vue, React)
- Support optionnel des équipes avec Jetstream

### `createNewVhostNginx.sh` (alias: `nginx-new`)

Ce script crée un hôte virtuel Nginx pour différents types de projets.

**Fonctionnalités :**
- Création de configurations Nginx optimisées pour Laravel, React ou Vue
- Gestion automatique des entrées DNS locales dans le fichier hosts
- Configuration spécifique à l'environnement (développement/production)
- Mémorisation des préférences utilisateur

### `deleteVhostNginx.sh` (alias: `nginx-delete`)

Ce script permet de supprimer un hôte virtuel Nginx et les entrées associées.

**Fonctionnalités :**
- Affichage interactif des configurations Nginx disponibles
- Suppression des fichiers de configuration des répertoires Nginx appropriés
- Nettoyage des entrées DNS correspondantes du fichier hosts
- Rechargement automatique du service Nginx après les modifications

### `createNewVhostApache.sh` (alias: `apache-new`)

Ce script crée un hôte virtuel Apache pour différents types de projets.

**Fonctionnalités :**
- Création de configurations Apache optimisées pour Laravel, React ou Vue
- Gestion automatique des entrées DNS locales dans le fichier hosts
- Configuration spécifique à l'environnement (développement/production)
- Mémorisation des préférences utilisateur

### `deleteVhostApache.sh` (alias: `apache-delete`)

Ce script permet de supprimer un hôte virtuel Apache et les entrées associées.

**Fonctionnalités :**
- Affichage interactif des configurations Apache disponibles
- Suppression des fichiers de configuration des répertoires Apache appropriés
- Nettoyage des entrées DNS correspondantes du fichier hosts
- Rechargement automatique du service Apache après les modifications

### `adminsys.sh` (alias: `adminsys`)

Cet outil d'administration système offre plusieurs fonctionnalités pour gérer votre serveur.

**Fonctionnalités :**
- Affichage des informations système
- Gestion des utilisateurs (création, suppression, modification)
- Gestion du réseau (interfaces, configuration IP, test de connectivité)
- Gestion des services (démarrage, arrêt, redémarrage)
- Consultation des journaux système
- Création de sauvegardes
- Vérifications de sécurité

### `diskwatch.sh` (commande : `diskwatch`)

Surveille l'espace disque et alerte au-delà d'un seuil (80 % par défaut).

**Fonctionnalités :**
- `diskwatch 90` pour un seuil à 90 %
- Ignore les systèmes de fichiers virtuels (tmpfs, snap/squashfs, overlay…)
- Notification de bureau via `notify-send` (paquet `libnotify-bin`)
- Exécution automatique toutes les 30 min : `systemctl --user enable --now diskwatch.timer`

## Prérequis système

- Environnement shell Bash
- Serveur web NGINX et/ou Apache
- Privilèges sudo pour les modifications de fichiers système
- PHP (pour les projets Laravel)
- Node.js et npm (pour les projets React/Vue)

## Configuration

Le script `createNewVhostNginx.sh` et `createNewVhostApache.sh` conservent les préférences utilisateur dans `~/.config/project-creator.conf`, améliorant l'efficacité pour les tâches de création de projets répétitives.

## Considérations de sécurité

- Les scripts nécessitent des privilèges sudo pour modifier les fichiers système et les configurations
- Vérifiez toujours les configurations générées avant de les déployer dans des environnements de production
- Implémentez des permissions de fichiers appropriées sur les répertoires et fichiers de configuration créés

## Auteur

Ando Romain
