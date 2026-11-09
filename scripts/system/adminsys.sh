#!/bin/bash

# This script is used to gain access to a system
# Extended functionality for system administration tasks

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if running as root
check_root() {
    if [ "$(id -u)" != "0" ]; then
        echo -e "${RED}This script must be run as root!${NC}"
        exit 1
    fi
}

# System information function
get_system_info() {
    echo -e "${GREEN}=== System Information ===${NC}"
    echo -e "${BLUE}Hostname:${NC} $(hostname)"
    echo -e "${BLUE}OS:${NC} $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d \")"
    echo -e "${BLUE}Kernel:${NC} $(uname -r)"
    echo -e "${BLUE}CPU:${NC} $(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | sed 's/^[ \t]*//')"
    echo -e "${BLUE}Memory:${NC} $(free -h | grep Mem | awk '{print $2}')"
    echo -e "${BLUE}Disk Usage:${NC}"
    df -h | grep -v "tmpfs" | grep -v "udev"
    echo -e "${BLUE}Uptime:${NC} $(uptime | cut -d, -f1)"
}

# User management function
user_management() {
    local choice
    echo -e "${GREEN}=== User Management ===${NC}"
    echo "1. List all users"
    echo "2. Add a user"
    echo "3. Delete a user"
    echo "4. Change user password"
    echo "5. Add user to group"
    echo "6. Back to main menu"
    
    read -p "Enter your choice [1-6]: " choice
    
    case $choice in
        1) 
            echo -e "${YELLOW}User list:${NC}"
            cut -d: -f1,3 /etc/passwd | grep -v "nologin\|false" | sort
            ;;
        2)
            read -p "Enter username to add: " username
            read -p "Create home directory? (y/n): " create_home
            
            if [[ "$create_home" == "y" ]]; then
                useradd -m "$username"
            else
                useradd "$username"
            fi
            
            passwd "$username"
            echo -e "${GREEN}User $username created successfully!${NC}"
            ;;
        3)
            read -p "Enter username to delete: " username
            read -p "Remove home directory? (y/n): " remove_home
            
            if [[ "$remove_home" == "y" ]]; then
                userdel -r "$username"
            else
                userdel "$username"
            fi
            
            echo -e "${GREEN}User $username deleted successfully!${NC}"
            ;;
        4)
            read -p "Enter username to change password: " username
            passwd "$username"
            ;;
        5)
            read -p "Enter username: " username
            read -p "Enter group name: " groupname
            
            usermod -aG "$groupname" "$username"
            echo -e "${GREEN}User $username added to group $groupname!${NC}"
            ;;
        6) 
            return
            ;;
        *)
            echo -e "${RED}Invalid choice!${NC}"
            ;;
    esac
}

# Network management function
network_management() {
    local choice
    echo -e "${GREEN}=== Network Management ===${NC}"
    echo "1. Show network interfaces"
    echo "2. Display IP configuration"
    echo "3. Test connectivity"
    echo "4. Show open ports"
    echo "5. DNS lookup"
    echo "6. Back to main menu"
    
    read -p "Enter your choice [1-6]: " choice
    
    case $choice in
        1) 
            echo -e "${YELLOW}Network interfaces:${NC}"
            ip -c link show
            ;;
        2)
            echo -e "${YELLOW}IP configuration:${NC}"
            ip -c addr show
            ;;
        3)
            read -p "Enter hostname or IP to ping: " target
            ping -c 4 "$target"
            ;;
        4)
            echo -e "${YELLOW}Open ports:${NC}"
            if command -v netstat &> /dev/null; then
                netstat -tuln
            elif command -v ss &> /dev/null; then
                ss -tuln
            else
                echo -e "${RED}Neither netstat nor ss found!${NC}"
            fi
            ;;
        5)
            read -p "Enter domain to lookup: " domain
            nslookup "$domain"
            ;;
        6) 
            return
            ;;
        *)
            echo -e "${RED}Invalid choice!${NC}"
            ;;
    esac
}

# Service management function
service_management() {
    local choice
    echo -e "${GREEN}=== Service Management ===${NC}"
    echo "1. List all services"
    echo "2. Check service status"
    echo "3. Start a service"
    echo "4. Stop a service"
    echo "5. Restart a service"
    echo "6. Enable service on boot"
    echo "7. Disable service on boot"
    echo "8. Back to main menu"
    
    read -p "Enter your choice [1-8]: " choice
    
    case $choice in
        1) 
            echo -e "${YELLOW}Active services:${NC}"
            systemctl list-units --type=service --state=running
            ;;
        2)
            read -p "Enter service name: " service
            systemctl status "$service"
            ;;
        3)
            read -p "Enter service to start: " service
            systemctl start "$service"
            echo -e "${GREEN}Service $service started!${NC}"
            ;;
        4)
            read -p "Enter service to stop: " service
            systemctl stop "$service"
            echo -e "${GREEN}Service $service stopped!${NC}"
            ;;
        5)
            read -p "Enter service to restart: " service
            systemctl restart "$service"
            echo -e "${GREEN}Service $service restarted!${NC}"
            ;;
        6)
            read -p "Enter service to enable: " service
            systemctl enable "$service"
            echo -e "${GREEN}Service $service enabled on boot!${NC}"
            ;;
        7)
            read -p "Enter service to disable: " service
            systemctl disable "$service"
            echo -e "${GREEN}Service $service disabled on boot!${NC}"
            ;;
        8) 
            return
            ;;
        *)
            echo -e "${RED}Invalid choice!${NC}"
            ;;
    esac
}

