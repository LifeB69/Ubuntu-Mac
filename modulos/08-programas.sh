# shellcheck shell=bash
# DESCRICAO: Programas — Firefox .deb (mais leve que o Snap), fontes, tema e dock

if [[ "$ONLINE" != 1 ]]; then pular "Programas" "sem internet"; return 0; fi

instalar_lista "fontes" fonts-inter fonts-jetbrains-mono fonts-noto-color-emoji
if [[ "$TEMA_MAC" == 1 ]]; then
  instalar_lista "tema, ícones e dock" arc-theme papirus-icon-theme plank
fi

# ---------- Firefox: Snap -> .deb oficial da Mozilla ----------
# O Snap demora bastante para abrir em máquinas antigas. A Mozilla mantém um
# repositório apt oficial. Só removemos o Snap DEPOIS que o .deb instalar,
# para você nunca ficar sem navegador.
firefox_deb_ok() { dpkg-query -W -f='${Version}' firefox 2>/dev/null | grep -qv snap; }

if [[ "$FIREFOX_DEB" != 1 ]]; then
  pular "Firefox .deb" "desligado no config.conf"
elif firefox_deb_ok; then
  pular "Firefox .deb" "já instalado"
else
  adicionar_repo_mozilla() {
    local chave=/etc/apt/keyrings/packages.mozilla.org.asc
    sudo install -d -m 0755 /etc/apt/keyrings &&
      wget -qO- https://packages.mozilla.org/apt/repo-signing-key.gpg | sudo tee "$chave" >/dev/null &&
      gpg -n -q --import --import-options import-show "$chave" | grep -q 35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3 || {
        echo "Impressão digital da chave da Mozilla não confere — abortando."; sudo rm -f "$chave"; return 1; }
    echo "deb [signed-by=$chave] https://packages.mozilla.org/apt mozilla main" |
      sudo tee /etc/apt/sources.list.d/mozilla.list >/dev/null
    # Prioridade 1000: prefere o Firefox da Mozilla ao pacote de transição (Snap) do Ubuntu.
    printf 'Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000\n' |
      sudo tee /etc/apt/preferences.d/mozilla >/dev/null
    # Atualizações automáticas de segurança também para o Firefox da Mozilla.
    printf 'Unattended-Upgrade::Origins-Pattern { "origin=packages.mozilla.org"; };\n' |
      sudo tee /etc/apt/apt.conf.d/51ubuntu-mac-firefox >/dev/null
    apt_atualizar
  }
  if passo "Adicionar repositório oficial da Mozilla" adicionar_repo_mozilla &&
     passo "Instalar Firefox .deb (pt-BR)" tentar 2 sudo apt-get "${APT_OPTS[@]}" install --allow-downgrades firefox firefox-l10n-pt-br &&
     firefox_deb_ok; then
    if snap list firefox >/dev/null 2>&1; then
      passo "Remover Firefox Snap antigo" sudo timeout 600 snap remove --purge firefox
    fi
  else
    aviso "Firefox .deb não instalou; o Firefox Snap continua funcionando normalmente."
  fi
fi

# ---------- Google Chrome (para o Claude in Chrome) ----------
# A extensão Claude in Chrome (o Claude controlando o navegador) só existe para
# Chrome e navegadores Chromium. O Firefox continua sendo o navegador principal;
# o Chrome só gasta memória quando está aberto.
if [[ "$INSTALAR_CHROME" != 1 ]]; then
  pular "Google Chrome" "desligado no config.conf"
elif pacote_instalado google-chrome-stable; then
  pular "Google Chrome" "já instalado (atualiza junto com o sistema)"
else
  instalar_chrome() {
    local deb; deb="$(mktemp --suffix=.deb)"
    tentar 3 wget -qO "$deb" https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb &&
      sudo chmod 644 "$deb" &&
      tentar 2 sudo apt-get "${APT_OPTS[@]}" install "$deb"
    local rc=$?
    rm -f "$deb"
    return "$rc"
  }
  # O pacote do Chrome cadastra sozinho o repositório do Google para atualizações.
  passo "Instalar Google Chrome" instalar_chrome
fi
