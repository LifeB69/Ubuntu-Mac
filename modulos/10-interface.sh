# shellcheck shell=bash
# DESCRICAO: Interface com cara de Mac — dock, tema, fontes, botões à esquerda e atalhos

if [[ "$TEMA_MAC" != 1 ]]; then pular "Interface" "desligado no config.conf"; return 0; fi
if ! em_sessao_grafica; then
  pular "Interface" "rode o instalar.sh de dentro da área de trabalho (terminal do Xfce)"
  return 0
fi

# A aparência é aplicada uma vez só, para não desfazer o que você mudar depois
# (tema, dock, atalhos). Para reaplicar tudo: ./instalar.sh --somente 10
MARCA_INTERFACE="$HOME/.config/ubuntu-mac/interface-aplicada"
if [[ -f "$MARCA_INTERFACE" ]] && ! modulo_pedido 10; then
  pular "Interface" "já aplicada antes (para reaplicar: ubuntu-mac --somente 10)"
  return 0
fi

# Define uma configuração do Xfce (cria se não existir).
xfset() { # canal propriedade tipo valor
  xfconf-query -c "$1" -p "$2" -s "$4" 2>/dev/null || xfconf-query -c "$1" -p "$2" -n -t "$3" -s "$4"
}

tema_existe() { [[ -d "/usr/share/themes/$1" ]]; }
icones_existem() { [[ -d "/usr/share/icons/$1" ]]; }

# ---------- Tema, ícones e fontes ----------
if tema_existe Arc; then
  passo "Tema das janelas: Arc" xfset xsettings /Net/ThemeName string Arc
  passo "Borda das janelas: Arc" xfset xfwm4 /general/theme string Arc
else
  pular "Tema Arc" "tema não instalado (módulo 08 falhou?)"
fi
if icones_existem Papirus; then
  passo "Ícones: Papirus" xfset xsettings /Net/IconThemeName string Papirus
else
  pular "Ícones Papirus" "não instalados (módulo 08 falhou?)"
fi
if fc-list | contem -i 'Inter'; then
  passo "Fonte da interface: Inter" xfset xsettings /Gtk/FontName string "Inter 10"
  passo "Fonte dos títulos: Inter" xfset xfwm4 /general/title_font string "Inter Semi-Bold 10"
fi
if fc-list | contem -i 'JetBrains Mono'; then
  passo "Fonte monoespaçada: JetBrains Mono" xfset xsettings /Gtk/MonospaceFontName string "JetBrains Mono 10"
  passo "Terminal: fonte JetBrains Mono" bash -c '
    xfconf-query -c xfce4-terminal -p /font-use-system -n -t bool -s false &&
    xfconf-query -c xfce4-terminal -p /font-name -n -t string -s "JetBrains Mono 11"'
fi
passo "Suavização de fontes" bash -c '
  xfconf-query -c xsettings -p /Xft/Antialias -n -t int -s 1 &&
  xfconf-query -c xsettings -p /Xft/HintStyle -n -t string -s hintslight &&
  xfconf-query -c xsettings -p /Xft/RGBA -n -t string -s rgb'

# ---------- Janelas no estilo Mac ----------
passo "Botões das janelas à esquerda (fechar, minimizar, maximizar)" \
  xfset xfwm4 /general/button_layout string "CHM|"
passo "Título das janelas centralizado" xfset xfwm4 /general/title_alignment string center
passo "Sem sombra embaixo da dock" xfset xfwm4 /general/show_dock_shadow bool false
# O Xubuntu vem com 1 só área de trabalho; os gestos de 3 dedos ← → precisam de mais.
passo "4 áreas de trabalho (para os gestos de 3 dedos)" xfset xfwm4 /general/workspace_count int 4

# ---------- Barra de cima no estilo Mac ----------
# (Os atalhos de teclado ficam no módulo 05.)
plugin_id() { # plugin_id tipo -> id do primeiro plugin desse tipo no painel
  xfconf-query -c xfce4-panel -lv 2>/dev/null |
    awk -v t="$1" '$1 ~ "^/plugins/plugin-[0-9]+$" && $2 == t {sub("/plugins/plugin-", "", $1); print $1; exit}'
}
relogio_mac() {
  local id; id="$(plugin_id clock)"
  [[ -n "$id" ]] || { echo "Relógio não encontrado no painel"; return 1; }
  # Como a barra do Mac: "qua 4 nov  07:04"
  xfconf-query -c xfce4-panel -p "/plugins/plugin-$id/digital-layout" -n -t int -s 3 &&
    xfconf-query -c xfce4-panel -p "/plugins/plugin-$id/digital-time-format" -n -t string -s " %a %-d %b  %H:%M "
}
passo "Relógio como na barra do Mac (dia da semana, data e hora)" relogio_mac

