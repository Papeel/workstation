#!/usr/bin/env bash
# Prepara una workstation (Ubuntu/Debian) con Ghostty + tmux + Neovim (LazyVim) + zsh.
#
# Uso:
#   ./install.sh            # instala todo y enlaza las configs
#   ./install.sh --link     # solo crea los symlinks de configuración
#
# Es idempotente: puedes ejecutarlo tantas veces como quieras.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
NVIM_DIR="$HOME/.local/bin/nvim"
NODE_VERSION="22"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m ✓\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m !\033[0m %s\n' "$*"; }
has()  { command -v "$1" >/dev/null 2>&1; }

# ── Symlinks ───────────────────────────────────────────────────────────────
# Enlaza $1 (dentro del repo) en $2. Si ya existe algo que no es nuestro
# symlink, lo mueve a ~/.dotfiles-backup/<fecha>/.
link() {
  local src="$DOTFILES/$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    ok "$dst ya enlazado"
    return
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mkdir -p "$BACKUP_DIR"
    mv "$dst" "$BACKUP_DIR/"
    warn "$dst movido a $BACKUP_DIR/"
  fi
  ln -s "$src" "$dst"
  ok "$dst -> $src"
}

link_all() {
  info "Enlazando configuraciones"
  link ghostty          "$HOME/.config/ghostty"
  link tmux/tmux.conf   "$HOME/.config/tmux/tmux.conf"
  link nvim             "$HOME/.config/nvim"
  link zsh/.zshrc       "$HOME/.zshrc"
  link zsh/.p10k.zsh    "$HOME/.p10k.zsh"
}

# ── Paquetes ───────────────────────────────────────────────────────────────
install_apt() {
  info "Paquetes del sistema (apt)"
  sudo apt-get update
  sudo apt-get install -y \
    git curl wget unzip tar build-essential \
    zsh tmux \
    ripgrep fd-find fzf xclip wl-clipboard \
    python3 python3-venv python3-pip \
    fontconfig
  # Ubuntu llama al binario 'fdfind'; LazyVim busca 'fd'
  mkdir -p "$HOME/.local/bin"
  if has fdfind && ! has fd; then ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"; fi
}

install_ghostty() {
  if has ghostty; then ok "Ghostty ya instalado"; return; fi
  info "Instalando Ghostty"
  # Paquete .deb comunitario para Ubuntu: https://github.com/mkasberg/ghostty-ubuntu
  if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"; then
    ok "Ghostty instalado"
  elif has snap; then
    sudo snap install ghostty --classic
  else
    warn "No se pudo instalar Ghostty automáticamente: https://ghostty.org/download"
  fi
}

install_neovim() {
  if [ -x "$NVIM_DIR/bin/nvim" ]; then ok "Neovim ya instalado ($("$NVIM_DIR/bin/nvim" --version | head -1))"; return; fi
  info "Instalando Neovim (última release estable) en $NVIM_DIR"
  local arch tmp
  case "$(uname -m)" in
    x86_64) arch="x86_64" ;;
    aarch64|arm64) arch="arm64" ;;
    *) warn "Arquitectura no soportada: $(uname -m)"; return ;;
  esac
  tmp="$(mktemp -d)"
  curl -fL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${arch}.tar.gz" -o "$tmp/nvim.tar.gz"
  tar -xzf "$tmp/nvim.tar.gz" -C "$tmp"
  rm -rf "$NVIM_DIR"
  mkdir -p "$(dirname "$NVIM_DIR")"
  mv "$tmp/nvim-linux-${arch}" "$NVIM_DIR"
  rm -rf "$tmp"
  ok "Neovim instalado"
}

install_lazygit() {
  if has lazygit; then ok "lazygit ya instalado"; return; fi
  info "Instalando lazygit"
  local version arch tmp
  case "$(uname -m)" in
    x86_64) arch="x86_64" ;;
    aarch64|arm64) arch="arm64" ;;
    *) warn "Arquitectura no soportada para lazygit"; return ;;
  esac
  version="$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep -Po '"tag_name": *"v\K[^"]*')"
  tmp="$(mktemp -d)"
  curl -fL "https://github.com/jesseduffield/lazygit/releases/download/v${version}/lazygit_${version}_Linux_${arch}.tar.gz" -o "$tmp/lazygit.tar.gz"
  tar -xzf "$tmp/lazygit.tar.gz" -C "$tmp" lazygit
  install -m 755 "$tmp/lazygit" "$HOME/.local/bin/lazygit"
  rm -rf "$tmp"
  ok "lazygit instalado"
}

