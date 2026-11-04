# shellcheck shell=bash
# DESCRICAO: Driver do Wi-Fi Broadcom BCM4360 (usa o pendrive se não houver internet)

# O MacBook Air 2015 usa o chip Broadcom BCM4360 (ID 14e4:43a0), que só funciona
# com o driver proprietário "wl" (pacote broadcom-sta-dkms). O próprio pendrive
# do Xubuntu 26.04.1 já traz esse pacote em pool/restricted/b/broadcom-sta/.

if ! lspci -nn | contem -i '14e4:43a0'; then
  aviso "Chip BCM4360 não encontrado (lspci). Seguindo mesmo assim."
fi

wl_funcionando() { lsmod | contem '^wl ' && nmcli -t -f TYPE device 2>/dev/null | contem -x wifi; }

if wl_funcionando && pacote_instalado broadcom-sta-dkms; then
  pular "Driver Wi-Fi" "já instalado e funcionando"
  return 0
fi

# Monta o pendrive do Xubuntu se ele estiver conectado mas não montado.
montar_pendrive() {
  local dev
  for dev in $(lsblk -rpno NAME,FSTYPE 2>/dev/null | awk '$2=="iso9660"{print $1}'); do
    findmnt -rn -S "$dev" >/dev/null 2>&1 && continue
    udisksctl mount --no-user-interaction -b "$dev" 2>&1 || true
  done
}

instalar_do_pendrive() {
  montar_pendrive
  local pool
  pool="$(find /cdrom /media/"$USER" /run/media/"$USER" -maxdepth 6 -type d \
          -path '*pool/restricted/b/broadcom-sta' 2>/dev/null | head -n1)"
  [[ -n "$pool" ]] || { echo "Pendrive do Xubuntu não encontrado. Conecte-o e rode de novo."; return 1; }
  local raiz="${pool%/restricted/b/broadcom-sta}"
  echo "Usando pacotes do pendrive em: $raiz"
  # dkms, gcc, make e os headers do kernel já vêm instalados no Xubuntu;
  # se faltar o dkms, pega do pendrive também.
  local debs=()
  pacote_instalado dkms || debs+=("$raiz"/main/d/dkms/dkms_*.deb)
  debs+=("$pool"/broadcom-sta-dkms_*.deb)
  sudo apt-get "${APT_OPTS[@]}" install "${debs[@]}"
}

if [[ "$ONLINE" == 1 ]]; then
  passo "Instalar driver Wi-Fi (internet)" apt_instalar broadcom-sta-dkms ||
    passo "Instalar driver Wi-Fi (pendrive)" instalar_do_pendrive
else
  passo "Instalar driver Wi-Fi (pendrive)" instalar_do_pendrive
fi

# Drivers livres que "pegam" o chip antes do wl e impedem o Wi-Fi de funcionar.
# (O pacote já faz isso; este arquivo garante, mesmo se o pacote mudar.)
passo "Bloquear drivers que conflitam com o wl" escrever_root /etc/modprobe.d/ubuntu-mac-broadcom.conf <<'CONF'
# Gerado pelo Ubuntu-Mac — o BCM4360 do MacBook Air só funciona com o driver "wl".
blacklist b43
blacklist b43legacy
blacklist ssb
blacklist bcma
blacklist brcmsmac
blacklist brcmfmac
CONF

carregar_wl() {
  sudo modprobe -r b43 b43legacy bcma ssb brcmsmac brcmfmac 2>/dev/null
  sudo modprobe wl
}
passo "Carregar o driver wl" carregar_wl
passo "Desbloquear rádios (rfkill)" sudo rfkill unblock all

sleep 5
if wl_funcionando; then
  log "Wi-Fi pronto. Conecte-se pelo ícone de rede no canto superior direito."
else
  aviso "O driver foi instalado mas o Wi-Fi ainda não apareceu. Reinicie e confira; se continuar, veja 'dkms status' no diagnóstico."
fi
