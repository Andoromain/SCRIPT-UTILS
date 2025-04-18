# SCRIPT-UTILS

Une collection complète de scripts utilitaires pour automatiser la gestion des hôtes virtuels NGINX/Apache et simplifier les workflows de configuration de projets.

## Présentation

Ce dépôt contient des scripts professionnels conçus pour améliorer la productivité des développeurs en automatisant la création et la gestion d'hôtes virtuels NGINX et Apache. Ces utilitaires permettent une mise en place rapide d'environnements pour différents types de projets, notamment Laravel, React et Vue.

## Installation

### Étape 1 : Obtenir les scripts
```bash
# Clonez ce dépôt
git clone https://github.com/yourusername/script-utils.git

# Accédez au dossier des scripts
cd script-utils
```

### Étape 2 : Configurer les scripts
```bash
# Rendez les scripts exécutables
chmod +x *.sh

# Exécutez le script d'installation pour configurer les alias
./install.sh
```

### Étape 3 : Activer les alias
```bash
# Rechargez votre profil bash pour activer les alias
source ~/.bashrc
```

Une fois l'installation terminée, vous pourrez utiliser les alias suivants :

| Alias | Description |
|-------|-------------|
| `laravel-new` | Crée un nouveau projet Laravel |
| `nginx-new` | Crée un hôte virtuel Nginx |
| `nginx-delete` | Supprime un hôte virtuel Nginx |
| `apache-new` | Crée un hôte virtuel Apache |
| `apache-delete` | Supprime un hôte virtuel Apache |
| `adminsys` | Lance l'outil d'administration système |

## Scripts disponibles

### `install.sh`

Ce script installe tous les alias dans votre fichier `~/.bashrc` pour faciliter l'utilisation des autres scripts.

**Fonctionnalités :**
- Vérifie que tous les scripts requis sont présents
- Rend les scripts exécutables
- Ajoute ou met à jour les alias dans le fichier `~/.bashrc`
- Affiche un résumé des alias installés

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