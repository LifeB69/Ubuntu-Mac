#!/usr/bin/env bash
# Ubuntu-Mac — configura o Xubuntu 26.04 num MacBook Air 11" (Early 2015).
#
# Uso:
#   ./instalar.sh                    roda todos os módulos
#   ./instalar.sh --somente 06 09    roda só os módulos indicados (pelo número)
#   ./instalar.sh --pular 10         roda tudo, menos os módulos indicados
#   ./instalar.sh --listar           mostra os módulos
#   ./instalar.sh --verificar        confere se está tudo funcionando (depois de reiniciar)
#
# Não para quando algo falha: registra e continua. No final mostra um resumo.
# Logs ficam em logs/<data-hora>/ (e o atalho logs/ultimo aponta para o mais recente).

set -uo pipefail

REPO="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
export REPO
# shellcheck source=lib/comum.sh
source "$REPO/lib/comum.sh"

SOMENTE=() PULAR=()
while (($#)); do
  case "$1" in
    --somente) shift; while (($#)) && [[ "$1" != --* ]]; do SOMENTE+=("$1"); shift; done ;;
    --pular) shift; while (($#)) && [[ "$1" != --* ]]; do PULAR+=("$1"); shift; done ;;
    --verificar) exec bash "$REPO/verificar.sh" ;;
    --listar)
      for m in "$REPO"/modulos/[0-9]*.sh; do
        printf '  %s  %s\n' "$(basename "$m" .sh)" "$(sed -n 's/^# DESCRICAO: //p' "$m")"
      done
      exit 0 ;;
    -h|--help) sed -n '2,13p' "$0"; exit 0 ;;
    *) echo "Opção desconhecida: $1 (use --help)"; exit 2 ;;
  esac
done

# Aceita "5" ou "05" para o módulo 05.
normalizar() { local x; for x in "$@"; do [[ "$x" =~ ^[0-9]+$ ]] && printf '%02d ' "$((10#$x))" || printf '%s ' "$x"; done; }
read -r -a SOMENTE <<<"$(normalizar "${SOMENTE[@]}")"
read -r -a PULAR <<<"$(normalizar "${PULAR[@]}")"
export UBUNTU_MAC_SOMENTE="${SOMENTE[*]}"

if [[ $EUID -eq 0 ]]; then
  echo "Rode como seu usuário normal (sem sudo). O script pede a senha quando precisar."
  exit 1
fi

# Impede que o notebook suspenda ou bloqueie a tela no meio da instalação.
if [[ -z "${UBUNTU_MAC_INIBIDO:-}" ]] && command -v systemd-inhibit >/dev/null &&
   systemd-inhibit --what=idle:sleep --who=ubuntu-mac --why=teste true 2>/dev/null; then
  export UBUNTU_MAC_INIBIDO=1
  exec systemd-inhibit --what=idle:sleep --who=ubuntu-mac --why="Instalando Ubuntu-Mac" "$0" "$@"
fi

# Uma execução por vez.
mkdir -p "$REPO/logs"
exec 9>"$REPO/logs/.trava"
if ! flock -n 9; then
  echo "O Ubuntu-Mac já está rodando em outro terminal. Espere ele terminar."
  exit 1
fi

CARIMBO="$(date +%Y-%m-%d_%H%M%S)"
export LOG_DIR="$REPO/logs/$CARIMBO"
export LOG_GERAL="$LOG_DIR/instalacao.log"
export RESUMO="$LOG_DIR/resumo.tsv"
export FALHAS="$LOG_DIR/falhas.txt"
mkdir -p "$LOG_DIR"
: >"$RESUMO"; : >"$FALHAS"
ln -sfn "$CARIMBO" "$REPO/logs/ultimo"

carregar_config

echo "${C_B}=== Ubuntu-Mac: configurando o MacBook Air ===${C_0}"
echo "Logs: $LOG_DIR"
echo
echo "Vou precisar da sua senha uma vez (sudo)."
if ! sudo -v; then
  echo "Sem sudo não dá para continuar."
  exit 1
