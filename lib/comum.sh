# shellcheck shell=bash
# shellcheck disable=SC2034  # cores são usadas pelos módulos
# Funções compartilhadas por instalar.sh e pelos módulos.
# Filosofia: NUNCA parar no primeiro erro. Cada passo é registrado como
# OK / FALHOU / PULADO e a instalação segue até onde der.

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

# Espera até 15 min se outro apt (ex.: atualização automática) estiver rodando.
APT_OPTS=(-y -o DPkg::Lock::Timeout=900 -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold)

if [[ -t 1 ]]; then
  C_OK=$'\e[32m'; C_ERR=$'\e[31m'; C_SKIP=$'\e[33m'; C_INFO=$'\e[36m'; C_B=$'\e[1m'; C_0=$'\e[0m'
else
  C_OK=; C_ERR=; C_SKIP=; C_INFO=; C_B=; C_0=
fi

agora() { date '+%H:%M:%S'; }

# Escreve na tela e no log geral.
log() { echo "${C_INFO}[$(agora)]${C_0} $*"; echo "[$(agora)] $*" >>"$LOG_GERAL"; }

_registrar() { # status descrição
  printf '%s\t%s\t%s\n' "$1" "${MODULO_ATUAL:-geral}" "$2" >>"$RESUMO"
  if [[ "$1" == FALHOU ]]; then
    printf '%s | %s | ver %s (procure "%s")\n' "${MODULO_ATUAL:-geral}" "$2" "$LOG_GERAL" "$2" >>"$FALHAS"
  fi
}

# passo "descrição" comando args...
# Roda o comando, manda a saída para o log e registra o resultado.
passo() {
  local desc="$1"; shift
  printf '%s  ▶ %s ... ' "[$(agora)]" "$desc"
  {
    echo
    echo "===== [$(agora)] ${MODULO_ATUAL:-geral} :: $desc"
    echo "----- comando: $*"
  } >>"$LOG_GERAL"
  if "$@" >>"$LOG_GERAL" 2>&1; then
    echo "${C_OK}OK${C_0}"
    echo "----- resultado: OK" >>"$LOG_GERAL"
    _registrar OK "$desc"
    return 0
  else
    local rc=$?
    echo "${C_ERR}FALHOU (código $rc)${C_0}"
    echo "----- resultado: FALHOU (código $rc)" >>"$LOG_GERAL"
    _registrar FALHOU "$desc (código $rc)"
    return "$rc"
  fi
}

pular() { # pular "descrição" "motivo"
  echo "[$(agora)]  ${C_SKIP}⏭ $1 — pulado: $2${C_0}"
  echo "[$(agora)] PULADO: $1 — $2" >>"$LOG_GERAL"
  _registrar PULADO "$1 — $2"
}

aviso() {
  echo "[$(agora)]  ${C_SKIP}⚠ $*${C_0}"
  echo "[$(agora)] AVISO: $*" >>"$LOG_GERAL"
  printf 'AVISO\t%s\t%s\n' "${MODULO_ATUAL:-geral}" "$*" >>"$RESUMO"
}

# tentar N comando...  -> repete com espera crescente (5s, 10s, 20s...)
tentar() {
  local n="$1"; shift
  local i espera=5
  for ((i = 1; i <= n; i++)); do
    "$@" && return 0
    ((i < n)) && { echo "  (tentativa $i/$n falhou, nova tentativa em ${espera}s)"; sleep "$espera"; espera=$((espera * 2)); }
  done
  return 1
}

# wget com limite de tempo: o padrão do wget pode ficar até horas tentando.
wget() { command wget --timeout=30 --tries=3 "$@"; }