install_node() {
  export NVM_DIR="$HOME/.nvm"
  if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    info "Instalando nvm"
    PROFILE=/dev/null bash -c "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh)"
  fi
  # shellcheck disable=SC1091
  set +u; . "$NVM_DIR/nvm.sh"
  if ! nvm ls "$NODE_VERSION" >/dev/null 2>&1; then
    info "Instalando Node $NODE_VERSION (necesario para LSPs de LazyVim)"
    nvm install "$NODE_VERSION"
    nvm alias default "$NODE_VERSION"
  fi
  set -u
  ok "Node $(node --version)"
}

install_fonts() {
  local font_dir="$HOME/.local/share/fonts"
  mkdir -p "$font_dir"
  if ! fc-list | grep -qi "Fira Code"; then
    info "Instalando Fira Code"
    local tmp; tmp="$(mktemp -d)"
    curl -fL "https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip" -o "$tmp/fira.zip"
    unzip -qo "$tmp/fira.zip" 'ttf/*' -d "$tmp"
    cp "$tmp"/ttf/*.ttf "$font_dir/"
    rm -rf "$tmp"
  else
    ok "Fira Code ya instalada"
  fi
  # Nerd Font para los iconos de LazyVim, tmux y powerlevel10k (Ghostty hace fallback)
  if ! fc-list | grep -qi "Nerd Font"; then
    info "Instalando Symbols Nerd Font"
    local tmp; tmp="$(mktemp -d)"
    curl -fL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/NerdFontsSymbolsOnly.zip" -o "$tmp/nf.zip"
    unzip -qo "$tmp/nf.zip" '*.ttf' -d "$font_dir"
    rm -rf "$tmp"
  else
    ok "Nerd Font ya instalada"
  fi
  fc-cache -f >/dev/null
}

install_zsh() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Instalando Oh My Zsh"
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  else
    ok "Oh My Zsh ya instalado"
  fi
  local p10k="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  if [ ! -d "$p10k" ]; then
    info "Instalando powerlevel10k"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k"
  else
    ok "powerlevel10k ya instalado"
  fi
  if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]; then
    info "Cambiando la shell por defecto a zsh"
    chsh -s "$(command -v zsh)" || warn "No se pudo cambiar la shell; ejecuta: chsh -s $(command -v zsh)"
  fi
}

install_tmux_plugins() {
  local tpm="$HOME/.tmux/plugins/tpm"
  if [ ! -d "$tpm" ]; then
    info "Instalando TPM"
    git clone --depth=1 https://github.com/tmux-plugins/tpm "$tpm"
  fi
  info "Instalando plugins de tmux"
  "$tpm/bin/install_plugins" >/dev/null || warn "Abre tmux y pulsa Ctrl+a I para instalar plugins"
  ok "Plugins de tmux listos"
}

install_nvim_plugins() {
  info "Sincronizando plugins de Neovim (según lazy-lock.json)"
  "$NVIM_DIR/bin/nvim" --headless "+Lazy! restore" +qa 2>/dev/null \
    && ok "Plugins de Neovim instalados" \
    || warn "Abre nvim una vez para terminar la instalación de plugins"
}

main() {
  if [ "${1:-}" = "--link" ]; then link_all; exit 0; fi

  if ! has apt-get; then
    warn "Este script está pensado para Ubuntu/Debian. Usa './install.sh --link' para enlazar solo las configs."
    exit 1
  fi

  install_apt
  install_fonts
  install_ghostty
  install_neovim
  install_lazygit
  install_node
  install_zsh
  link_all
  install_tmux_plugins
  install_nvim_plugins

  echo
  ok "Workstation lista. Cierra sesión (o abre Ghostty) para empezar a usarla."
  [ -d "$BACKUP_DIR" ] && warn "Tus configs anteriores están en $BACKUP_DIR"
  exit 0
}

main "$@"
