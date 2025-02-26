#!/bin/bash

clear

projectTypes=("Laravel" "React" "Vue")

projectName=""
projectUrl=""
projectType=""
projectPhpVersion=""
projectDirectory=""

printWelcome(){
	echo "******* Bienvenue sur l'assistance de nouveau projet ***********"
	echo -e "\n\n"
}

printTab(){ 
  index=1
  local table=("$@")
  for element in "${table[@]}"; do
  	echo -e "$index - $element"
  	((index++))
  done
}

readProjectStructure(){
  read -p "Saisir le nom du projet  : " projectName
  read -p "Saisir l'url du projet (sans http://) : " projectUrl
  read -p "Saisir le chemin du projet : " projectDirectory

  echo -e "Choisir le type de projet"
  printTab "${projectTypes[@]}"
  read -p "Choix : " projectType
  
  if [ "$projectType" = "Laravel" ]; then
    read -p "Version du php : " projectPhpVersion
  fi
}

createVirtualUrl(){
   echo "127.0.0.1 $projectUrl" | sudo tee -a /etc/hosts > /dev/null
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
    
    React|Vue)
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



