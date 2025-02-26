#!/bin/bash

clear

projectTypes=("Laravel" "React" "Vue")

projectName=""
projectUrl=""
projectType=""
projectDirectory=""
projectPhpVersion=""
projectEnvironment=""

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

printWelcome() {
  echo "******* Bienvenue sur l'assistance de nouveau projet ***********"
  echo -e "\n\n"
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
    read -p "Choix : " projectType
  else
    echo "Type du projet (default): $projectType"
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
    if [ "$projectEnvironment" != "dev" ] && [ "$projectEnvironment" != "prod" ]; then
      echo "Environnement non reconnu. Veuillez choisir entre dev ou prod."
      read -p "Environnement (dev, prod) : " projectEnvironment
    fi
  else
    echo "Environnement (default): $projectEnvironment"
  fi

   if [[ ( "$projectType" == "React" || "$projectType" == "Vue" ) && -z "$projectEnvironment" ]]; then 
    # Your commands here
  fi
}

createVirtualUrl() {
  echo "127.0.0.1 $projectUrl" | sudo tee -a /etc/hosts >/dev/null
}

createVirtualHostNginx() {
  local projectUrl="$1"
  local projectType="$2"
  local projectPhpVersion="$3"

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
# createVirtualHostNginx "$projectUrl" "$projectType" "$projectPhpVersion"
# createVirtualUrl

echo -e " ------- Terminé ------ "
