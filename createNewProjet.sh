#!/bin/bash

clear

projectTypes=("Laravel" "React" "Vue")

projectName=""
projectUrl=""
projectType=""
projectDirectory=""
projectPhpVersion=""
projectEnvironment=""
projectPort=""

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

printWelcome() {
  echo "******* Bienvenue sur l'assistance de nouveau projet ***********"
  echo -e "\n\n"
}

printTab() {
  index=1
  local table=("$@")
  for element in "${table[@]}"; do
    echo -e "$index - $element"
    ((index++))
  done
}

readProjectStructure() {
  if [ -z "$projectName" ]; then
    read -p "Saisir le nom du projet  : " projectName
  else
    echo "Nom du projet (default): $projectName"
  fi

  if [ -z "$projectUrl" ]; then
    read -p "Saisir l'url du projet (sans http://) : " projectUrl
  else
    echo "Url du projet (default): $projectUrl"
  fi

  if [ -z "$projectDirectory" ]; then
    read -p "Saisir le chemin du projet : " projectDirectory
  else
    echo "Chemin du projet (default): $projectDirectory"
  fi

  echo -e "\nChoisir le type de projet"
  printTab "${projectTypes[@]}"
  if [ -z "$projectType" ]; then
    read -p "Choix : " choix
    
    # Conversion du choix numérique en type de projet
    if [ "$choix" = "1" ]; then
      projectType="Laravel"
    elif [ "$choix" = "2" ]; then
      projectType="React"
    elif [ "$choix" = "3" ]; then
      projectType="Vue"
    else
      echo "Choix non valide. Veuillez sélectionner un numéro entre 1 et 3."
      projectType=""
      return
    fi
  else
    echo "Type du projet (default): $projectType"
    # Si projectType est un nombre, conversion en nom de type
    if [ "$projectType" = "1" ]; then
      projectType="Laravel"
    elif [ "$projectType" = "2" ]; then
      projectType="React"
    elif [ "$projectType" = "3" ]; then
      projectType="Vue"
    fi
  fi

  if [ "$projectType" = "Laravel" ] && [ -z "$projectPhpVersion" ]; then
    read -p "Version du php : " projectPhpVersion
  elif [ "$projectType" = "Laravel" ]; then
    echo "Version du PHP (default): $projectPhpVersion"
  fi

  if [ -z "$projectEnvironment" ]; then
    read -p "Environnement (dev, prod) : " projectEnvironment
    while [ "$projectEnvironment" != "dev" ] && [ "$projectEnvironment" != "prod" ]; do
      echo "Environnement non reconnu. Veuillez choisir entre dev ou prod."
      read -p "Environnement (dev, prod) : " projectEnvironment
    done
  else
    echo "Environnement (default): $projectEnvironment"
  fi

  # Gestion du port pour les projets React/Vue en dev
  if [[ ( "$projectType" == "React" || "$projectType" == "Vue" ) && "$projectEnvironment" == "dev" ]]; then 
    if [ -z "$projectPort" ]; then
      read -p "Port : " projectPort
    else
      echo "Port (default): $projectPort"
    fi
  fi

  # Validation des champs obligatoires
  if [ -z "$projectName" ] || [ -z "$projectUrl" ] || [ -z "$projectDirectory" ] || [ -z "$projectType" ] || [ -z "$projectEnvironment" ]; then
    echo "Veuillez remplir tous les champs obligatoires."
    readProjectStructure
  fi
  
  # Validation supplémentaire pour les projets qui nécessitent un port
  if [[ ( "$projectType" == "React" || "$projectType" == "Vue" ) && "$projectEnvironment" == "dev" && -z "$projectPort" ]]; then
    echo "Le port est obligatoire pour les projets React/Vue en environnement de développement."
    readProjectStructure
  fi
}

createVirtualUrl() {
  echo "127.0.0.1 $projectUrl" | sudo tee -a /etc/hosts >/dev/null
}

createVirtualHostNginx() {
  local projectUrl="$1"
  local projectType="$2"
  local projectPhpVersion="$3"
  local projectEnvironment="$4"
  local projectPort="$5"

  echo "Création du virtual host pour $projectUrl ($projectType)"

  configFile="/etc/nginx/sites-available/$projectUrl.conf"

  # Vérifier si le fichier existe déjà
  if [ -f "$configFile" ]; then
    echo "Le fichier $configFile existe déjà. Opération annulée."
    return 1
  fi

  sudo touch "$configFile"

  case "$projectType" in
  Laravel)
    cat <<EOF | sudo tee "$configFile"
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
}
EOF
    ;;

  React | Vue)
    if [ "$projectEnvironment" = "dev" ] && [ -n "$projectPort" ]; then
      # Configuration pour l'environnement de développement avec proxy pass
      cat <<EOF | sudo tee "$configFile"
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
    }
}
EOF
    else
      # Configuration pour l'environnement de production
      cat <<EOF | sudo tee "$configFile"
server {
    listen 80;
    server_name $projectUrl;
    root /var/www/$projectUrl/build;
    
    index index.html;
    
    location / {
        try_files \$uri /index.html;
    }
}
EOF
    fi
    ;;

  *)
    echo "Type de projet non reconnu. Veuillez choisir entre Laravel, React ou Vue."
    return 1
    ;;
  esac

  # Activer le site et recharger Nginx
  sudo ln -s "$configFile" "/etc/nginx/sites-enabled/"
  sudo systemctl reload nginx

  echo "Virtual Host créé et activé pour $projectUrl ($projectType)"
}

## fonction main :::

printWelcome
readProjectStructure
createVirtualHostNginx "$projectUrl" "$projectType" "$projectPhpVersion" "$projectEnvironment" "$projectPort"
createVirtualUrl

echo -e " ------- Terminé ------ "