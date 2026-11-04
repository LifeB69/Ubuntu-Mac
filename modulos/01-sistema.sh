# shellcheck shell=bash
# DESCRICAO: Atualiza o sistema e instala ferramentas básicas

if [[ "$ONLINE" != 1 ]]; then
  pular "Atualizar sistema" "sem internet"
  return 0
fi

# O pacote "firefox" do Ubuntu é só uma ponte para o Snap: atualizá-lo antes de o
# snapd terminar a preparação inicial do primeiro boot FALHA e deixa o dpkg quebrado.
# Como ele vai ser trocado pelo Firefox .deb da Mozilla (módulo 08), fica de fora.
firefox_eh_ponte_snap() { dpkg-query -W -f='${Version}' firefox 2>/dev/null | contem snap; }

atualizar_sistema() {
  local segurar=() rc
  if firefox_eh_ponte_snap; then
    if [[ "$FIREFOX_DEB" == 1 ]]; then
      segurar=(firefox)
    else
      esperar_snapd || echo "Seguindo mesmo assim."
    fi
  fi
  ((${#segurar[@]})) && sudo apt-mark hold "${segurar[@]}"
  tentar 2 sudo apt-get "${APT_OPTS[@]}" full-upgrade
  rc=$?
  ((${#segurar[@]})) && sudo apt-mark unhold "${segurar[@]}"
  if ((rc != 0)); then
    # Nunca deixa o sistema de pacotes "pela metade" para os próximos passos.
    echo "Atualização falhou; consertando o dpkg para os próximos passos..."
    sudo dpkg --configure -a
    sudo apt-get "${APT_OPTS[@]}" -f install
  fi
  return "$rc"
}
passo "Atualizar todos os pacotes (pode demorar)" atualizar_sistema

instalar_lista "ferramentas básicas" \
  curl wget git gnupg ca-certificates dconf-cli xdotool \
  htop ripgrep jq unzip zstd lm-sensors powertop

# Pacotes de idioma que faltarem para o português (o instalador do Ubuntu
# só baixa todos se tiver internet durante a instalação).
idioma_pt() {
  local faltam
  faltam="$(check-language-support -l pt_BR 2>/dev/null)"
  [[ -z "$faltam" ]] && { echo "Nada faltando para pt_BR"; return 0; }
  # shellcheck disable=SC2086  # lista de pacotes separada por espaço
  apt_instalar $faltam
}
passo "Pacotes de idioma português (pt-BR)" idioma_pt

passo "Fuso horário $FUSO_HORARIO" sudo timedatectl set-timezone "$FUSO_HORARIO"

passo "Remover pacotes que sobraram" sudo apt-get "${APT_OPTS[@]}" autoremove --purge
