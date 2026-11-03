#!/usr/bin/env bash
# Comando único para começar (rode no Xubuntu recém-instalado, com internet):
#
#   wget -qO- https://raw.githubusercontent.com/LifeB69/Ubuntu-Mac/main/comecar.sh | bash
#
# Baixa este repositório para ~/Ubuntu-Mac (com git, para o Claude local poder
# salvar melhorias depois) e roda o instalar.sh.

set -u
REPO_URL="https://github.com/LifeB69/Ubuntu-Mac"
RAMO="${RAMO:-main}"
DEST="$HOME/Ubuntu-Mac"

echo "== Ubuntu-Mac: baixando os scripts para $DEST =="

if ! command -v git >/dev/null; then
  echo "Instalando git (pede sua senha)..."
  sudo apt-get update -qq && sudo apt-get install -y -qq git ||
    echo "Não consegui instalar o git; vou baixar como arquivo compactado."
fi

if [[ -d "$DEST/.git" ]]; then
  git -C "$DEST" pull --ff-only || echo "Aviso: não consegui atualizar; usando a versão que já está aqui."
elif command -v git >/dev/null && git clone -b "$RAMO" "$REPO_URL" "$DEST"; then
  :
else
  mkdir -p "$DEST" &&
    wget -qO- "$REPO_URL/archive/refs/heads/$RAMO.tar.gz" | tar xz --strip-components=1 -C "$DEST" || {
      echo "Falha ao baixar o repositório. Confira a internet (e se o repositório é público)."
      exit 1
    }
fi

chmod +x "$DEST/instalar.sh"
exec "$DEST/instalar.sh" "$@" </dev/tty
