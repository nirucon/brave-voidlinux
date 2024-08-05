#!/bin/bash

# Script to install/update Brave browser on Void Linux by Nicklas Rudolfsson

# Colors for eye-candy
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to print status messages
print_status() {
    echo -e "${BLUE}==>${NC} $1"
}

# Function to print success messages
print_success() {
    echo -e "${GREEN}==> $1${NC}"
}

# Function to print error messages
print_error() {
    echo -e "${RED}==> Error: $1${NC}"
}

# Function to check the last command status and exit if it failed
check_status() {
    if [ $? -ne 0 ]; then
        print_error "$1"
        exit 1
    fi
}

# Function to clone the void-packages repository if not already cloned
clone_void_packages() {
    if [ ! -d "void-packages" ]; then
        print_status "Cloning void-packages repository..."
        git clone https://github.com/void-linux/void-packages
        check_status "Failed to clone void-packages repository."
    else
        print_status "void-packages repository already exists. Skipping clone."
    fi
}

# Function to run binary-bootstrap
run_binary_bootstrap() {
    print_status "Running binary-bootstrap..."
    cd void-packages
    ./xbps-src binary-bootstrap
    check_status "Failed to run binary-bootstrap."
    cd ..
}

# Function to clone or update brave-bin repository
setup_brave_bin() {
    if [ ! -d "void-packages/srcpkgs/brave-bin" ]; then
        print_status "Cloning brave-bin repository..."
        git clone https://github.com/soanvig/brave-bin void-packages/srcpkgs/brave-bin
        check_status "Failed to clone brave-bin repository."
    else
        print_status "Updating brave-bin repository..."
        git -C void-packages/srcpkgs/brave-bin pull
        check_status "Failed to update brave-bin repository."
    fi
}

# Function to build and install brave-bin
install_brave_bin() {
    print_status "Building brave-bin package..."
    cd void-packages
    ./xbps-src pkg brave-bin
    check_status "Failed to build brave-bin package."
    
    print_status "Installing brave-bin package..."
    sudo xbps-install --repository hostdir/binpkgs brave-bin
    check_status "Failed to install brave-bin package."
    cd ..
}

# Function to check if Brave Browser is installed
check_brave_installed() {
    if command -v brave-browser >/dev/null 2>&1; then
        print_status "Brave Browser is already installed."
        read -p "Do you want to re-install/update to the latest version? (Yes/No/Quit) [Yes]: " response
        response=${response:-Yes}
        response=$(echo "$response" | tr '[:upper:]' '[:lower:]')
        case $response in
            yes|y|'')
                print_status "Proceeding with re-installation/update..."
                install_brave_bin
                ;;
            no|n)
                print_status "No update performed. Exiting."
                exit 0
                ;;
            quit|q)
                print_status "Exiting."
                exit 0
                ;;
            *)
                print_error "Invalid response. Exiting."
                exit 1
                ;;
        esac
    else
        print_status "Brave Browser is not installed. Proceeding with installation..."
        install_brave_bin
    fi
}

# Main function to setup, install, and update Brave Browser
main() {
    clone_void_packages
    run_binary_bootstrap
    setup_brave_bin
    check_brave_installed
    print_success "Brave Browser installation and update completed successfully."
}

# Execute the main function
main
