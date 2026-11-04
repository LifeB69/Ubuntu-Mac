# shellcheck shell=bash
# DESCRICAO: Memória — swap comprimido (zram) e proteção contra travamentos (earlyoom)

# Com 4 GB de RAM, comprimir a memória (zram) faz muita diferença:
# na prática é como ter ~6 GB, sem gastar o SSD.

if [[ "$ONLINE" != 1 ]]; then pular "Memória (zram/earlyoom)" "sem internet"; return 0; fi

instalar_lista "zram e earlyoom" zram-tools earlyoom

passo "Configurar zram (zstd, ${ZRAM_PORCENTAGEM}% da RAM)" escrever_root /etc/default/zramswap <<CONF
# Gerado pelo Ubuntu-Mac
ALGO=zstd
PERCENT=$ZRAM_PORCENTAGEM
PRIORITY=100
CONF

passo "Ajustar kernel para usar zram" escrever_root /etc/sysctl.d/90-ubuntu-mac-memoria.conf <<'CONF'
# Gerado pelo Ubuntu-Mac — recomendado para swap em zram
vm.swappiness = 150
vm.page-cluster = 0
vm.vfs_cache_pressure = 50
vm.dirty_background_ratio = 5
vm.dirty_ratio = 10
CONF
passo "Aplicar ajustes do kernel" sudo sysctl --system
passo "Ativar zram" ativar_servico zramswap.service

# earlyoom: se a memória acabar, fecha o programa mais pesado em vez de travar tudo.
passo "Configurar earlyoom" escrever_root /etc/default/earlyoom <<'CONF'
# Gerado pelo Ubuntu-Mac
EARLYOOM_ARGS="-m 5 -s 10 -r 3600 -n --avoid ^(Xorg|xfwm4|xfce4-session|xfce4-panel|lightdm|systemd)$ --prefer ^(firefox|Isolated|chrome|chromium)"
CONF
passo "Ativar earlyoom" ativar_servico earlyoom.service
