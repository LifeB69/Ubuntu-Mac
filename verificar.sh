#!/usr/bin/env bash
# Ubuntu-Mac — confere se está tudo funcionando (rode depois de reiniciar).
#   ubuntu-mac --verificar     (ou:  ~/Ubuntu-Mac/verificar.sh)
# Não muda nada no sistema e não pede senha.

set -uo pipefail

if [[ -t 1 ]]; then OK=$'\e[32m✔\e[0m'; NAO=$'\e[31m✘\e[0m'; TALVEZ=$'\e[33m•\e[0m'; B=$'\e[1m'; Z=$'\e[0m'
else OK='[ok]'; NAO='[FALHOU]'; TALVEZ='[atenção]'; B=; Z=; fi

n_ok=0 n_nao=0 n_talvez=0
contem() { grep "$@" >/dev/null; }
ok() { echo "  $OK $1"; n_ok=$((n_ok + 1)); }
nao() { echo "  $NAO $1"; [[ -n "${2:-}" ]] && echo "      → $2"; n_nao=$((n_nao + 1)); }
talvez() { echo "  $TALVEZ $1"; [[ -n "${2:-}" ]] && echo "      → $2"; n_talvez=$((n_talvez + 1)); }
checa() { # checa "descrição" "dica se falhar" comando...
  local d="$1" dica="$2"; shift 2
  if "$@" >/dev/null 2>&1; then ok "$d"; else nao "$d" "$dica"; fi
}
ativo() { systemctl is-active --quiet "$1"; }
instalado() { dpkg-query -W -f='${Status}' "$1" 2>/dev/null | contem 'install ok installed'; }

modelo="$(cat /sys/class/dmi/id/product_name 2>/dev/null)"
echo "${B}Ubuntu-Mac — verificação${Z}  (${modelo:+$modelo, }kernel $(uname -r))"

echo; echo "${B}Wi-Fi${Z}"
checa "Driver wl carregado" "dkms status; sudo modprobe wl; veja logs/ultimo/instalacao.log (02-wifi)" \
  bash -c "lsmod | grep -q '^wl '"
checa "Placa Wi-Fi reconhecida pela rede" "nmcli device; rfkill list" \
  bash -c "nmcli -t -f TYPE device | grep -qx wifi"
if dkms status 2>/dev/null | contem "broadcom-sta.*$(uname -r).*installed"; then
  ok "Driver compilado para o kernel atual"
else
  nao "Driver compilado para o kernel atual" "sudo dkms autoinstall"
fi

echo; echo "${B}Memória${Z}"
checa "zram (memória comprimida) ativo" "sudo systemctl restart zramswap; zramctl" bash -c "swapon --show | grep -q zram"
checa "earlyoom (evita congelar sem memória)" "sudo systemctl restart earlyoom" ativo earlyoom
echo "      $(free -h | awk '/^Mem/{print "RAM: "$2" no total, "$7" disponível"}')"

echo; echo "${B}Energia e temperatura${Z}"
checa "TLP (bateria)" "sudo systemctl restart tlp; sudo tlp-stat -s" ativo tlp
checa "thermald" "sudo systemctl restart thermald" ativo thermald
checa "mbpfan (ventoinha)" "sudo systemctl restart mbpfan; lsmod | grep applesmc" ativo mbpfan
if command -v sensors >/dev/null; then
  t=$(sensors 2>/dev/null | awk '/^Package id 0:/{print $4; exit}')
  [[ -n "$t" ]] && echo "      Temperatura do processador: $t"
fi

echo; echo "${B}Teclado e touchpad${Z}"
checa "keyd (⌘ como no Mac)" "sudo systemctl restart keyd; journalctl -u keyd -n 20" ativo keyd
if [[ -f /etc/keyd/default.conf && -f "$(dirname "$0")/arquivos/keyd-mac.conf" ]] &&
   contem -F "$(head -1 "$(dirname "$0")/arquivos/keyd-mac.conf")" /etc/keyd/default.conf; then
  ok "Atalhos do Mac instalados (/etc/keyd/default.conf)"
else
  nao "Atalhos do Mac instalados (/etc/keyd/default.conf)" "./instalar.sh --somente 05"
