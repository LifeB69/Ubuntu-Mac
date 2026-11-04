# Instruções para o Claude Code (rodando no próprio MacBook)

Você está rodando **dentro** do notebook que este repositório configura. Fale com o usuário em **português do Brasil**. Ele conhece Linux; seja direto.

## Contexto

- **Máquina:** MacBook Air 7,1 (11", Early 2015). Intel Core i5-5250U (Broadwell, Intel HD 6000), **4 GB de RAM**, SSD PCIe, Wi-Fi Broadcom BCM4360 (`14e4:43a0`), webcam FaceTime HD (Broadcom 1570, PCIe), teclado US com retroiluminação.
- **Sistema:** Xubuntu 26.04 LTS (XFCE sobre X11, kernel 7.0), substituindo o macOS por completo. Atenção: o `sudo` do 26.04 é o **sudo-rs** (reimplementação em Rust); algumas opções do sudo clássico (ex.: `verifypw`) não existem nele.
- **Objetivo do usuário:** um notebook leve e estável para usar Claude Desktop e Claude Code no dia a dia.
- **O que já foi feito:** o `instalar.sh` rodou os módulos de `modulos/` (veja o `README.md`, seção "O que é configurado"). As opções estão em `config.conf`.

## Comece por aqui

1. Rode `./verificar.sh` (ou `ubuntu-mac --verificar`). Ele mostra em segundos o que está funcionando (✔) e o que não está (✘), com uma dica para cada ✘.
2. Depois leia os logs abaixo.

## Logs

`logs/ultimo/` aponta para a execução mais recente do `instalar.sh`:

- `resumo.txt`: cada passo com OK / FALHOU / PULADO / AVISO
- `falhas.txt`: só as falhas
- `instalacao.log`: a saída completa; procure pela descrição do passo
- `diagnostico.txt`: lspci, lsmod, rfkill, dkms, sensores, wakeup ACPI, bateria e erros do journal

## Tarefa 1: corrigir o que falhou

1. Leia `logs/ultimo/resumo.txt` e `falhas.txt`.
2. Para cada falha, ache a causa em `instalacao.log` e corrija.
3. **Corrija no script, não só na máquina.** Se a causa estava no módulo (nome de pacote errado, ordem, configuração), conserte o arquivo em `modulos/` ou `arquivos/` e rode de novo só aquele módulo: `./instalar.sh --somente NN`.
4. Repita até o resumo ficar sem falhas (ou só com falhas que o usuário aceitou).

## Tarefa 2: checagem no hardware real

Confira cada item. Alguns precisam do usuário (apertar teclas, fechar a tampa); peça a ele e explique o que observar.

| Item | Como verificar | Se falhar |
|---|---|---|
| Wi-Fi | `lsmod \| grep ^wl`, `nmcli device`, conectar numa rede | `dkms status`; reinstalar `broadcom-sta-dkms`; ver blacklist de `b43`/`bcma` |
| Teclado ⌘ | ⌘C/⌘V no Mousepad **e no Terminal**, ⌘Tab, ⌘Espaço, ⌘Q, ⌃⌘Q, ⌥⌘Esc (lista em `ATALHOS.md`) | `sudo keyd.rvaiya monitor` mostra o que o keyd recebe; a configuração é `arquivos/keyd-mac.conf` + `arquivos/keyd-option-mac.conf` (se `OPTION_ESQUERDO=mac`). **Depois de mudar, rode `testes/keyd/rodar.sh`** (simulador oficial do keyd, 49 casos) |
| Acentos | ⌥e a = á, ⌥n a = ã, ⌥i e = ê, ⌥c = ç (layout `us(mac)`), com o ⌥ esquerdo e o direito | `setxkbmap -query`; `/etc/default/keyboard` |
| Teclas F | F1/F2 brilho, F3 todas as janelas, F4 apps, F5/F6 luz do teclado, F7–F9 música, F10–F12 volume; ⏻ pergunta | `xev` mostra as teclas (F3 = `XF86LaunchA`, F4 = `XF86LaunchB`); luz do teclado depende do `upower` ver `smc::kbd_backlight` |
| Touchpad | rolagem natural, toque = clique, 2 dedos = botão direito, palma ignorada ao digitar | `xinput list-props`; `arquivos/touchpad.conf`; `arquivos/libinput-quirks` (necessário por causa do keyd) |
| Gestos | 3 dedos ← → (área de trabalho), ↑ (xfdashboard), ↓ (mostrar mesa), 4 dedos ← → (voltar/avançar), pinça (zoom) | `libinput-gestures-setup status`; `libinput debug-events` (usuário precisa estar no grupo `input`, vale após novo login). Confira se a pinça no **Firefox** dá zoom suave sozinha (MOZ_USE_XINPUT2=1 em /etc/environment). Se não der, tire `firefox` da exceção em `arquivos/ubuntu-mac-zoom`. Se der zoom em dobro em outro app, adicione-o à exceção |
| Suspensão | fechar a tampa, esperar 30 s, abrir. Também `systemctl suspend` | **Problema conhecido em MacBooks:** acorda sozinho logo depois de suspender. Veja `cat /proc/acpi/wakeup`; geralmente se resolve desativando `XHC1` (e às vezes `LID0`) com um serviço systemd que roda `echo XHC1 > /proc/acpi/wakeup` no boot (só se estiver `*enabled`). Crie como módulo novo |
| Áudio | alto-falantes, fone, microfone | `wpctl status`, `pavucontrol` |
| Ventoinha/temperatura | `sensors`; carga com `stress` ou compilação | ajustar `arquivos/mbpfan.conf` |
| Bateria | `sudo tlp-stat -b`, `upower -d` | `arquivos/tlp-ubuntu-mac.conf` |
| Memória | `zramctl`, `swapon --show`, `free -h` | `modulos/03-memoria.sh` |
| Webcam | `lspci -nn \| grep -i 14e4:1570` | ver Tarefa 3 |
| Bluetooth | parear um dispositivo | `bluetoothctl`, `rfkill` |
| Claude Desktop | abrir, fazer login, fechar e abrir de novo (login salvo?) | keyring: ver a doc oficial https://code.claude.com/docs/en/desktop-linux |
| Claude in Chrome | Chrome aberto com a extensão Claude logada na mesma conta; no Claude Code, `/chrome` | doc oficial: https://code.claude.com/docs/en/chrome |

## Tarefa 3: webcam FaceTime HD (ficou de fora de propósito)

Precisa do driver `facetimehd` (não existe nos repositórios do Ubuntu) e do firmware extraído do pacote da Apple:

- Firmware: https://github.com/patjak/facetimehd-firmware (`make && sudo make install`)
- Driver: https://github.com/patjak/facetimehd (instalar via DKMS para sobreviver a atualizações do kernel)

O kernel é o 7.0, então confira se o driver compila (issues e forks recentes). Se funcionar, transforme os passos num módulo `modulos/11-webcam.sh` no mesmo padrão dos outros (usando `passo`, sem parar em erro). Se não compilar, registre o motivo aqui e siga em frente: a webcam não é essencial.

## Git (para salvar as correções no GitHub)

O usuário pode ter instalado pelo **ZIP** (repositório privado). Nesse caso `~/Ubuntu-Mac` **não** é um repositório git (confira com `git -C ~/Ubuntu-Mac status`). Para poder commitar e enviar correções:

1. `sudo apt install gh` e `gh auth login` (o usuário faz o login pelo navegador).
2. Clone ao lado: `gh repo clone LifeB69/Ubuntu-Mac ~/Ubuntu-Mac.git-tmp`.
3. Mova o `.git` para a pasta atual: `mv ~/Ubuntu-Mac.git-tmp/.git ~/Ubuntu-Mac/ && rm -rf ~/Ubuntu-Mac.git-tmp`. Depois `git -C ~/Ubuntu-Mac status` mostra só as diferenças locais (a pasta `logs/` é ignorada).
4. Assim o comando `ubuntu-mac` também passa a se atualizar do GitHub sozinho.

## Regras

- **Nunca** mexa em partições, EFI, GRUB ou bootloader sem pedir ao usuário antes e explicar o risco.
- Peça antes de reiniciar ou de encerrar a sessão gráfica.
- A RAM é curta (4 GB): não instale serviços que ficam rodando sem necessidade. Prefira o que é leve.
- Toda correção permanente vai para os scripts deste repositório, para que reinstalar dê o mesmo resultado. Siga o padrão dos módulos:
  - `# DESCRICAO:` na 2ª linha
  - funções de `lib/comum.sh` (`passo`, `pular`, `aviso`, `instalar_lista`, `escrever_root`, `copiar_root`)
  - nada de `set -e`
  - idempotente: rodar duas vezes não pode quebrar nada
- Depois de mudar scripts, rode `bash -n` e, se tiver, `shellcheck`. Faça commits com mensagens claras em português. Pergunte ao usuário antes de dar `git push`.
- Ao terminar, atualize a seção "Estado atual" abaixo.
- Se acrescentar uma checagem nova (ex.: webcam, suspensão), coloque-a também no `verificar.sh`.

## Estado atual

_(preencha depois da checagem: o que funciona, o que não funciona e o que foi decidido)_

- [ ] Falhas do `instalar.sh` resolvidas
- [ ] Checagem do hardware (Tarefa 2) concluída
- [ ] Webcam (Tarefa 3) resolvida ou descartada
