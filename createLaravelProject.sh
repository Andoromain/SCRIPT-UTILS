#!/bin/bash

#script for creating project laravel

echo "=== Laravel Project Creator ==="
echo ""

# Ask for project location
read -p "Enter the project directory path (e.g., /var/www/html/): " project_path
if [[ -z "$project_path" ]]; then
    project_path=$(pwd)
fi

# Ensure path ends with trailing slash
[[ "${project_path}" != */ ]] && project_path="${project_path}/"

# Ask for project name
read -p "Enter project name: " project_name
if [[ -z "$project_name" ]]; then
    echo "Project name is required."
    exit 1
fi

# Ask for Laravel version
echo "Which Laravel version do you want to install?"
echo "1) Latest (default)"
echo "2) Specific version"
read -p "Select an option [1-2]: " version_option

laravel_version=""
if [[ "$version_option" == "2" ]]; then
    read -p "Enter Laravel version (e.g., 10.*, 9.*, 8.*): " laravel_version
fi

# Create the Laravel project
echo -e "\nCreating your Laravel project..."
cd "$project_path" || { echo "Failed to navigate to $project_path"; exit 1; }

if [[ -z "$laravel_version" ]]; then
    composer create-project laravel/laravel "$project_name"
else
    composer create-project "laravel/laravel:$laravel_version" "$project_name"
fi

# Navigate into the project directory
cd "$project_name" || { echo "Failed to navigate to $project_name"; exit 1; }

# Ask for starter kit preference
echo -e "\nWhich Laravel starter kit would you like to use?"
echo "1) None (default Laravel)"
echo "2) Laravel Breeze (lightweight authentication)"
echo "3) Laravel Jetstream (robust authentication & teams)"
read -p "Select an option [1-3]: " starter_kit

if [[ "$starter_kit" == "2" ]]; then
    # Laravel Breeze options
    echo -e "\nSelect Laravel Breeze stack:"
    echo "1) Blade with Alpine.js"
    echo "2) Livewire with Alpine.js"
    echo "3) Inertia with Vue"
    echo "4) Inertia with React"
    echo "5) API only"
    read -p "Select an option [1-5]: " breeze_option
    
    echo "Installing Laravel Breeze..."
    composer require laravel/breeze --dev
    
    case $breeze_option in
        1) php artisan breeze:install blade ;;
        2) php artisan breeze:install livewire ;;
        3) php artisan breeze:install vue ;;
        4) php artisan breeze:install react ;;
        5) php artisan breeze:install api ;;
        *) php artisan breeze:install blade ;;
    esac
    
    # Install and build assets (except API)
    if [[ "$breeze_option" != "5" ]]; then
        npm install
        npm run build
    fi
    
    echo "Laravel Breeze installed successfully!"
    
elif [[ "$starter_kit" == "3" ]]; then
    # Laravel Jetstream options
    echo -e "\nSelect Laravel Jetstream stack:"
    echo "1) Livewire (with Blade)"
    echo "2) Inertia.js (with Vue)"
    read -p "Select an option [1-2]: " jetstream_option
    
    # Ask for teams support
    echo -e "\nDo you want to enable teams support?"
    echo "1) No"
    echo "2) Yes"
    read -p "Select an option [1-2]: " teams_option
    
    teams_flag=""
    if [[ "$teams_option" == "2" ]]; then
        teams_flag="--teams"
    fi
    
    echo "Installing Laravel Jetstream..."
    composer require laravel/jetstream
    
    if [[ "$jetstream_option" == "2" ]]; then
        php artisan jetstream:install inertia $teams_flag
    else
        php artisan jetstream:install livewire $teams_flag
    fi
    
    # Install and build assets
    npm install
    npm run build
    
    echo "Laravel Jetstream installed successfully!"
fi

# Final setup
php artisan migrate

# Final message
echo -e "\n=== Laravel Project Created Successfully! ==="
echo "Project location: $project_path$project_name"
echo "To run your application:"
echo "cd $project_path$project_name"
echo "php artisan serve"
echo -e "\nReference: https://laravel.com/docs"