# A lista de janelas na barra de cima repete o que a dock já mostra (o Mac não
# tem isso) e ocupa espaço numa tela de 11". Os apps abertos aparecem na dock.
tirar_lista_janelas() {
  local id ids novos=() x
  id="$(plugin_id tasklist)"
  [[ -n "$id" ]] || { echo "Lista de janelas já não está no painel"; return 0; }
  mapfile -t ids < <(xfconf-query -c xfce4-panel -p /panels/panel-1/plugin-ids 2>/dev/null | grep -E '^[0-9]+$')
  for x in "${ids[@]}"; do [[ "$x" != "$id" ]] && novos+=(-t int -s "$x"); done
  ((${#novos[@]})) || return 1
  xfconf-query -c xfce4-panel -p /panels/panel-1/plugin-ids "${novos[@]}" &&
    xfconf-query -c xfce4-panel -p "/plugins/plugin-$id" -r -R || return 1
  # O painel só aplica a remoção quando reinicia.
  (setsid xfce4-panel -r >/dev/null 2>&1 &)
  sleep 3
}
if command -v plank >/dev/null; then
  passo "Tirar a lista de janelas da barra de cima (fica na dock)" tirar_lista_janelas
fi

# ---------- Dock (Plank) ----------
if ! command -v plank >/dev/null; then
  pular "Dock (Plank)" "plank não instalado (módulo 08 falhou?) — rode de novo com --somente 08 10"
  return 0
fi

achar_desktop() { # imprime o primeiro .desktop existente
  local f
  for f in "$@"; do [[ -f "$f" ]] && { echo "$f"; return 0; }; done
  return 1
}

configurar_dock() {
  local dir="$HOME/.config/plank/dock1/launchers" itens=() f nome
  pkill -x plank 2>/dev/null; sleep 1
  mkdir -p "$dir"
  rm -f "$dir"/*.dockitem
  local apps=(
    "$(achar_desktop /usr/share/applications/thunar.desktop)"
    "$(achar_desktop /usr/share/applications/firefox.desktop /var/lib/snapd/desktop/applications/firefox_firefox.desktop)"
    "$(find /usr/share/applications -maxdepth 1 -iname '*claude*.desktop' 2>/dev/null | head -n1)"
    "$(achar_desktop /usr/share/applications/xfce4-terminal.desktop /usr/share/applications/xfce4-terminal-emulator.desktop)"
    "$(achar_desktop /usr/share/applications/org.xfce.mousepad.desktop /usr/share/applications/mousepad.desktop)"
    "$(achar_desktop /usr/share/applications/xfce-settings-manager.desktop /usr/share/applications/xfce4-settings-manager.desktop)"
  )
  for f in "${apps[@]}"; do
    [[ -n "$f" ]] || continue
    nome="$(basename "$f" .desktop).dockitem"
    printf '[PlankDockItemPreferences]\nLauncher=file://%s\n' "$f" >"$dir/$nome"
    itens+=("'$nome'")
  done
  local lista; lista="[$(IFS=,; echo "${itens[*]}")]"
  local base=/net/launchpad/plank/docks/dock1
  dconf write $base/dock-items "$lista"
  # "Gtk+": fundo escuro arredondado como a dock do macOS; funciona com ou sem
  # composição de janelas (o "Transparent" deixa os ícones soltos, sem fundo).
  dconf write $base/theme "'Gtk+'"
  dconf write $base/hide-mode "'window-dodge'"
  dconf write $base/icon-size 40
  dconf write $base/zoom-enabled true
  dconf write $base/zoom-percent 140
  dconf write $base/position "'bottom'"
  dconf write $base/lock-items false
}
passo "Configurar a dock (Arquivos, Firefox, Claude, Terminal, Editor, Configurações)" configurar_dock

passo "Abrir a dock automaticamente ao entrar" bash -c '
  mkdir -p "$HOME/.config/autostart" &&
  printf "[Desktop Entry]\nType=Application\nName=Plank (dock)\nExec=plank\nX-GNOME-Autostart-enabled=true\n" \
    > "$HOME/.config/autostart/plank.desktop"'
passo "Iniciar a dock agora" bash -c '(setsid plank >/dev/null 2>&1 &) ; sleep 2; pgrep -x plank'

# Só marca como aplicada se nada falhou ou foi pulado neste módulo.
if ! grep -E "^(FALHOU|PULADO)"$'\t'"$MODULO_ATUAL"$'\t' "$RESUMO" >/dev/null; then
  mkdir -p "$(dirname "$MARCA_INTERFACE")" && date >"$MARCA_INTERFACE"
fi
