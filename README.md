# Ubuntu-Mac

Transforma um **MacBook Air 11" (Early 2015)** num notebook com **Xubuntu 26.04 LTS** já configurado, com Claude Desktop e Claude Code instalados.
Você instala o sistema, roda **um comando**, reinicia e está pronto.

| | |
|---|---|
| Máquina | MacBook Air 7,1 (11") — Intel Core i5-5250U, 4 GB RAM, Wi-Fi Broadcom BCM4360 |
| Sistema | Xubuntu 26.04.1 LTS (interface XFCE, leve) |
| Resultado | Wi-Fi, teclado de Mac (⌘ funciona), touchpad estilo Mac, bateria otimizada, memória comprimida (zram), dock, Claude Desktop e Claude Code |

---

## Como instalar

📋 **Siga o [PASSO-A-PASSO.md](PASSO-A-PASSO.md)**, que vai do backup no macOS até o Claude funcionando, com solução de problemas.

Resumo:
1. No macOS: backup → baixar o [Xubuntu 26.04.1](https://cdimage.ubuntu.com/xubuntu/releases/26.04/release/xubuntu-26.04.1-desktop-amd64.iso) → gravar no pendrive.
2. Ligar segurando **⌥** → **EFI Boot** → instalar com ✅ "software de terceiros" (é o driver do Wi-Fi). Internet pelo celular no cabo.
3. No Xubuntu, no Terminal (**Ctrl+Alt+T**):
   - repositório **público**:
     ```bash
     wget -qO- https://raw.githubusercontent.com/LifeB69/Ubuntu-Mac/main/comecar.sh | bash
     ```
   - repositório **privado**: baixe o ZIP pelo Firefox (Code → Download ZIP) e rode:
     ```bash
     cd ~/Downloads && unzip -oq Ubuntu-Mac-*.zip && bash Ubuntu-Mac-*/comecar.sh
     ```
4. Reiniciar e conferir:
   ```bash
   ubuntu-mac --verificar
   ```
5. Abrir o Claude Code no projeto (`cd ~/Ubuntu-Mac && claude`) e pedir: *"leia o CLAUDE.md e faça a checagem pós-instalação"*.

> **Sobre baixar drivers antes:** não precisa. O driver do Wi-Fi (Broadcom) **já vem dentro do pendrive do Xubuntu 26.04.1**, junto com o necessário para compilá-lo. Sem internet, o script instala o driver direto do pendrive.

---

## O que é configurado

| Módulo | O que faz |
|---|---|
| `01-sistema` | Atualiza tudo, instala ferramentas (git, curl, htop, ripgrep…) e define o fuso horário |
| `02-wifi-broadcom` | Driver `wl` do BCM4360, pela internet ou **pelo pendrive** se não houver internet |
| `03-memoria` | **zram** (swap comprimido em RAM, ~60%) e **earlyoom** (evita que o sistema congele sem memória) |
| `04-energia` | **TLP** (bateria), **thermald** (temperatura) e **mbpfan** (ventoinha do MacBook) |
| `05-teclado` | Layout US com acentos no Option direito e **⌘ funcionando como no Mac** (keyd) |
| `06-touchpad` | Rolagem natural, toque para clicar, botão direito com dois dedos, **gestos de 3 e 4 dedos e pinça para zoom** |
| `07-ajustes-mac` | TRIM do SSD, microcódigo Intel e internet do iPhone/Android via cabo |
| `08-programas` | Firefox `.deb` em português (abre bem mais rápido que o Snap), **Google Chrome** (para o Claude in Chrome), fontes, tema Arc, ícones Papirus e dock Plank |
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
| ⌥← / ⌥→ / ⌥Backspace | pular / apagar palavra (Option esquerdo) |
| ⌘[ / ⌘] | voltar / avançar (navegador, arquivos) |
| ⌘⇧3 / ⌘⇧4 | capturar a tela inteira / uma área |
| Ctrl+Alt+T | abrir o terminal |
| No terminal: ⌘⇧C / ⌘⇧V | copiar / colar |
| No terminal: **Ctrl**+C (Ctrl de verdade) | interromper o programa |
| Option direito + `'`, depois `a` | á, é, í, ó, ú |
| Option direito + ⇧ + `~`, depois `a` | ã, õ |
| Option direito + `6`, depois `e` | ê, â, ô |
| Option direito + `` ` ``, depois `a` | à |
| Option direito + `,` | ç |
| fn + F1…F12 | F1…F12 (sem fn: brilho, volume, mídia) |

### Touchpad

| Gesto | Faz |
|---|---|
| tocar com 1 dedo | clique |
| tocar ou clicar com 2 dedos | botão direito |
| tocar com 3 dedos | botão do meio (colar seleção, abrir link em nova aba) |
| arrastar com 2 dedos | rolar (rolagem natural, igual ao Mac) |
| tocar duas vezes e arrastar | arrastar janelas e arquivos |
| pinça (abrir/fechar 2 dedos) | zoom (no Firefox é suave; nos outros apps vai em passos, como ⌘+ e ⌘−) |
| 3 dedos ← → | trocar de área de trabalho |
| 3 dedos ↑ | ver todas as janelas (parecido com o Mission Control) |
| 3 dedos ↓ | mostrar a área de trabalho |
| 4 dedos ← → | voltar / avançar no navegador |

O que **não** dá para ter igual ao macOS: o "arrastar com 3 dedos" e as animações que acompanham os dedos em tempo real. No XFCE os gestos disparam a ação quando você termina o movimento.

### O Claude usando o navegador

A extensão **Claude in Chrome** (o Claude abrindo páginas, clicando e preenchendo coisas) só funciona no **Google Chrome** e em navegadores parecidos (Edge, Brave). **No Firefox não existe** versão oficial. Por isso o script instala o Chrome também. O Firefox continua sendo o navegador do dia a dia, e o Chrome só gasta memória quando está aberto.
Para ativar: abra o Chrome, instale a extensão Claude pela Chrome Web Store e entre com a mesma conta do Claude Code. O "Computer Use" (o Claude controlando o computador inteiro) ainda **não** existe no Linux.

## Rodar de novo, rodar só uma parte, logs

```bash
cd ~/Ubuntu-Mac
./instalar.sh                  # tudo de novo (é seguro repetir)
./instalar.sh --listar         # lista os módulos
./instalar.sh --somente 05 10  # só teclado e interface
./instalar.sh --pular 08       # tudo menos o módulo 08
./instalar.sh --verificar      # confere se está tudo funcionando
```

Ou, de qualquer pasta: `ubuntu-mac` (atualiza do GitHub e roda tudo), `ubuntu-mac --verificar`, `ubuntu-mac --somente 05`.

A **aparência** (módulo 10) e os **gestos** são aplicados uma vez só, para não desfazer o que você personalizar depois. Para reaplicar: `ubuntu-mac --somente 10` (ou `06`).

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
