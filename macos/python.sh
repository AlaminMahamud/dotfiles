#!/bin/bash

DEFAULT_PYTHON_VERSION="3.12.7"
PYTHON_VERSION="${1:-$DEFAULT_PYTHON_VERSION}"
CONFIGURE_SHELL=$([ "$2" == "configure" ] && echo true || echo false)

function update_and_upgrade() {
    echo "🔄 Updating and upgrading Homebrew..."
    brew update
    brew upgrade
}

function command_exists() {
    command -v "$1" >/dev/null 2>&1
}

function install_python_deps() {
    echo "📦 Installing dependencies for pyenv..."
    brew install openssl readline sqlite3 xz zlib
}

function configure_pyenv() {
    echo "🔧 Configuring pyenv..."
    {
        echo 'export PYENV_ROOT="$HOME/.pyenv"'
        echo 'export PATH="$PYENV_ROOT/bin:$PATH"'
        echo 'eval "$(pyenv init --path)"'
        echo 'eval "$(pyenv init -)"'
    } >>~/.zshrc
    source ~/.zshrc
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
    fi
}

function install_python_version(){
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
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
            source ~/.zshrc
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
            echo 'export PIPENV_PYTHON="$HOME/.pyenv/shims/python"' >> ~/.zshrc
            source ~/.zshrc
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

update_and_upgrade
install_python_deps
install_pyenv
install_python_version
install_pip
install_pipx
install_pipenv
display_installation_summary
