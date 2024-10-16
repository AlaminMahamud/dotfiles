#!/bin/bash

ARCH="arch"
UBUNTU="ubuntu"

# Determine the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source other scripts using the determined directory
source "$SCRIPT_DIR/symlinks.sh"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect the operating system
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    else
        echo "❌ Unable to detect operating system."
        exit 1
    fi
}

# Function to update and upgrade the system
update_and_upgrade() {
    echo "🔄 Updating and upgrading the system..."
    case "$OS" in
        $UBUNTU)
            sudo apt-get update -y
            sudo apt-get upgrade -y
            ;;
        $ARCH)
            sudo pacman -Syu --noconfirm
            ;;
        *)
            echo "❌ Unsupported operating system: $OS"
            exit 1
            ;;
    esac
}

# Function to configure sudoers for package managers
configure_sudoers() {
    echo "🔧 Configuring sudoers for package managers..."
    local sudoers_file="/etc/sudoers"

    if command_exists xbps-install; then
        sudo sh -c "echo '$(whoami) ALL=(ALL) NOPASSWD: /usr/bin/xbps-install' >> $sudoers_file"
        echo "✅ Added xbps-install to sudoers."
    fi

    if command_exists pacman; then
        sudo sh -c "echo '$(whoami) ALL=(ALL) NOPASSWD: /usr/bin/pacman' >> $sudoers_file"
        echo "✅ Added pacman to sudoers."
    fi

    if command_exists apt; then
        sudo sh -c "echo '$(whoami) ALL=(ALL) NOPASSWD: /usr/bin/apt, /usr/bin/apt-get' >> $sudoers_file"
        echo "✅ Added apt to sudoers."
    fi
}

# Function to install build-essential
setup_build_essential() {
    echo "🔧 Installing build-essential..."
    case "$OS" in
        $UBUNTU)
            sudo apt install -y build-essential
            ;;
        $ARCH)
            sudo pacman -S --noconfirm base-devel
            ;;
    esac
}

# Function to install curl
setup_curl() {
    if ! command_exists curl; then
        echo "🌐 Installing curl..."
        case "$OS" in
            $UBUNTU)
                sudo apt install -y curl
                ;;
            $ARCH)
                sudo pacman -S --noconfirm curl
                ;;
        esac
    else
        echo "🌐 curl is already installed."
    fi
}

# Function to install git and set up symlinks
setup_git() {
    if ! command_exists git; then
        echo "🔧 Installing git..."
        case "$OS" in
            $UBUNTU)
                sudo apt install -y git
                ;;
            $ARCH)
                sudo pacman -S --noconfirm git
                ;;
        esac
    else
        echo "🔧 git is already installed."
    fi
    echo "🔗 Setting up git symlinks..."
    setup_git_symlink
}

# Function to install zsh and oh-my-zsh, and set up symlinks
setup_zsh() {
    if ! command_exists zsh; then
        echo "🐚 Installing zsh..."
        case "$OS" in
            $UBUNTU)
                sudo apt install -y zsh
                ;;
            $ARCH)
                sudo pacman -S --noconfirm zsh
                ;;
        esac
    else
        echo "🐚 zsh is already installed."
    fi

    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "🐚 Installing oh-my-zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    else
        echo "🐚 oh-my-zsh is already installed."
    fi

    echo "🔗 Setting up zsh symlinks..."
    setup_zsh_symlink
}

# Function to install Python and relevant tools
setup_python() {
    echo "🐍 Installing Python and relevant tools..."
    source "$SCRIPT_DIR/python.sh"
}

# Function to install dependencies for i3lock-color
setup_i3_lock_color() {
    echo "🔧 Installing dependencies for i3lock-color..."
    case "$OS" in
        $UBUNTU)
            sudo apt install -y autoconf automake pkg-config libpam0g-dev libcairo2-dev \
                                libxcb1-dev libxcb-composite0-dev libxcb-xinerama0-dev \
                                libxcb-randr0-dev libev-dev libx11-xcb-dev libxcb-xkb-dev \
                                libxcb-image0-dev libxcb-util0-dev libxcb-xrm-dev \
                                libxcb-cursor-dev libxkbcommon-dev libxkbcommon-x11-dev \
                                libjpeg-dev
            ;;
        $ARCH)
            sudo pacman -S --noconfirm autoconf automake pkg-config pam-devel cairo \
                                xcb-util xcb-util-image xcb-util-keysyms xcb-util-renderutil \
                                xcb-util-wm xcb-util-xrm xcb-util-cursor xcb-util-xinerama \
                                libev xcb-util-xrandr xcb-util-xkb xkbcommon xkbcommon-x11 \
                                libjpeg-turbo
            ;;
    esac

    current_dir=$(pwd)
    echo "🔧 Cloning and installing i3lock-color..."
    git clone https://github.com/Raymo111/i3lock-color.git /tmp/i3lock-color
    cd /tmp/i3lock-color
    ./install-i3lock-color.sh
    echo "✅ i3lock-color installed successfully."
    cd "$current_dir"
}