# Ativa e (re)inicia um serviço SEM esperar por ele (--no-block).
# Um serviço que trava ao iniciar não pode prender a instalação inteira.
ativar_servico() { # ativar_servico nome.service
  sudo systemctl enable "$1" || return 1
  sudo systemctl restart --no-block "$1" || return 1
  local i
  for ((i = 0; i < 30; i++)); do
    systemctl is-active --quiet "$1" && { echo "$1: ativo"; return 0; }
    if systemctl is-failed --quiet "$1"; then
      systemctl status "$1" --no-pager -l 2>&1 | tail -20
      return 1
    fi
    sleep 1
  done
  echo "$1 ainda está iniciando depois de 30 s — seguindo em frente."
  systemctl status "$1" --no-pager -l 2>&1 | tail -10
  return 0
}

tem_internet() {
  wget -q --spider --timeout=8 https://archive.ubuntu.com/ubuntu/ 2>/dev/null ||
    wget -q --spider --timeout=8 https://www.google.com 2>/dev/null
}

# "grep -q" num pipe com "set -o pipefail" dá falso negativo: o grep sai na
# primeira linha encontrada, o comando anterior morre com SIGPIPE e o pipe
# inteiro "falha". contem() lê a entrada até o fim e só devolve o resultado.
contem() { grep "$@" >/dev/null; }

pacote_instalado() { dpkg-query -W -f='${Status}' "$1" 2>/dev/null | contem 'install ok installed'; }

apt_atualizar() { tentar 3 sudo apt-get "${APT_OPTS[@]}" update; }

# Instala pacotes. Tenta todos de uma vez; se falhar, tenta um por um,
# para que um pacote problemático não impeça os outros.
apt_instalar() {
  local faltando=() p
  for p in "$@"; do pacote_instalado "$p" || faltando+=("$p"); done
  if ((${#faltando[@]} == 0)); then
    echo "  (já instalados: $*)" >>"$LOG_GERAL"
    return 0
  fi
  tentar 2 sudo apt-get "${APT_OPTS[@]}" install "${faltando[@]}" && return 0
  echo "  instalação em lote falhou; tentando pacote por pacote" >>"$LOG_GERAL"
  local rc=0
  for p in "${faltando[@]}"; do
    if ! tentar 2 sudo apt-get "${APT_OPTS[@]}" install "$p"; then
      echo "  !! não foi possível instalar: $p" >>"$LOG_GERAL"
      rc=1
    fi
  done
  return "$rc"
}

# Instala um grupo de pacotes registrando cada pacote individualmente no resumo.
instalar_lista() { # instalar_lista "rótulo" pacotes...
  local rotulo="$1"; shift
  passo "Instalar $rotulo ($*)" apt_instalar "$@" && return 0
  local p
  for p in "$@"; do
    pacote_instalado "$p" || _registrar FALHOU "pacote ausente após instalação: $p"
  done
  return 1
}

# Escreve um arquivo de sistema (via sudo) a partir do stdin.
escrever_root() { # escrever_root /caminho [modo]
  local destino="$1" modo="${2:-644}"
  sudo mkdir -p "$(dirname "$destino")" &&
    sudo tee "$destino" >/dev/null &&
    sudo chmod "$modo" "$destino"
}

# Copia um arquivo da pasta arquivos/ do repositório para o sistema.
copiar_root() { # copiar_root origem_relativa destino [modo]
  sudo install -D -m "${3:-644}" "$REPO/arquivos/$1" "$2"
}

em_sessao_grafica() { [[ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]] && [[ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; }

# Lê variáveis de config.conf (com valores padrão se faltar algo).
carregar_config() {
  # shellcheck disable=SC1091
  [[ -f "$REPO/config.conf" ]] && source "$REPO/config.conf"
  : "${TECLADO_LAYOUT:=us}" "${TECLADO_VARIANTE:=altgr-intl}"
  : "${CMD_COMO_CTRL:=1}" "${ZRAM_PORCENTAGEM:=60}"
  : "${FIREFOX_DEB:=1}" "${INSTALAR_CHROME:=1}" "${INSTALAR_CLAUDE_DESKTOP:=1}" "${INSTALAR_CLAUDE_CODE:=1}"
  : "${INSTALAR_COWORK:=0}" "${TEMA_MAC:=1}" "${FUSO_HORARIO:=America/Sao_Paulo}"
}
