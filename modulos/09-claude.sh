# shellcheck shell=bash
# DESCRICAO: Claude Desktop (app oficial) e Claude Code (terminal)

if [[ "$ONLINE" != 1 ]]; then pular "Claude" "sem internet"; return 0; fi

# ---------- Claude Desktop (beta oficial para Linux) ----------
# Passos da documentação oficial: https://code.claude.com/docs/en/desktop-linux
if [[ "$INSTALAR_CLAUDE_DESKTOP" == 1 ]]; then
  adicionar_repo_claude() {
    local chave=/usr/share/keyrings/claude-desktop-archive-keyring.asc
    tentar 3 sudo wget --timeout=30 --tries=3 -qO "$chave" https://downloads.claude.ai/claude-desktop/key.asc || return 1
    if ! gpg --show-keys "$chave" 2>/dev/null | grep -q 31DDDE24DDFAB679F42D7BD2BAA929FF1A7ECACE; then
      echo "Impressão digital da chave da Anthropic não confere — abortando."
      sudo rm -f "$chave"
      return 1
    fi
    echo "deb [arch=amd64,arm64 signed-by=$chave] https://downloads.claude.ai/claude-desktop/apt/stable stable main" |
      sudo tee /etc/apt/sources.list.d/claude-desktop.list >/dev/null
    apt_atualizar
  }
  instalar_claude_desktop() {
    # Sem "recommends" o apt não instala o QEMU do Cowork (pesado para 4 GB).
    local extra=(--no-install-recommends)
    [[ "$INSTALAR_COWORK" == 1 ]] && extra=()
    tentar 2 sudo apt-get "${APT_OPTS[@]}" install "${extra[@]}" claude-desktop gnome-keyring
  }
  if pacote_instalado claude-desktop; then
    pular "Claude Desktop" "já instalado (atualiza junto com o sistema)"
  else
    passo "Adicionar repositório oficial da Anthropic" adicionar_repo_claude &&
      passo "Instalar Claude Desktop" instalar_claude_desktop
  fi
  if [[ "$INSTALAR_COWORK" == 1 ]]; then
    passo "Cowork: adicionar usuário ao grupo kvm" sudo usermod -aG kvm "$USER"
  fi
else
  pular "Claude Desktop" "desligado no config.conf"
fi

# ---------- Claude Code (CLI) ----------
# Instalador oficial: instala em ~/.local/bin/claude e se atualiza sozinho.
if [[ "$INSTALAR_CLAUDE_CODE" == 1 ]]; then
  if [[ -x "$HOME/.local/bin/claude" ]] || command -v claude >/dev/null; then
    pular "Claude Code" "já instalado"
  else
    instalar_claude_code() {
      local tmp; tmp="$(mktemp)"
      tentar 3 wget -qO "$tmp" https://claude.ai/install.sh || return 1
      bash "$tmp"; local rc=$?
      rm -f "$tmp"
      return "$rc"
    }
    passo "Instalar Claude Code (comando: claude)" instalar_claude_code
  fi
  # Garante ~/.local/bin no PATH (o Ubuntu só adiciona se a pasta existir no login).
  adicionar_path() {
    cat >>"$HOME/.bashrc" <<'BASHRC'

# ubuntu-mac: local/bin
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac
BASHRC
  }
  if ! grep -q 'ubuntu-mac: local/bin' "$HOME/.bashrc" 2>/dev/null; then
    passo "Adicionar ~/.local/bin ao PATH" adicionar_path
  fi
else
  pular "Claude Code" "desligado no config.conf"
fi