# Function to install i3 and related tools
setup_i3() {
    echo "🖥️ Installing i3 and related tools..."
    case "$OS" in
        $UBUNTU)
            sudo apt install -y \
                # i3 window manager and status bar
                i3 i3status \

                # Additional UI components
                # bar, launcher, notifications
                polybar rofi dunst \

                # Terminal emulators
                kitty alacritty \

                # Screenshot and compositor
                maim picom \

                # Background and file manager
                feh thunar \

                # Audio and volume control
                alsa alsa-utils volumeicon-alsa \

                # Brightness and Bluetooth control
                brightnessctl bluetoothctl \

                # Network manager
                network-manager-gnome \

                # Clipboard manager
                xclip \

                # Audio server and modules
                pulseaudio pulseaudio-utils pulseaudio-module-bluetooth \

                # Backlight control
                xbacklight \

                # X11 utilities
                x11-utils \

                # Power manager
                xfce4-power-manager \
            ;;
        $ARCH)
            sudo pacman -S --noconfirm \
                # i3 window manager and status bar
                i3-wm i3status i3lock \

                # Additional UI components
                polybar rofi dunst \

                # Terminal emulators
                kitty alacritty \

                # Screenshot and compositor
                maim picom \

                # Background and file manager
                feh thunar \

                # Audio and volume control
                alsa-utils volumeicon \

                # Brightness and Bluetooth control
                brightnessctl bluez-utils \

                # Network manager
                network-manager-applet \

                # Clipboard manager
                xclip \

                # Audio server and modules
                pulseaudio pulseaudio-alsa pulseaudio-bluetooth \

                # Backlight control
                xorg-xbacklight \

                # Xorg utilities
                xorg-server xorg-xinit xorg-xauth xorg-xprop \

                # Power manager
                xfce4-power-manager                          \

                # Additional utilities
                jq
            ;;
    esac

    echo "🔗 Setting up i3 symlinks..."
    setup_i3_lock_color
    setup_i3_symlink
}

# Function to ensure paru is installed
setup_paru() {
    if ! command -v paru &> /dev/null; then
        echo "🌐 Installing paru..."
        sudo pacman -S --needed base-devel
        git clone https://aur.archlinux.org/paru.git /tmp/paru
        cd /tmp/paru
        makepkg -si
        cd -
        rm -rf /tmp/paru
        echo "✅ paru installed."
    else
        echo "✅ paru is already installed."
    fi
}

# Function to install ttf-maple using paru
install_ttf_maple() {
    echo "🌐 Installing ttf-maple..."
    paru -S --noconfirm ttf-maple
    echo "✅ ttf-maple installed."
}

# Function to install fonts
setup_fonts() {
    declare -a fonts=(
        FiraCode
        FiraMono
        Hack
        JetBrainsMono
        Iosevka
    )

    # install maple fonts
    echo "🔧 Installing Maple fonts..."
    case "$OS" in
        $UBUNTU) echo "❌ Maple fonts are not available for Ubuntu." ;;
        $ARCH) install_ttf_maple ;;
    esac

    fonts_dir="${HOME}/.local/share/fonts"
    mkdir -p "$fonts_dir"

    echo "🔗 Setting up fonts symlinks..."
    cp -r "$SCRIPT_DIR/.fonts/"* "$fonts_dir"

    echo "🔗 Downloading Nerd Fonts..."
    version='3.2.1'

    for font in "${fonts[@]}"; do
        if fc-list | grep -qi "$font"; then
            echo "Font $font already exists, skipping download."
        else
            zip_file="${font}.zip"
            download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/${zip_file}"
            echo "Downloading $download_url"
            wget "$download_url"
            unzip "$zip_file" -d "$fonts_dir"
            rm "$zip_file"
            echo "Font $font installed successfully."
        fi
    done

    find "$fonts_dir" -name '*Windows Compatible*' -delete

    echo "🔗 Updating font cache..."
    sudo fc-cache -f -v
}


# Function to change the default shell to zsh
change_default_shell_to_zsh() {
    echo "🔄 Changing the default shell to zsh..."
    sudo chsh -s "$(which zsh)" "$USER"
}


# Main script execution
echo "🚀 Starting system setup..."

detect_os
update_and_upgrade
configure_sudoers
setup_build_essential
setup_curl
setup_git
setup_zsh
setup_python
setup_i3
setup_fonts
change_default_shell_to_zsh

echo "✅ System setup completed successfully."
