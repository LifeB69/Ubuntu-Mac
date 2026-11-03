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

passo "Fuso horário $FUSO_HORARIO" sudo timedatectl set-timezone "$FUSO_HORARIO"

passo "Remover pacotes que sobraram" sudo apt-get "${APT_OPTS[@]}" autoremove --purge
