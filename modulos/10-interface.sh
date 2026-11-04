# shellcheck shell=bash
# DESCRICAO: Interface com cara de Mac — dock, tema, fontes, botões à esquerda e atalhos

if [[ "$TEMA_MAC" != 1 ]]; then pular "Interface" "desligado no config.conf"; return 0; fi
if ! em_sessao_grafica; then
  pular "Interface" "rode o instalar.sh de dentro da área de trabalho (terminal do Xfce)"
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

# ---------- Atalhos ----------
# ⌘ sozinho manda "Super"; ⌘+Espaço manda "Super+Espaço" (ver arquivos/keyd-mac.conf).
if command -v xfce4-popup-whiskermenu >/dev/null; then
  passo "Atalho: ⌘ abre o menu" \
    xfset xfce4-keyboard-shortcuts "/commands/custom/Super_L" string xfce4-popup-whiskermenu
  passo "Atalho: ⌘+Espaço abre o menu (busca)" \
    xfset xfce4-keyboard-shortcuts "/commands/custom/<Super>space" string xfce4-popup-whiskermenu
fi
passo "Atalho: Ctrl+Alt+T abre o terminal" \
  xfset xfce4-keyboard-shortcuts "/commands/custom/<Primary><Alt>t" string "xfce4-terminal"
passo "Atalho: ⌘+Shift+3 captura a tela inteira" \
  xfset xfce4-keyboard-shortcuts "/commands/custom/<Primary><Shift>numbersign" string "xfce4-screenshooter -f"
passo "Atalho: ⌘+Shift+4 captura uma área da tela" \
  xfset xfce4-keyboard-shortcuts "/commands/custom/<Primary><Shift>dollar" string "xfce4-screenshooter -r"

# ---------- Dock (Plank) ----------
if ! command -v plank >/dev/null; then
  pular "Dock (Plank)" "plank não instalado (módulo 08 falhou?)"
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
  dconf write $base/theme "'Transparent'"
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
