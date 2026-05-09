#!/usr/bin/env bash

# =========================================================
# INSTALADOR DEV/IA TOOLING PARA UBUNTU SERVER
# ---------------------------------------------------------
# Este script instala y configura:
#
# - NVM
# - Node.js 22 LTS
# - OpenCode
# - GitHub CLI
# - GitHub Copilot CLI
# - Herramientas auxiliares
#
# Compatible con:
# - Ubuntu Server 20.04+
# - Ubuntu 22.04+
# - Ubuntu 24.04+
#
# Autor: Jhon + ChatGPT
# =========================================================

set -e

# =========================================================
# VARIABLES GLOBALES
# =========================================================

NVM_VERSION="v0.40.3"
NODE_VERSION="22"

# =========================================================
# COLORES PARA TERMINAL
# =========================================================

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
BLUE="\e[34m"
RESET="\e[0m"

# =========================================================
# FUNCIONES AUXILIARES
# =========================================================

print_header() {
    echo -e "${BLUE}"
    echo "================================================="
    echo "$1"
    echo "================================================="
    echo -e "${RESET}"
}

print_success() {
    echo -e "${GREEN}[OK] $1${RESET}"
}

print_warning() {
    echo -e "${YELLOW}[WARN] $1${RESET}"
}

print_error() {
    echo -e "${RED}[ERROR] $1${RESET}"
}

pause_screen() {
    read -p "Presiona ENTER para continuar..."
}

# =========================================================
# ACTUALIZAR SISTEMA
# =========================================================

update_system() {

    print_header "ACTUALIZANDO SISTEMA"

    # Actualiza índices de paquetes
    sudo apt update

    # Actualiza paquetes instalados
    sudo apt upgrade -y

    # Instala herramientas básicas necesarias
    sudo apt install -y \
        curl \
        wget \
        git \
        unzip \
        build-essential \
        ripgrep \
        fd-find \
        ca-certificates \
        software-properties-common

    print_success "Sistema actualizado"
}

# =========================================================
# INSTALAR NVM
# =========================================================

install_nvm() {

    print_header "INSTALANDO NVM"

    # Descarga e instala NVM
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash

    # Exporta variables de entorno para la sesión actual
    export NVM_DIR="$HOME/.nvm"

    # Carga NVM en memoria
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    # Agrega configuración a .bashrc si no existe
    if ! grep -q 'NVM_DIR' ~/.bashrc; then

        cat << 'EOF' >> ~/.bashrc

# =========================================================
# NVM CONFIG
# =========================================================
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

EOF

    fi

    print_success "NVM instalado"
}

# =========================================================
# INSTALAR NODE.JS
# =========================================================

install_node() {

    print_header "INSTALANDO NODE.JS"

    # Verifica si NVM existe
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    # Instala versión LTS de Node.js
    nvm install ${NODE_VERSION}

    # Usa la versión instalada
    nvm use ${NODE_VERSION}

    # Establece como versión por defecto
    nvm alias default ${NODE_VERSION}

    print_success "Node.js instalado"

    echo
    node -v
    npm -v
    echo
}

# =========================================================
# ELIMINAR NODE ANTIGUO DEL SISTEMA
# =========================================================

remove_old_node() {

    print_header "ELIMINANDO NODE GLOBAL ANTIGUO"

    sudo apt remove -y nodejs npm || true
    sudo apt autoremove -y

    print_success "Node antiguo eliminado"
}

# =========================================================
# INSTALAR OPENCODE
# =========================================================

install_opencode() {

    print_header "INSTALANDO OPENCODE"

    # Carga NVM
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    # Instala OpenCode globalmente
    npm install -g opencode-ai

    print_success "OpenCode instalado"

    echo
    opencode --version || true
    echo
}

# =========================================================
# INSTALAR GITHUB CLI
# =========================================================

install_github_cli() {

    print_header "INSTALANDO GITHUB CLI"

    # Descarga llave GPG oficial
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg

    # Ajusta permisos
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg

    # Agrega repositorio oficial
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

    # Actualiza índices
    sudo apt update

    # Instala GitHub CLI
    sudo apt install gh -y

    print_success "GitHub CLI instalado"
}

# =========================================================
# LOGIN GITHUB
# =========================================================

github_login() {

    print_header "LOGIN GITHUB"

    print_warning "Se abrirá autenticación GitHub"

    # Login GitHub
    gh auth login

    # Habilita permisos Copilot
    gh auth refresh -s copilot

    print_success "GitHub autenticado"
}

# =========================================================
# INSTALAR COPILOT CLI
# =========================================================

install_copilot_cli() {

    print_header "INSTALANDO GITHUB COPILOT CLI"

    # Carga NVM
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    # Instala Copilot CLI
    npm install -g @github/copilot

    print_success "Copilot CLI instalado"
}

# =========================================================
# MOSTRAR VERSIONES
# =========================================================

show_versions() {

    print_header "VERSIONES INSTALADAS"

    echo "NODE:"
    node -v || true

    echo
    echo "NPM:"
    npm -v || true

    echo
    echo "GIT:"
    git --version || true

    echo
    echo "GH:"
    gh --version || true

    echo
    echo "OPENCODE:"
    opencode --version || true

    echo
}

# =========================================================
# MENÚ PRINCIPAL
# =========================================================

main_menu() {

    while true; do

        clear

        echo "================================================="
        echo " INSTALADOR DEV + IA TOOLING"
        echo "================================================="
        echo
        echo "1) Actualizar sistema"
        echo "2) Instalar NVM"
        echo "3) Instalar Node.js"
        echo "4) Eliminar Node viejo"
        echo "5) Instalar OpenCode"
        echo "6) Instalar GitHub CLI"
        echo "7) Login GitHub"
        echo "8) Instalar Copilot CLI"
        echo "9) Mostrar versiones"
        echo "10) Instalación completa"
        echo "0) Salir"
        echo

        read -p "Selecciona una opción: " option

        case $option in

            1)
                update_system
                pause_screen
                ;;

            2)
                install_nvm
                pause_screen
                ;;

            3)
                install_node
                pause_screen
                ;;

            4)
                remove_old_node
                pause_screen
                ;;

            5)
                install_opencode
                pause_screen
                ;;

            6)
                install_github_cli
                pause_screen
                ;;

            7)
                github_login
                pause_screen
                ;;

            8)
                install_copilot_cli
                pause_screen
                ;;

            9)
                show_versions
                pause_screen
                ;;

            10)

                update_system
                install_nvm
                remove_old_node
                install_node
                install_opencode
                install_github_cli
                install_copilot_cli
                github_login
                show_versions

                print_success "INSTALACIÓN COMPLETA FINALIZADA"

                pause_screen
                ;;

            0)

                print_warning "Saliendo..."
                exit 0
                ;;

            *)

                print_error "Opción inválida"
                pause_screen
                ;;

        esac

    done
}

# =========================================================
# INICIO SCRIPT
# =========================================================

main_menu
