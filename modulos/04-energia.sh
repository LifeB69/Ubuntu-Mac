# shellcheck shell=bash
# DESCRICAO: Bateria e temperatura — TLP, thermald e controle da ventoinha (mbpfan)

if [[ "$ONLINE" != 1 ]]; then pular "Energia" "sem internet"; return 0; fi

instalar_lista "gerenciamento de energia" tlp thermald mbpfan

passo "Configurar TLP para MacBook Air" copiar_root tlp-ubuntu-mac.conf /etc/tlp.d/90-ubuntu-mac.conf
passo "Configurar mbpfan" copiar_root mbpfan.conf /etc/mbpfan.conf

passo "Carregar módulos de sensores (coretemp, applesmc)" bash -c '
  printf "coretemp\napplesmc\n" | sudo tee /etc/modules-load.d/ubuntu-mac-sensores.conf >/dev/null
  sudo modprobe coretemp; sudo modprobe applesmc'

passo "Ativar TLP" sudo systemctl enable --now tlp.service
passo "Ativar thermald" sudo systemctl enable --now thermald.service
passo "Ativar mbpfan" sudo systemctl enable --now mbpfan.service
passo "Reiniciar mbpfan com a configuração nova" sudo systemctl restart mbpfan.service
