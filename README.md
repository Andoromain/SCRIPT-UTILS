# SCRIPT-UTILS

A comprehensive collection of utility scripts for automating NGINX virtual host management and streamlining project setup workflows.

## Overview

This repository contains professional-grade scripts designed to enhance developer productivity by automating the creation and management of NGINX virtual hosts. These utilities support rapid environment setup for various project types including Laravel, React, and Vue applications.

## Key Scripts

| Script | Description | Usage |
|--------|-------------|-------|
| `createNewProjet.sh` | Creates a new project with complete NGINX virtual host configuration | `sudo ./createNewProjet.sh [projectName] [projectUrl] [projectDirectory] [projectType] [phpVersion] [environment] [port]` |
| `deleteProject.sh` | Removes NGINX virtual host configurations and related entries | `sudo ./deleteProject.sh` |

## Detailed Documentation

### `createNewProjet.sh`

This script automates the complete workflow for setting up new development projects with appropriate NGINX configurations.

#### Features:

- Creates optimized NGINX virtual host configurations for Laravel, React, or Vue projects
- Automatically manages local DNS entries in the hosts file
- Configures environment-specific settings (development/production)
- Implements user preference persistence for streamlined workflow
- Provides detailed logging and robust error handling

#### Parameters:

- `projectName`: Name of the project
- `projectUrl`: Domain for the virtual host (without http://)
- `projectDirectory`: Target directory for project creation
- `projectType`: Project framework (1=Laravel, 2=React, 3=Vue)
- `phpVersion`: PHP version for Laravel projects (e.g., 8.2)
- `environment`: Deployment environment (dev/prod)
- `port`: Port number for development React/Vue projects

### `deleteProject.sh`

This utility manages the clean removal of NGINX virtual host configurations and related system entries.

#### Features:

- Displays interactive list of available NGINX configurations
- Removes configuration files from appropriate NGINX directories
- Cleans up corresponding DNS entries from hosts file
- Automatically reloads NGINX service after changes
- Provides confirmation prompts to prevent accidental deletions

## System Requirements

- Bash shell environment
- NGINX web server
- Sudo privileges for system file modifications
- PHP (for Laravel projects)
- Node.js and npm (for React/Vue projects)

## Installation

```bash
# Clone this repository
git clone https://github.com/yourusername/script-utils.git

# Make the scripts executable
chmod +x script-utils/*.sh

# Run scripts with sudo privileges
cd script-utils
sudo ./createNewProjet.sh
```

## Configuration

The `createNewProjet.sh` script maintains user preferences in `~/.config/project-creator.conf`, enhancing efficiency for repeated project creation tasks.

## Security Considerations

- Scripts require sudo privileges for modifying system files and NGINX configurations
- Always review generated configurations before deploying to production environments
- Implement appropriate file permissions on created directories and configuration files

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

Released under the MIT License. See the LICENSE file for details.

## Author

Ando Romain