# System logs function
view_logs() {
    local choice
    echo -e "${GREEN}=== System Logs ===${NC}"
    echo "1. View system logs"
    echo "2. View auth logs"
    echo "3. View kernel logs"
    echo "4. View boot logs"
    echo "5. Custom log file"
    echo "6. Back to main menu"
    
    read -p "Enter your choice [1-6]: " choice
    
    case $choice in
        1) 
            echo -e "${YELLOW}System logs:${NC}"
            journalctl -n 50 --no-pager
            ;;
        2)
            echo -e "${YELLOW}Auth logs:${NC}"
            if [ -f "/var/log/auth.log" ]; then
                tail -n 50 /var/log/auth.log
            else
                journalctl -n 50 SYSLOG_FACILITY=10 --no-pager
            fi
            ;;
        3)
            echo -e "${YELLOW}Kernel logs:${NC}"
            journalctl -k -n 50 --no-pager
            ;;
        4)
            echo -e "${YELLOW}Boot logs:${NC}"
            journalctl -b -n 50 --no-pager
            ;;
        5)
            read -p "Enter log file path: " logfile
            if [ -f "$logfile" ]; then
                tail -n 50 "$logfile"
            else
                echo -e "${RED}Log file not found!${NC}"
            fi
            ;;
        6) 
            return
            ;;
        *)
            echo -e "${RED}Invalid choice!${NC}"
            ;;
    esac
}

# Backup function
backup_system() {
    local choice
    echo -e "${GREEN}=== Backup System ===${NC}"
    echo "1. Backup home directory"
    echo "2. Backup specific directory"
    echo "3. List backups"
    echo "4. Back to main menu"
    
    read -p "Enter your choice [1-4]: " choice
    
    BACKUP_DIR="/var/backups/admin_script"
    mkdir -p "$BACKUP_DIR"
    
    case $choice in
        1) 
            echo -e "${YELLOW}Backing up home directory...${NC}"
            timestamp=$(date +"%Y%m%d_%H%M%S")
            tar -czf "$BACKUP_DIR/home_backup_$timestamp.tar.gz" /home
            echo -e "${GREEN}Backup created at $BACKUP_DIR/home_backup_$timestamp.tar.gz${NC}"
            ;;
        2)
            read -p "Enter directory to backup: " dir
            if [ -d "$dir" ]; then
                timestamp=$(date +"%Y%m%d_%H%M%S")
                dirname=$(basename "$dir")
                tar -czf "$BACKUP_DIR/${dirname}_backup_$timestamp.tar.gz" "$dir"
                echo -e "${GREEN}Backup created at $BACKUP_DIR/${dirname}_backup_$timestamp.tar.gz${NC}"
            else
                echo -e "${RED}Directory not found!${NC}"
            fi
            ;;
        3)
            echo -e "${YELLOW}Available backups:${NC}"
            ls -lh "$BACKUP_DIR"
            ;;
        4) 
            return
            ;;
        *)
            echo -e "${RED}Invalid choice!${NC}"
            ;;
    esac
}

# Security checks
security_checks() {
    echo -e "${GREEN}=== Security Checks ===${NC}"
    echo -e "${YELLOW}Running security checks...${NC}"
    
    echo -e "\n${BLUE}Checking for failed login attempts:${NC}"
    lastb | head -n 10
    
    echo -e "\n${BLUE}Checking for users with UID 0:${NC}"
    grep ":0:" /etc/passwd
    
    echo -e "\n${BLUE}Checking for passwordless accounts:${NC}"
    cat /etc/shadow | grep '::' || echo "No passwordless accounts found."
    
    echo -e "\n${BLUE}Checking for listening network services:${NC}"
    if command -v netstat &> /dev/null; then
        netstat -tulpn | grep LISTEN
    elif command -v ss &> /dev/null; then
        ss -tulpn | grep LISTEN
    else
        echo -e "${RED}Neither netstat nor ss found!${NC}"
    fi
    
    echo -e "\n${BLUE}Checking for pending system updates:${NC}"
    if command -v apt &> /dev/null; then
        apt list --upgradable 2>/dev/null
    elif command -v dnf &> /dev/null; then
        dnf check-update
    elif command -v yum &> /dev/null; then
        yum check-update
    else
        echo -e "${RED}No supported package manager found!${NC}"
    fi
}

# Main menu
show_menu() {
    echo -e "${GREEN}===== System Administration Tool =====${NC}"
    echo "1. System Information"
    echo "2. User Management"
    echo "3. Network Management"
    echo "4. Service Management"
    echo "5. View System Logs"
    echo "6. Backup System"
    echo "7. Security Checks"
    echo "8. Exit"
    
    read -p "Enter your choice [1-8]: " choice
    
    case $choice in
        1) get_system_info ;;
        2) user_management ;;
        3) network_management ;;
        4) service_management ;;
        5) view_logs ;;
        6) backup_system ;;
        7) security_checks ;;
        8) 
            echo -e "${GREEN}Exiting. Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice!${NC}"
            ;;
    esac
}

# Main program
clear
echo -e "${BLUE}========================================${NC}"
echo -e "${YELLOW}    System Administration Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo

# Check for root privileges for most operations
# if [ "$1" != "--no-root-check" ]; then
#     check_root
# fi

# Main loop
while true; do
    show_menu
    read -p "Press Enter to continue..."
    clear
done