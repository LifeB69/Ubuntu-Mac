# shellcheck shell=bash
# DESCRICAO: Touchpad — rolagem natural, toque para clicar e clique com dois dedos

passo "Configurar touchpad (libinput)" copiar_root touchpad.conf /etc/X11/xorg.conf.d/30-ubuntu-mac-touchpad.conf
log "O touchpad novo vale a partir do próximo login/reinício."
