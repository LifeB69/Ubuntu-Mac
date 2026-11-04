# shellcheck shell=bash
# DESCRICAO: Bateria e temperatura — TLP, thermald, ventoinha (mbpfan), tecla ⏻ e tampa

if [[ "$ONLINE" != 1 ]]; then pular "Energia" "sem internet"; return 0; fi

instalar_lista "gerenciamento de energia" tlp thermald mbpfan

passo "Configurar TLP para MacBook Air" copiar_root tlp-ubuntu-mac.conf /etc/tlp.d/90-ubuntu-mac.conf
passo "Configurar mbpfan" copiar_root mbpfan.conf /etc/mbpfan.conf

passo "Carregar módulos de sensores (coretemp, applesmc)" bash -c '
  printf "coretemp\napplesmc\n" | sudo tee /etc/modules-load.d/ubuntu-mac-sensores.conf >/dev/null
  sudo modprobe coretemp; sudo modprobe applesmc'

passo "Ativar TLP" ativar_servico tlp.service
passo "Ativar thermald" ativar_servico thermald.service
passo "Ativar mbpfan" ativar_servico mbpfan.service

# ---------- Tecla ⏻, tampa e bateria crítica ----------
# A tecla ⏻ do MacBook Air fica colada no F12: apertar sem querer não pode desligar.
# Na tela de login (sem o gerenciador de energia do Xfce) quem decide é o logind.
passo "Tecla ⏻ na tela de login: suspender (segurar: desligar)" escrever_root /etc/systemd/logind.conf.d/90-ubuntu-mac.conf <<'CONF'
# Gerado pelo Ubuntu-Mac — vale a partir do próximo boot.
[Login]
HandlePowerKey=suspend
HandlePowerKeyLongPress=poweroff
CONF

if em_sessao_grafica; then
  # Só define se você ainda não mudou isso nas configurações de energia.
  xfpm_padrao() { # propriedade valor
    local p="/xfce4-power-manager/$1"
    if xfconf-query -c xfce4-power-manager -p "$p" >/dev/null 2>&1; then
      echo "$1 já definido por você: $(xfconf-query -c xfce4-power-manager -p "$p")"
      return 0
    fi
    xfconf-query -c xfce4-power-manager -p "$p" -n -t uint -s "$2"
  }
  # Valores: 1 = suspender, 3 = perguntar, 4 = desligar
  passo "Tecla ⏻: perguntar o que fazer (suspender, reiniciar, desligar)" xfpm_padrao power-button-action 3
  passo "Fechar a tampa: suspender (na tomada)" xfpm_padrao lid-action-on-ac 1
  passo "Fechar a tampa: suspender (na bateria)" xfpm_padrao lid-action-on-battery 1
  passo "Bateria crítica (10%): desligar com segurança" xfpm_padrao critical-power-action 4
else
  pular "Tecla ⏻, tampa e bateria crítica (Xfce)" "rode de dentro da área de trabalho"
fi
