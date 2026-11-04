# shellcheck shell=bash
# DESCRICAO: Teclado — tudo como no Mac: ⌘, ⌥ com acentos do Mac, teclas F e atalhos

# ---------- 1) Layout: "English (Macintosh)" ----------
# O mesmo do macOS com teclado americano: ⌥e a = á, ⌥n a = ã, ⌥i e = ê,
# ⌥` a = à, ⌥u u = ü, ⌥c = ç (e os demais símbolos do ⌥ do Mac).
passo "Layout de teclado: $TECLADO_LAYOUT ($TECLADO_VARIANTE)" escrever_root /etc/default/keyboard <<CONF
# Gerado pelo Ubuntu-Mac
XKBMODEL="pc105"
XKBLAYOUT="$TECLADO_LAYOUT"
XKBVARIANT="$TECLADO_VARIANTE"
XKBOPTIONS=""
BACKSPACE="guess"
CONF
if em_sessao_grafica; then
  passo "Aplicar layout agora" setxkbmap -layout "$TECLADO_LAYOUT" -variant "$TECLADO_VARIANTE"
  # Faz o Xfce seguir o layout do sistema (em vez de uma configuração própria).
  passo "Xfce: usar layout do sistema" \
    xfconf-query -c keyboard-layout -p /Default/XkbDisable -n -t bool -s true
fi

# ---------- 2) Teclas F: mídia primeiro, com fn = F1..F12 (igual ao macOS) ----------
passo "Teclas de função no estilo Mac (hid_apple)" escrever_root /etc/modprobe.d/ubuntu-mac-hid-apple.conf <<'CONF'
# Gerado pelo Ubuntu-Mac
# fnmode=1: F1–F12 fazem brilho/mídia/volume; fn+tecla = F1..F12 (como no macOS).
# fn+← → ↑ ↓ = Home/End/PgUp/PgDn e fn+⌫ = Delete são do próprio driver.
options hid_apple fnmode=1
CONF

# ---------- 3) ⌘, ⌥ e ⌃ como no Mac (keyd) ----------
if [[ "$CMD_COMO_CTRL" != 1 ]]; then
  pular "Atalhos do Mac (keyd)" "desligado no config.conf"
else
  if [[ "$ONLINE" != 1 ]] && ! pacote_instalado keyd; then
    pular "Atalhos do Mac (keyd)" "sem internet"
  else
    instalar_lista "keyd" keyd
    montar_keyd() {
      local partes=("$REPO/arquivos/keyd-mac.conf")
      [[ "$OPTION_ESQUERDO" == mac ]] && partes+=("$REPO/arquivos/keyd-option-mac.conf")
      cat "${partes[@]}" | escrever_root /etc/keyd/default.conf
    }
    passo "Configurar atalhos do Mac (keyd, ⌥ esquerdo = $OPTION_ESQUERDO)" montar_keyd
    passo "Ativar keyd" ativar_servico keyd.service
  fi
  # No terminal, ⌘C/⌘V chegam como Ctrl+Insert/Shift+Insert. O padrão do terminal
  # colava a seleção do mouse no Shift+Insert; aqui passa a colar o que você copiou.
  passo "Terminal: ⌘C copia e ⌘V cola (Ctrl+C continua interrompendo)" \
    install -D -m 644 "$REPO/arquivos/terminal-accels.scm" "$HOME/.config/xfce4/terminal/accels.scm"
fi

# ---------- 4) Atalhos do Xfce para as teclas e combinações do Mac ----------
if ! em_sessao_grafica; then
  pular "Atalhos do Xfce" "rode de dentro da área de trabalho"
  return 0
fi
atalho() { # atalho "<Combinação>" "comando"
  xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/$1" -s "$2" 2>/dev/null ||
    xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/$1" -n -t string -s "$2"
}
passo "F3 (Mission Control): ver todas as janelas" atalho "XF86LaunchA" "xfdashboard --toggle"
passo "F4 (Launchpad): aplicativos" atalho "XF86LaunchB" "xfce4-popup-whiskermenu"
passo "⌘Espaço: buscar aplicativos" atalho "<Super>space" "xfce4-popup-whiskermenu"
passo "⌘⇧3: captura da tela inteira" atalho "<Primary><Shift>numbersign" "xfce4-screenshooter -f"
passo "⌘⇧4: captura de uma área" atalho "<Primary><Shift>dollar" "xfce4-screenshooter -r"
passo "⌘⇧5: opções de captura" atalho "<Primary><Shift>percent" "xfce4-screenshooter"
passo "Ctrl+Alt+T: terminal" atalho "<Primary><Alt>t" "xfce4-terminal"