fi
# Mantém o sudo ativo enquanto o script roda.
( while kill -0 $$ 2>/dev/null; do sudo -n -v 2>/dev/null; sleep 50; done ) &
SUDO_PID=$!
trap 'kill $SUDO_PID 2>/dev/null' EXIT

{
  echo "Ubuntu-Mac — início: $(date)"
  echo "Usuário: $USER | Máquina: $(cat /sys/class/dmi/id/product_name 2>/dev/null) | Kernel: $(uname -r)"
  grep PRETTY_NAME /etc/os-release
  echo "Config:"; grep -vE '^\s*(#|$)' "$REPO/config.conf" 2>/dev/null
  echo "Git: $(git -C "$REPO" rev-parse --short HEAD 2>/dev/null || echo 'sem git')"
} >>"$LOG_GERAL"

# Carregador e espaço em disco (a instalação demora e baixa bastante coisa).
na_tomada() { local f; for f in /sys/class/power_supply/*/online; do [[ -f "$f" && "$(cat "$f")" == 1 ]] && return 0; done; return 1; }
if ls /sys/class/power_supply/*/online >/dev/null 2>&1 && ! na_tomada; then
  aviso "O notebook está na bateria. Conecte o carregador: a instalação pode levar mais de meia hora."
fi
livre_gb=$(df -BG --output=avail / | tail -1 | tr -dc 0-9)
if [[ -n "$livre_gb" ]] && ((livre_gb < 6)); then
  aviso "Pouco espaço em disco (${livre_gb} GB livres). Algumas instalações podem falhar."
fi

if tem_internet; then
  export ONLINE=1
  log "Internet: conectada"
else
  export ONLINE=0
  aviso "Sem internet. Vou fazer o que der offline (incluindo o driver de Wi-Fi do pendrive). Depois conecte e rode de novo."
fi

# Garante os repositórios main, restricted (driver Wi-Fi), universe e multiverse.
garantir_componentes() {
  local f=/etc/apt/sources.list.d/ubuntu.sources
  if [[ -f "$f" ]]; then
    sudo sed -i 's/^Components:.*/Components: main restricted universe multiverse/' "$f"
  elif command -v add-apt-repository >/dev/null; then
    sudo add-apt-repository -y -n universe && sudo add-apt-repository -y -n restricted &&
      sudo add-apt-repository -y -n multiverse
  else
    return 1
  fi
}
MODULO_ATUAL=00-preparo passo "Ativar repositórios universe/restricted/multiverse" garantir_componentes

# A imagem do Xubuntu vem com uma fonte de pacotes "file:/cdrom" (o pendrive).
# Sem o pendrive conectado ela faz o "apt update" falhar, então é desativada.
# (O driver de Wi-Fi offline lê os .deb do pendrive direto, sem precisar dela.)
desativar_cdrom() {
  local f=/etc/apt/sources.list.d/cdrom.sources
  if [[ -f "$f" ]] && ! grep -q '^Enabled: no' "$f"; then
    sudo sed -i '1i Enabled: no' "$f"
  fi
  if [[ -f /etc/apt/sources.list ]]; then
    sudo sed -i 's|^deb cdrom:|# deb cdrom:|' /etc/apt/sources.list
  fi
  return 0
}
MODULO_ATUAL=00-preparo passo "Desativar a fonte de pacotes do pendrive (cdrom)" desativar_cdrom

# Se uma instalação anterior foi interrompida (bateria, queda de energia...),
# termina de configurar o que ficou pela metade antes de seguir.
consertar_dpkg() {
  esperar_dpkg && sudo dpkg --configure -a && sudo apt-get "${APT_OPTS[@]}" -f install
}
MODULO_ATUAL=00-preparo passo "Terminar instalações interrompidas (dpkg)" consertar_dpkg
if [[ "$ONLINE" == 1 ]]; then
  MODULO_ATUAL=00-preparo passo "Atualizar lista de pacotes" apt_atualizar
fi

selecionado() {
  local num="$1" x
  if ((${#SOMENTE[@]})); then
    for x in "${SOMENTE[@]}"; do [[ "$num" == "$x" ]] && return 0; done
    return 1
  fi
  for x in "${PULAR[@]}"; do [[ "$num" == "$x" ]] && return 1; done
  return 0
}

INICIO=$SECONDS
for modulo in "$REPO"/modulos/[0-9]*.sh; do
  nome="$(basename "$modulo" .sh)"
  num="${nome%%-*}"
  selecionado "$num" || continue
  echo
  echo "${C_B}── $nome: $(sed -n 's/^# DESCRICAO: //p' "$modulo")${C_0}"
  echo "[$(agora)] ===== MÓDULO $nome =====" >>"$LOG_GERAL"
  # Cada módulo roda num subshell: se ele "explodir", o próximo roda mesmo assim.
  # shellcheck disable=SC1090
  ( export MODULO_ATUAL="$nome"; source "$modulo" )
  rc=$?
  if ((rc != 0)); then
    MODULO_ATUAL="$nome" aviso "o módulo terminou com código $rc (os passos dele estão no resumo)"
  fi
  # Se a internet voltou (ex.: o driver de Wi-Fi acabou de ser instalado), avisa os próximos.
  if [[ "$ONLINE" == 0 ]] && tem_internet; then
    export ONLINE=1
    log "Internet ficou disponível — os próximos módulos vão usá-la."
  fi
done

# ---------- Diagnóstico para consulta futura (inclusive pelo Claude local) ----------
echo
log "Gerando diagnóstico do hardware em $LOG_DIR/diagnostico.txt"
{
  for c in "uname -a" "cat /sys/class/dmi/id/product_name" "lsb_release -a" "free -h" "swapon --show" \
           "zramctl" "lspci -nnk" "lsusb" "rfkill list" "nmcli device status" "dkms status" \
           "lsmod" "systemctl --failed --no-pager" "sensors" "cat /proc/acpi/wakeup" \
           "ls /sys/class/backlight /sys/class/leds" "upower -d" "df -h /" \
           "journalctl -b -p err --no-pager -n 150"; do
    echo "################ $c"
    timeout 30 bash -c "$c" 2>&1
    echo
  done
} >"$LOG_DIR/diagnostico.txt" 2>&1

# ---------- Resumo ----------
n_ok=$(grep -c '^OK' "$RESUMO"); n_f=$(grep -c '^FALHOU' "$RESUMO")
n_p=$(grep -c '^PULADO' "$RESUMO"); n_a=$(grep -c '^AVISO' "$RESUMO")
min=$(((SECONDS - INICIO) / 60))
{
  echo "Ubuntu-Mac — resumo de $CARIMBO (duração: ${min} min)"
  echo "OK: $n_ok | FALHOU: $n_f | PULADO: $n_p | AVISOS: $n_a"
  echo
  column -t -s $'\t' "$RESUMO" 2>/dev/null || cat "$RESUMO"
} >"$LOG_DIR/resumo.txt"

echo
echo "${C_B}=== Resumo (${min} min) ===${C_0}"
echo "${C_OK}OK: $n_ok${C_0}   ${C_ERR}Falhas: $n_f${C_0}   ${C_SKIP}Pulados: $n_p   Avisos: $n_a${C_0}"
if ((n_f > 0)); then
  echo
  echo "${C_ERR}O que falhou:${C_0}"
  cut -d'|' -f1,2 "$FALHAS" | sed 's/^/  • /'
  echo
  echo "Detalhes em: $LOG_DIR/instalacao.log"
  echo "Dica: rode de novo (é seguro repetir) ou abra o Claude Code nesta pasta e peça:"
  echo "      \"leia logs/ultimo e resolva as falhas\""
fi
echo
echo "Resumo completo: $LOG_DIR/resumo.txt"
echo
echo "${C_B}Reinicie o computador para aplicar tudo.${C_0} Depois de reiniciar, confira com:  ubuntu-mac --verificar"
if [[ -t 0 ]]; then
  read -r -t 300 -p "Reiniciar agora? [s/N] " resposta || resposta=""
  if [[ "$resposta" =~ ^[sS] ]]; then
    kill "$SUDO_PID" 2>/dev/null
    sudo systemctl reboot
  fi
fi
