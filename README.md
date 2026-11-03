# Ubuntu-Mac

Transforma um **MacBook Air 11" (Early 2015)** num notebook com **Xubuntu 26.04 LTS** já configurado, com Claude Desktop e Claude Code instalados.
Você instala o sistema, roda **um comando**, reinicia e está pronto.

| | |
|---|---|
| Máquina | MacBook Air 7,1 (11") — Intel Core i5-5250U, 4 GB RAM, Wi-Fi Broadcom BCM4360 |
| Sistema | Xubuntu 26.04.1 LTS (interface XFCE, leve) |
| Resultado | Wi-Fi, teclado de Mac (⌘ funciona), touchpad estilo Mac, bateria otimizada, memória comprimida (zram), dock, Claude Desktop e Claude Code |

---

## Passo 1 — Antes, ainda no macOS

1. **Faça backup de tudo.** A instalação **apaga o disco inteiro**.
   (Se um dia quiser o macOS de volta: ligue segurando **⌥ ⌘ R** para a *Recuperação pela Internet*.)
2. **Baixe o Xubuntu 26.04.1** (arquivo de ~4 GB):
   https://cdimage.ubuntu.com/xubuntu/releases/26.04/release/xubuntu-26.04.1-desktop-amd64.iso
3. **Confira o arquivo.** No Terminal do macOS:
   ```bash
   shasum -a 256 ~/Downloads/xubuntu-26.04.1-desktop-amd64.iso
   ```
   O resultado tem que ser:
   `0cd5160f72ae6b7a26be7a29248b60cbd579b9e6aa8fbd274e95264da0ade43d`
4. **Grave no pendrive** (8 GB ou mais, ele será apagado) com o [balenaEtcher](https://etcher.balena.io/):
   *Flash from file* → escolha o .iso → escolha o pendrive → *Flash*.

> **Sobre baixar drivers antes:** não precisa. O driver do Wi-Fi do MacBook (Broadcom) **já vem dentro do pendrive do Xubuntu 26.04.1**, junto com tudo o que é necessário para compilá-lo. Se você ficar sem internet, o script instala o driver direto do pendrive. O resto (Claude, temas etc.) precisa de internet, que você tem pelo celular via cabo. O pendrive gravado vira somente leitura, então não haveria onde guardar mais arquivos nele.

## Passo 2 — Instalar o Xubuntu

1. Coloque o pendrive, desligue o Mac e **ligue segurando a tecla ⌥ (Option)**. Escolha **EFI Boot**.
2. No menu do pendrive, escolha *Try or Install Xubuntu*.
3. **Internet pelo celular:** conecte o celular no USB do Mac e ative
   - Android: *Configurações → Rede → Ponto de acesso → Ancoragem USB*
   - iPhone: *Ajustes → Acesso Pessoal* (e toque em *Confiar* no iPhone)

   (O Wi-Fi do Mac só funciona depois do driver; durante a instalação use o cabo.)
4. No instalador:
   - Idioma: **Português (Brasil)**
   - Teclado: **English (US)**, variante **English (intl., with AltGr dead keys)** (o script ajusta isso de qualquer forma)
   - ✅ Marque **"Instalar software de terceiros para placas de vídeo e Wi-Fi"**: isso já instala o driver do Wi-Fi
   - Tipo de instalação: **Apagar disco e instalar o Xubuntu**
   - Crie seu usuário e senha
5. Ao terminar, reinicie e tire o pendrive (guarde-o: ele serve de reserva para o driver de Wi-Fi).

## Passo 3 — O comando único

Já no Xubuntu, com internet (Wi-Fi ou celular), abra o Terminal (**Ctrl+Alt+T**) e cole:

```bash
wget -qO- https://raw.githubusercontent.com/LifeB69/Ubuntu-Mac/main/comecar.sh | bash
```

Ele pede sua senha **uma vez** e faz tudo sozinho (leva de 15 a 40 minutos, dependendo da internet).
**Se algo falhar, ele não para:** anota a falha, continua o resto e mostra um resumo no final. Depois:

```bash
sudo reboot
```

> Se o repositório estiver **privado**, o comando acima não consegue baixar. Deixe-o público ou copie a pasta para o Mac e rode `./instalar.sh` de dentro dela.

## Passo 4 — Claude

- **Claude Desktop:** abra pela dock ou pelo menu e faça login.
- **Claude Code:** no terminal, rode `cd ~/Ubuntu-Mac && claude`.
  Na pasta do projeto, o Claude lê automaticamente o [`CLAUDE.md`](CLAUDE.md), que tem as instruções para **terminar a configuração direto no hardware**: testar a suspensão, a webcam, a ventoinha, corrigir o que falhou etc. Basta pedir:
  > leia o CLAUDE.md e faça a checagem pós-instalação

---

## O que é configurado

| Módulo | O que faz |
|---|---|
| `01-sistema` | Atualiza tudo, instala ferramentas (git, curl, htop, ripgrep…) e define o fuso horário |
| `02-wifi-broadcom` | Driver `wl` do BCM4360, pela internet ou **pelo pendrive** se não houver internet |
| `03-memoria` | **zram** (swap comprimido em RAM, ~60%) e **earlyoom** (evita que o sistema congele sem memória) |
| `04-energia` | **TLP** (bateria), **thermald** (temperatura) e **mbpfan** (ventoinha do MacBook) |
| `05-teclado` | Layout US com acentos no Option direito e **⌘ funcionando como no Mac** (keyd) |
| `06-touchpad` | Rolagem natural, toque para clicar e clique com dois dedos = botão direito |
| `07-ajustes-mac` | TRIM do SSD, microcódigo Intel e internet do iPhone/Android via cabo |
| `08-programas` | Firefox `.deb` em português (abre bem mais rápido que o Snap), fontes, tema Arc, ícones Papirus e dock Plank |
| `09-claude` | **Claude Desktop** (repositório oficial da Anthropic) e **Claude Code** (`claude` no terminal) |
| `10-interface` | Dock embaixo, botões das janelas à esquerda, fontes e atalhos |

As opções ficam em [`config.conf`](config.conf) (layout do teclado, ⌘ como Ctrl, Firefox, Cowork etc.).

### Atalhos de teclado

| Tecla | Faz |
|---|---|
| ⌘C / ⌘V / ⌘X / ⌘Z / ⌘A / ⌘S | copiar / colar / recortar / desfazer / tudo / salvar |
| ⌘Q / ⌘W / ⌘T | fechar app / fechar aba / nova aba |
| ⌘Tab | trocar de janela |
| ⌘ (tocar sozinho) ou ⌘Espaço | menu e busca de aplicativos |
| ⌘← / ⌘→ | início / fim da linha |
| ⌘⇧4 | capturar uma área da tela |
| Ctrl+Alt+T | abrir o terminal |
| No terminal: ⌘⇧C / ⌘⇧V | copiar / colar |
| No terminal: **Ctrl**+C (Ctrl de verdade) | interromper o programa |
| Option direito + `'`, depois `a` | á, é, í, ó, ú |
| Option direito + ⇧ + `~`, depois `a` | ã, õ |
| Option direito + `6`, depois `e` | ê, â, ô |
| Option direito + `` ` ``, depois `a` | à |
| Option direito + `,` | ç |
| fn + F1…F12 | F1…F12 (sem fn: brilho, volume, mídia) |

## Rodar de novo, rodar só uma parte, logs

```bash
cd ~/Ubuntu-Mac
./instalar.sh                  # tudo de novo (é seguro repetir)
./instalar.sh --listar         # lista os módulos
./instalar.sh --somente 05 10  # só teclado e interface
./instalar.sh --pular 08       # tudo menos o módulo 08
```

Cada execução cria `logs/<data-hora>/` (o atalho `logs/ultimo` aponta para a mais recente):

| Arquivo | Conteúdo |
|---|---|
| `resumo.txt` | cada passo com OK / FALHOU / PULADO / AVISO |
| `falhas.txt` | só o que falhou, com indicação de onde olhar |
| `instalacao.log` | a saída completa de todos os comandos |
| `diagnostico.txt` | retrato do hardware: Wi-Fi, drivers, sensores, memória, bateria, erros do sistema |

## Divisão do trabalho

- **Já pronto aqui (scripts):** tudo o que dá para decidir sem o hardware na mão: pacotes, drivers, configurações, tema e atalhos.
- **Para o Claude local (`CLAUDE.md`):** o que só dá para testar na máquina real: suspensão e tampa, webcam FaceTime HD (driver precisa ser compilado), ajuste fino da ventoinha e do touchpad, correção das falhas registradas nos logs. Cada correção que ele fizer deve voltar para os scripts, para que uma reinstalação futura já saia certa.