fi
checa "Layout com acentos ($(. /etc/default/keyboard 2>/dev/null; echo "${XKBLAYOUT:-?} ${XKBVARIANT:-}"))" \
  "./instalar.sh --somente 05" test -f /etc/default/keyboard
checa "Configuração do touchpad" "./instalar.sh --somente 06" test -f /etc/X11/xorg.conf.d/30-ubuntu-mac-touchpad.conf
checa "Correção 'ignorar palma' com keyd" "./instalar.sh --somente 06" test -f /etc/libinput/local-overrides.quirks
if id -nG "$USER" | contem -w input; then
  if id -nG | contem -w input; then
    ok "Permissão para gestos (grupo input)"
  else
    talvez "Permissão para gestos concedida, mas ainda não vale" "saia da sessão e entre de novo (ou reinicie)"
  fi
else
  nao "Permissão para gestos (grupo input)" "sudo gpasswd -a $USER input; depois saia e entre"
fi
if pgrep -u "$USER" -f 'libinput-gestures' >/dev/null; then
  ok "Gestos de 3/4 dedos rodando"
else
  nao "Gestos de 3/4 dedos rodando" "libinput-gestures-setup restart; libinput-gestures-setup status"
fi

echo; echo "${B}Programas${Z}"
if dpkg-query -W -f='${Version}' firefox 2>/dev/null | contem -v snap; then ok "Firefox (.deb da Mozilla)"
elif timeout 15 snap list firefox >/dev/null 2>&1; then talvez "Firefox ainda é o Snap" "./instalar.sh --somente 08"
else nao "Firefox" "./instalar.sh --somente 08"; fi
if timeout 15 snap list firefox >/dev/null 2>&1 && dpkg-query -W -f='${Version}' firefox 2>/dev/null | contem -v snap; then
  talvez "Há dois Firefox (Snap e .deb)" "sudo snap remove --purge firefox"
fi
checa "Google Chrome (para o Claude in Chrome)" "./instalar.sh --somente 08 (ou INSTALAR_CHROME=0 no config.conf)" instalado google-chrome-stable
checa "Claude Desktop" "./instalar.sh --somente 09" instalado claude-desktop
checa "Claude Code (comando claude)" "./instalar.sh --somente 09; abra um terminal novo" \
  bash -c "command -v claude || test -x \"$HOME/.local/bin/claude\""

echo; echo "${B}Aparência${Z}"
checa "Dock (Plank) rodando" "plank &   (e confira ~/.config/autostart/plank.desktop)" pgrep -u "$USER" -x plank
checa "Terminal: ⌘C copia e ⌘V cola" "./instalar.sh --somente 05" test -f "$HOME/.config/xfce4/terminal/accels.scm"
checa "Dock abre sozinha ao entrar" "./instalar.sh --somente 10" test -f "$HOME/.config/autostart/plank.desktop"
if command -v xfconf-query >/dev/null && [[ -n "${DISPLAY:-}" ]]; then
  tema=$(xfconf-query -c xsettings -p /Net/ThemeName 2>/dev/null)
  [[ "$tema" == Arc* ]] && ok "Tema Arc" || talvez "Tema atual: ${tema:-?}" "./instalar.sh --somente 10"
fi

echo; echo "${B}Sistema${Z}"
f=$(systemctl --failed --no-legend --plain 2>/dev/null | awk '{print $1}' | tr '\n' ' ')
[[ -z "$f" ]] && ok "Nenhum serviço com falha" || talvez "Serviços com falha: $f" "systemctl status <nome>"
livre=$(df -h --output=avail / | tail -1 | tr -d ' ')
echo "      Espaço livre no disco: $livre"

echo
echo "${B}Resultado:${Z} $OK $n_ok   $NAO $n_nao   $TALVEZ $n_talvez"
if ((n_nao > 0)); then
  echo "Dica: rode  ubuntu-mac  de novo, ou abra o Claude Code em ~/Ubuntu-Mac e peça"
  echo "      \"rode o verificar.sh e resolva o que falhou\"."
fi
exit $((n_nao > 0))
