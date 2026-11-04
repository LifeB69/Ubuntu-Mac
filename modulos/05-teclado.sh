# shellcheck shell=bash
# DESCRICAO: Teclado — layout americano com acentos e ⌘ funcionando como no Mac

# 1) Layout: US com acentos pela tecla Option direita (AltGr). Ver config.conf.
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

# 2) Teclas do Mac: F1–F12 fazem brilho/volume; com fn viram F1–F12 (padrão do Mac).
passo "Teclas de função no estilo Mac (hid_apple)" escrever_root /etc/modprobe.d/ubuntu-mac-hid-apple.conf <<'CONF'
# Gerado pelo Ubuntu-Mac
# fnmode=1: teclas de mídia primeiro, fn+tecla = F1..F12 (igual ao macOS)
options hid_apple fnmode=1
CONF

# 3) ⌘ como Ctrl, usando o keyd (funciona em qualquer programa, X11 ou Wayland).
if [[ "$CMD_COMO_CTRL" != 1 ]]; then
  pular "⌘ como Ctrl (keyd)" "desligado no config.conf"
  return 0
fi
if [[ "$ONLINE" != 1 ]] && ! pacote_instalado keyd; then
  pular "⌘ como Ctrl (keyd)" "sem internet"
  return 0
fi

instalar_lista "keyd" keyd
passo "Configurar atalhos do Mac (keyd)" copiar_root keyd-mac.conf /etc/keyd/default.conf
passo "Ativar keyd" ativar_servico keyd.service
