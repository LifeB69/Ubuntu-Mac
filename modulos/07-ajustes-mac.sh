# shellcheck shell=bash
# DESCRICAO: Ajustes do MacBook — SSD, microcódigo Intel e internet do celular via cabo

# TRIM semanal no SSD (mantém o desempenho).
passo "Ativar TRIM semanal do SSD" ativar_servico fstrim.timer

# Internet pelo celular via cabo USB:
#  - Android: funciona direto (driver do kernel).
#  - iPhone: precisa do usbmuxd e do ipheth (o Xubuntu já traz quase tudo).
if [[ "$ONLINE" == 1 ]]; then
  instalar_lista "suporte a iPhone/Android por cabo" usbmuxd libimobiledevice-utils
else
  pular "suporte a iPhone por cabo" "sem internet"
fi

# Firmware/microcódigo da Intel (correções do processador).
if [[ "$ONLINE" == 1 ]]; then
  instalar_lista "microcódigo Intel" intel-microcode
fi
