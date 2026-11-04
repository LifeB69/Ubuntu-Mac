# shellcheck shell=bash
# DESCRICAO: Touchpad — rolagem natural, toque para clicar e gestos de 3/4 dedos e pinça

# ---------- Básico (driver libinput do X11) ----------
# 1 dedo toca = clique | 2 dedos tocam ou clicam = botão direito | 3 dedos = botão do meio
# 2 dedos arrastam = rolagem natural | palma da mão ignorada enquanto digita
passo "Configurar touchpad (libinput)" copiar_root touchpad.conf /etc/X11/xorg.conf.d/30-ubuntu-mac-touchpad.conf

# O keyd (módulo 05) cria um "teclado virtual". Sem isto, o libinput acha que ele
# é um teclado externo e o "ignorar o touchpad enquanto digita" para de funcionar.
passo "Touchpad ignora a palma enquanto digita (mesmo com keyd)" copiar_root libinput-quirks /etc/libinput/local-overrides.quirks

# Firefox: rolagem suave e pinça para zoom no X11.
ativar_xinput2_firefox() {
  grep -q '^MOZ_USE_XINPUT2=' /etc/environment || echo 'MOZ_USE_XINPUT2=1' | sudo tee -a /etc/environment >/dev/null
}
passo "Firefox: gestos e rolagem suave do touchpad" ativar_xinput2_firefox

# ---------- Gestos (libinput-gestures) ----------
#  3 dedos ← →   troca de área de trabalho
#  3 dedos ↑     mostra todas as janelas (xfdashboard, parecido com o Mission Control)
#  3 dedos ↓     mostra a área de trabalho
#  4 dedos ← →   voltar / avançar no navegador
#  pinça         zoom (no Firefox o zoom é nativo e suave)
if [[ "$ONLINE" != 1 ]]; then pular "Gestos do touchpad" "sem internet"; return 0; fi

instalar_lista "dependências dos gestos" libinput-tools wmctrl xdotool python3 make git xfdashboard

LG_VERSAO=2.81
instalar_libinput_gestures() {
  if command -v libinput-gestures >/dev/null; then
    echo "libinput-gestures já instalado"; return 0
  fi
  local tmp; tmp="$(mktemp -d)"
  local src="$tmp/libinput-gestures-$LG_VERSAO"
  # Versão fixa (tag), para a instalação ser sempre igual. git primeiro; .tar.gz como reserva.
  if ! tentar 3 git clone -q --depth 1 --branch "$LG_VERSAO" https://github.com/bulletmark/libinput-gestures "$src"; then
    tentar 3 wget -qO "$tmp/lg.tar.gz" "https://github.com/bulletmark/libinput-gestures/archive/refs/tags/$LG_VERSAO.tar.gz" &&
      tar xzf "$tmp/lg.tar.gz" -C "$tmp"
  fi
  [[ -f "$src/Makefile" ]] && sudo make -C "$src" install
  local rc=$?
  rm -rf "$tmp"
  return "$rc"
}
passo "Instalar libinput-gestures $LG_VERSAO" instalar_libinput_gestures
passo "Instalar ajudante de zoom pela pinça" copiar_root ubuntu-mac-zoom /usr/local/bin/ubuntu-mac-zoom 755
passo "Configurar gestos" install -D -m 644 "$REPO/arquivos/libinput-gestures.conf" "$HOME/.config/libinput-gestures.conf"
# Ler o touchpad exige o grupo "input" (vale a partir do próximo login).
passo "Permitir leitura dos gestos (grupo input)" sudo gpasswd -a "$USER" input
if command -v libinput-gestures-setup >/dev/null; then
  passo "Iniciar gestos automaticamente ao entrar" libinput-gestures-setup autostart
  if em_sessao_grafica && id -nG | contem -w input; then
    passo "Iniciar gestos agora" libinput-gestures-setup restart
  else
    log "Os gestos começam a funcionar depois de sair e entrar de novo (ou reiniciar)."
  fi
fi
