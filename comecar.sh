#!/usr/bin/env bash
# Comando único para começar (rode no Xubuntu recém-instalado, com internet):
#
#   Repositório público:
#     wget -qO- https://raw.githubusercontent.com/LifeB69/Ubuntu-Mac/main/comecar.sh | bash
#
#   Repositório privado (baixe o ZIP pelo navegador e depois):
#     cd ~/Downloads && unzip -oq Ubuntu-Mac-*.zip && bash Ubuntu-Mac-*/comecar.sh
#
# Coloca o projeto em ~/Ubuntu-Mac e roda o instalar.sh.
# Depois da primeira vez, basta digitar:  ubuntu-mac
# (aceita as mesmas opções do instalar.sh, ex.: ubuntu-mac --somente 05, ubuntu-mac --verificar)

# Tudo fica dentro de main(): com "wget | bash", o bash lê o script pelo mesmo
# cano que os comandos usariam como entrada. Assim ele lê o arquivo inteiro
# antes de executar qualquer coisa, e nada "engole" o resto do script.
main() {
  set -u
  local REPO_URL="https://github.com/LifeB69/Ubuntu-Mac"
  local RAMO="${RAMO:-main}"
  local DEST="$HOME/Ubuntu-Mac"
  # Repositório privado: o git falha na hora em vez de ficar pedindo usuário e senha.
  export GIT_TERMINAL_PROMPT=0

  # Rodando de uma pasta já baixada (ZIP do GitHub, pendrive) ou pelo comando ubuntu-mac?
  local AQUI=""
  if [[ -f "${BASH_SOURCE[0]:-}" ]]; then
    AQUI="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
    [[ -f "$AQUI/instalar.sh" ]] || AQUI=""
  fi

  if [[ -z "$AQUI" ]] && ! command -v git >/dev/null; then
    echo "Instalando o git (pede sua senha)..."
    # O "update" pode reclamar da fonte do pendrive (cdrom); não importa aqui.
    sudo apt-get update -qq </dev/null || true
    sudo apt-get install -y -qq git </dev/null ||
      echo "Não consegui instalar o git; vou baixar como arquivo compactado."
  fi

  if [[ -n "$AQUI" && "$AQUI" == "$DEST" ]]; then
    # Comando ubuntu-mac: tenta atualizar a partir do GitHub.
    if [[ -d "$DEST/.git" ]]; then
      git -C "$DEST" pull -q --ff-only </dev/null 2>/dev/null &&
        echo "== Scripts atualizados do GitHub ==" ||
        echo "== Sem atualização do GitHub; usando a versão local =="
    fi
  elif [[ -n "$AQUI" ]]; then
    echo "== Copiando $AQUI para $DEST =="
    mkdir -p "$DEST" && cp -a "$AQUI/." "$DEST/" || { echo "Falha ao copiar para $DEST"; return 1; }
  elif [[ -d "$DEST/.git" ]]; then
    git -C "$DEST" pull -q --ff-only </dev/null ||
      echo "Aviso: não consegui atualizar; usando a versão que já está aqui."
  elif [[ ! -e "$DEST" ]] && command -v git >/dev/null &&
       git clone -q -b "$RAMO" "$REPO_URL" "$DEST" </dev/null 2>/dev/null; then
    echo "== Projeto baixado em $DEST =="
  else
    local tmp; tmp="$(mktemp -d)"
    if wget --timeout=30 --tries=3 -qO- "$REPO_URL/archive/refs/heads/$RAMO.tar.gz" |
       tar xz --strip-components=1 -C "$tmp" 2>/dev/null && [[ -f "$tmp/instalar.sh" ]]; then
      mkdir -p "$DEST" && cp -a "$tmp/." "$DEST/"
      echo "== Projeto baixado em $DEST =="
    elif [[ -f "$DEST/instalar.sh" ]]; then
      echo "Aviso: não consegui baixar do GitHub; usando a cópia que já está em $DEST."
    else
      echo
      echo "Não consegui baixar o projeto do GitHub."
      echo "Se o repositório for PRIVADO: entre no GitHub pelo Firefox, baixe o ZIP"
      echo "(Code → Download ZIP) e rode:"
      echo "  cd ~/Downloads && unzip -oq Ubuntu-Mac-*.zip && bash Ubuntu-Mac-*/comecar.sh"
      rm -rf "$tmp"
      return 1
    fi
    rm -rf "$tmp"
  fi

  chmod +x "$DEST/instalar.sh" "$DEST/comecar.sh" "$DEST/verificar.sh" 2>/dev/null

  # Comando curto "ubuntu-mac" para as próximas vezes.
  if [[ "$(readlink -f /usr/local/bin/ubuntu-mac 2>/dev/null)" != "$DEST/comecar.sh" ]]; then
    sudo ln -sfn "$DEST/comecar.sh" /usr/local/bin/ubuntu-mac </dev/null ||
      echo "Aviso: não consegui criar o comando ubuntu-mac (use $DEST/comecar.sh)."
  fi

  # Devolve o teclado ao instalar.sh (no "wget | bash" a entrada era o cano).
  if [[ -t 0 ]] || ! { true </dev/tty; } 2>/dev/null; then
    exec "$DEST/instalar.sh" "$@"
  else
    exec "$DEST/instalar.sh" "$@" </dev/tty
  fi
}

main "$@"
