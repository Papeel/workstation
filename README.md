# workstation

Mi entorno de trabajo reproducible: **Ghostty + tmux + Neovim (LazyVim) + zsh (Oh My Zsh + powerlevel10k)**.

## Instalación en un ordenador nuevo (Ubuntu/Debian)

```bash
git clone https://github.com/Papeel/workstation.git ~/workstation
cd ~/workstation
./install.sh
```

El script es idempotente (se puede ejecutar varias veces) y:

1. Instala paquetes base: `git`, `zsh`, `tmux`, `ripgrep`, `fd`, `fzf`, `xclip`, `build-essential`…
2. Instala fuentes: **Fira Code** + **Symbols Nerd Font** (iconos).
3. Instala **Ghostty**, **Neovim** (última estable en `~/.local/bin/nvim`), **lazygit** y **Node** (vía nvm).
4. Instala **Oh My Zsh** + **powerlevel10k** y pone zsh como shell por defecto.
5. Crea symlinks de las configs del repo a su sitio (lo que hubiera antes se mueve a `~/.dotfiles-backup/<fecha>/`).
6. Instala los plugins de tmux (TPM) y de Neovim (fijados por `lazy-lock.json`).

Solo enlazar configs (sin instalar nada): `./install.sh --link`

## Estructura

| Repo                | Se enlaza en                   |
| ------------------- | ------------------------------ |
| `ghostty/`          | `~/.config/ghostty`            |
| `tmux/tmux.conf`    | `~/.config/tmux/tmux.conf`     |
| `nvim/`             | `~/.config/nvim`               |
| `zsh/.zshrc`        | `~/.zshrc`                     |
| `zsh/.p10k.zsh`     | `~/.p10k.zsh`                  |

Como son symlinks, **cualquier cambio que hagas en tu config ya está dentro del repo**. Para sincronizar entre ordenadores:

```bash
cd ~/workstation
git add -A && git commit -m "..." && git push   # en el ordenador donde cambiaste algo
git pull                                         # en los demás
```

Tras un `git pull`: tmux → `Ctrl+a r` para recargar; Neovim → `:Lazy restore` si cambió `lazy-lock.json`.

Lo específico de una sola máquina (PATHs, alias, tokens…) va en `~/.zshrc.local`, que no se versiona.

## Atajos principales

**tmux** (prefijo `Ctrl+a`)

| Atajo                    | Acción                                  |
| ------------------------ | --------------------------------------- |
| `Alt+v` / `Alt+d`        | Split vertical / horizontal             |
| `Alt+h/j/k/l`            | Moverse entre paneles                   |
| `Ctrl+h/j/k/l`           | Moverse entre paneles de tmux **y** nvim |
| `Ctrl+Shift+h/j/k/l`     | Redimensionar panel                     |
| `prefijo` + `\|` / `-`   | Split vertical / horizontal             |
| `prefijo` + `c`          | Nueva ventana                           |
| `prefijo` + `r`          | Recargar config                         |
| `prefijo` + `I`          | Instalar plugins (TPM)                  |

Las sesiones se guardan y restauran automáticamente (tmux-resurrect + continuum). Ghostty abre siempre la sesión `main`.

**Neovim**: LazyVim con tema tokyonight adaptado a la paleta de Ghostty, snippets propios en `nvim/lua/snippets/`, `Alt+b` para cambiar de rama git.
