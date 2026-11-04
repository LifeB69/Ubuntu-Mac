# shellcheck shell=bash
# DESCRICAO: Atualiza o sistema e instala ferramentas básicas

if [[ "$ONLINE" != 1 ]]; then
  pular "Atualizar sistema" "sem internet"
  return 0
fi

passo "Atualizar todos os pacotes (pode demorar)" \
  tentar 2 sudo apt-get "${APT_OPTS[@]}" full-upgrade

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
