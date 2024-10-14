#!/bin/bash

ARCH="arch"
UBUNTU="ubuntu"

DEFAULT_PYTHON_VERSION="3.12.7"
PYTHON_VERSION="${1:-$DEFAULT_PYTHON_VERSION}"
CONFIGURE_SHELL=$([ "$2" == "configure" ] && echo true || echo false)

function detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    else
        echo "❌ Unable to detect operating system."
        exit 1
    fi
}

function update_and_upgrade() {
    echo "🔄 Updating and upgrading the system..."
    if [ "$OS" == $UBUNTU ]; then
        sudo apt-get update -y
        sudo apt-get upgrade -y
    elif [ "$OS" == $ARCH ]; then
        sudo pacman -Syu --noconfirm
    else
        echo "❌ Unsupported operating system: $OS"
        exit 1
    fi
}

function command_exists() {
    command -v "$1" >/dev/null 2>&1
}

function install_python_deps() {
    echo "📦 Installing dependencies for pyenv..."
    if [ "$OS" == $UBUNTU ]; then
        sudo apt install -y make build-essential libssl-dev zlib1g-dev \
            libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
            libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev \
            liblzma-dev openssl git
    elif [ "$OS" == $ARCH ]; then
        sudo pacman -S --noconfirm base-devel openssl zlib bzip2 readline sqlite wget curl llvm \
            ncurses xz tk libffi lzma git
    else
        echo "❌ Unsupported operating system: $OS"
        exit 1
    fi
}

function configure_pyenv() {
    echo "🔧 Configuring pyenv..."
    pyenv_query='export PYENV_ROOT="$HOME/.pyenv"'
    python_zsh_conf_query='source $ZSH_FOLDER/python.zsh'
    if ! grep -q "$pyenv_query" ~/.zshrc || ! grep -q "$python_zsh_conf_query" ~/.zshrc; then
        {
            echo 'export PYENV_ROOT="$HOME/.pyenv"'
            echo 'export PATH="$PYENV_ROOT/bin:$PATH"'
            echo 'eval "$(pyenv init --path)"'
            echo 'eval "$(pyenv init -)"'
        } >>~/.zshrc
        source ~/.zshrc
    else
        echo "🔧 pyenv is already configured in ~/.zshrc."
    fi
}

function install_pyenv() {
    if ! command_exists pyenv; then
        echo "📥 Installing pyenv..."
        curl https://pyenv.run | bash

        if [ "$CONFIGURE_SHELL" == true ]; then
            configure_pyenv
        fi

        echo "✅ pyenv installed successfully."
    else
        echo "✅ pyenv is already installed."
        echo "🔧 Re-sourcing ~/.zshrc...(In order to reload pyenv)"
        source ~/.zshrc
    fi
}

function install_python_version() {
    echo "📥 Installing Python $PYTHON_VERSION..."

    if pyenv versions | grep -q "$PYTHON_VERSION"; then
        echo "✅ Python $PYTHON_VERSION is already installed."
    else
        echo "📥 Installing Python $PYTHON_VERSION using pyenv..."
        pyenv install "$PYTHON_VERSION"
        pyenv global "$PYTHON_VERSION"
    fi
}

function install_pip() {
    if ! command_exists pip; then
        echo "📥 Installing pip..."
        curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
        python get-pip.py --user
        rm get-pip.py
    fi
    python -m pip install --upgrade pip
}

function install_pipx() {
    if ! command_exists pipx; then
        echo "📥 Installing pipx..."
        python -m pip install --user pipx
        python -m pipx ensurepath

        if [ "$CONFIGURE_SHELL" == true ]; then
            if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.zshrc; then
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
                source ~/.zshrc
            fi
        fi
    else
        echo "✅ pipx is already installed."
    fi
}

function install_pipenv() {
    if ! command_exists pipenv; then
        echo "📥 Installing pipenv..."
        pipx install pipenv
        if [ "$CONFIGURE_SHELL" == true ]; then
            pipenv_query='export PIPENV_PYTHON="$HOME/.pyenv/shims/python"'
            python_zsh_conf_query='source $ZSH_FOLDER/python.zsh'
            if ! grep -q "$pipenv_query" ~/.zshrc || ! grep -q "$python_zsh_conf_query" ~/.zshrc; then
                echo "$pipenv_query" >> ~/.zshrc
                source ~/.zshrc
            fi
        fi
    else
        echo "✅ pipenv is already installed."
    fi
}

function display_installation_summary() {
    echo "🔍 Installation Summary:"
    echo "🐍 Python Version: $(python --version)"
    echo "📦 pip Version: $(pip --version)"
    echo "📦 pipx Version: $(pipx --version)"
    echo "📦 pipenv Version: $(pipenv --version)"
}

detect_os
update_and_upgrade
install_python_deps
install_pyenv
install_python_version
install_pip
install_pipx
install_pipenv
display_installation_summary