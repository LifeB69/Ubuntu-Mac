# Atalhos: o teclado do MacBook Air no Ubuntu

Tudo foi feito para funcionar **como no macOS**. Teclas: ⌘ Command · ⌥ Option · ⌃ Control · ⇧ Shift · fn.
Cada combinação abaixo está coberta por um teste automático (`testes/keyd/rodar.sh`).

## Fileira de cima (teclas F)

| Tecla | Faz | Com **fn** |
|---|---|---|
| F1 / F2 | brilho da tela − / + | F1 / F2 |
| F3 | **todas as janelas** (Mission Control) | F3 |
| F4 | **aplicativos** (Launchpad) | F4 |
| F5 / F6 | luz do teclado − / + | F5 / F6 |
| F7 / F8 / F9 | música: anterior / tocar-pausar / próxima | F7 / F8 / F9 |
| F10 / F11 / F12 | mudo / volume − / volume + | F10 / F11 / F12 |
| ⏻ (canto direito) | pergunta: suspender, reiniciar ou desligar · na tela de login: suspende | — |

`fn` + ← → ↑ ↓ = Home / End / Page Up / Page Down · `fn` + ⌫ = apagar para a frente (Delete).

## ⌘ Command

| Atalho | Faz |
|---|---|
| ⌘C ⌘V ⌘X | copiar / colar / recortar: **também no Terminal** |
| ⌘⇧V | colar sem formatação |
| ⌘Z / ⌘⇧Z | desfazer / refazer |
| ⌘A ⌘S ⌘F ⌘P ⌘N ⌘O | selecionar tudo / salvar / buscar / imprimir / novo / abrir |
| ⌘T ⌘W ⌘⇧T | nova aba / fechar aba / reabrir aba |
| ⌘L ⌘R ⌘D | barra de endereço / recarregar / favoritar (navegador) |
| ⌘+ ⌘− ⌘0 | zoom + / − / normal |
| ⌘Q | fechar o aplicativo |
| ⌘H / ⌘M | esconder / minimizar a janela |
| ⌘Tab (segure ⌘) | trocar de aplicativo · ⌘⇧Tab ou ⌘\` (ainda segurando) volta |
| ⌘\` | outra janela do mesmo aplicativo |
| ⌘Espaço | buscar aplicativos (Spotlight) |
| ⌘← ⌘→ | início / fim da linha (com ⇧ seleciona) |
| ⌘↑ ⌘↓ | início / fim do documento (com ⇧ seleciona) |
| ⌘⌫ | apagar até o início da linha |
| ⌘[ ⌘] | voltar / avançar (navegador, arquivos) |
| ⌘⇧[ ⌘⇧] ou ⌘⌥← ⌘⌥→ | aba anterior / próxima |
| ⌘⇧. | mostrar arquivos ocultos (no gerenciador de arquivos) |
| ⌘⇧3 / ⌘⇧4 / ⌘⇧5 | captura: tela inteira / uma área / opções |
| ⌘F3 | mostrar a área de trabalho |
| ⌘⌥I / ⌘⌥J / ⌘⌥C | ferramentas de desenvolvedor / console / inspecionar (navegador) |
| ⌘⌥U | ver o código-fonte da página |
| ⌘⌥F | localizar e substituir |
| ⌘⌥Esc | **forçar encerrar** (depois clique na janela travada) |

## ⌃ Control

| Atalho | Faz |
|---|---|
| ⌃C | **interromper** o programa no Terminal (como no Mac) |
| ⌃← ⌃→ | área de trabalho à esquerda / direita |
| ⌃↑ | todas as janelas (igual ao F3) |
| ⌃Tab / ⌃⇧Tab | próxima / anterior aba |
| ⌃⌘Q | bloquear a tela |
| ⌃⌘F | tela cheia |
| ⌃⌘Espaço | emojis (em programas GTK, como o Editor e o Gerenciador de arquivos) |
| ⌃⌥T | abrir o Terminal |

## ⌥ Option

| Atalho | Faz |
|---|---|
| ⌥← ⌥→ | palavra anterior / próxima (com ⇧ seleciona) |
| ⌥⌫ | apagar a palavra anterior |
| ⌥Enter | nova linha sem enviar (no Claude Code) |
| ⌥Tab, ⌥F4 | continuam sendo Alt+Tab e Alt+F4 |

### Acentos e símbolos (igual ao Mac com teclado americano)

| Digite | Resultado |
|---|---|
| ⌥e e depois a / e / i / o / u | á é í ó ú |
| ⌥n e depois a / o | ã õ |
| ⌥i e depois a / e / o | â ê ô |
| ⌥\` e depois a | à |
| ⌥u e depois u | ü |
| ⌥c / ⌥⇧c | ç / Ç |
| ⌥2 ⌥3 ⌥8 ⌥g ⌥r | ™ £ • © ® |
| ⌥- / ⌥⇧- | – (meia-risca) / — (travessão) |
| ⌥[ / ⌥⇧[ | “ / ” |

Os dois ⌥ digitam acentos. Se você preferir o ⌥ **esquerdo** como Alt do Linux (atalhos Alt+letra no terminal), mude `OPTION_ESQUERDO="alt"` no `config.conf` e rode `ubuntu-mac --somente 05`. O ⌥ direito continua com os acentos.

## Touchpad

| Gesto | Faz |
|---|---|
| tocar com 1 / 2 / 3 dedos | clique / botão direito / botão do meio |
| clicar com 2 dedos | botão direito |
| 2 dedos arrastando | rolar (rolagem natural) |
| tocar duas vezes e arrastar | arrastar |
| pinça | zoom |
| 3 dedos ← → | trocar de área de trabalho |
| 3 dedos ↑ / ↓ | todas as janelas / mostrar a mesa |
| 4 dedos ← → | voltar / avançar |

## Diferenças que ficaram (e por quê)

- **⌘ não abre nada ao ser tocado sozinho**, igual ao Mac. O menu abre com ⌘Espaço ou F4.
- **⌃⌘Espaço (emojis)** só funciona em programas GTK. No Firefox, no Chrome e no Claude Desktop, use o seletor de emojis do próprio programa.
- **"Arrastar com 3 dedos"** não existe no Linux. Use tocar duas vezes e arrastar.
- **Os gestos** disparam quando o movimento termina; não acompanham os dedos como no macOS.
- **No Terminal, ⌘K, ⌘A e ⌘F** viram Ctrl+K, Ctrl+A e Ctrl+F, que são atalhos do shell (apagar até o fim da linha, ir para o início, avançar um caractere). Para buscar no terminal use ⌃⇧F.
