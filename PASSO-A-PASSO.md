# Passo a passo: Ubuntu no MacBook Air 11" (2015)

Guia completo para trocar o macOS (e o que mais estiver no disco, como o Alpine) pelo **Xubuntu 26.04.1** já configurado, com Claude Desktop e Claude Code.
**Abra este guia no celular**, porque o Mac vai ser apagado no meio do caminho.
Há também uma **versão visual**, com etapas marcáveis e botões para copiar os comandos: [MANUAL.html](MANUAL.html).

**Tempo total:** cerca de 2 horas, quase todo esperando barra de progresso.

**O que você precisa:**

- [ ] **Pendrive USB** de 8 GB ou mais (não use cartão SD em leitor USB: o Mac costuma não reconhecê-lo na hora de ligar). Ele será apagado.
- [ ] **Carregador** do Mac, ligado na tomada o tempo todo.
- [ ] **Cabo USB do celular** (o MacBook Air 2015 tem USB-A normal).
- [ ] Senha do Wi-Fi de casa.
- [ ] Internet para baixar cerca de **8 GB** no total: 5,2 GB do sistema (passo A2, ainda no macOS) e de 2 a 3 GB de atualizações e programas (passo C). No passo C, prefira o Wi-Fi de casa aos dados do celular.

---

## Parte A — No macOS (antes de apagar)

### A1. Backup
A instalação **apaga o disco inteiro**: o macOS **e qualquer outro sistema que esteja nele (como o seu Alpine)**. Copie para a nuvem ou para um HD externo: documentos, fotos, downloads, área de trabalho, favoritos e senhas do navegador, e o que você tiver no Alpine (`/home`, configurações, scripts).
Confira se o backup abre em outro aparelho antes de seguir.

> Arrependeu depois? Dá para voltar ao macOS a qualquer momento: veja **F7** no final.

### A2. Baixar o Xubuntu

| | |
|---|---|
| **Versão** | Xubuntu 26.04.1 LTS, 64 bits (amd64) |
| **Arquivo** | `xubuntu-26.04.1-desktop-amd64.iso`, 5,2 GB |
| **Link direto** | https://cdimage.ubuntu.com/xubuntu/releases/26.04/release/xubuntu-26.04.1-desktop-amd64.iso |

### A3. Conferir se o arquivo veio inteiro
Abra o **Terminal** (⌘Espaço → "Terminal") e rode:

```bash
shasum -a 256 ~/Downloads/xubuntu-26.04.1-desktop-amd64.iso
```

O resultado **tem que ser exatamente**:
`0cd5160f72ae6b7a26be7a29248b60cbd579b9e6aa8fbd274e95264da0ade43d`

Se for diferente, apague o arquivo e baixe de novo.

### A4. Gravar o pendrive com o balenaEtcher

> ⚠️ **Use a versão 2.1.8.** A versão mais nova do Etcher (2.1.9 em diante) **não abre no macOS 12** ("requer o macOS 13.0"). A 2.1.8 é a última que funciona no seu Monterey: o próprio instalador declara mínimo macOS 11.0.

| | |
|---|---|
| **Versão** | balenaEtcher 2.1.8, para Mac Intel (x64) |
| **Arquivo** | `balenaEtcher-2.1.8-x64.dmg`, 166 MB |
| **Link direto** | https://github.com/balena-io/etcher/releases/download/v2.1.8/balenaEtcher-2.1.8-x64.dmg |

1. Se você já instalou uma versão mais nova, apague-a primeiro: **Aplicativos → balenaEtcher → Mover para o Lixo**.
2. Abra o `.dmg` baixado e arraste o **balenaEtcher** para **Aplicativos**.
3. Abra o Etcher. Se o macOS perguntar se quer abrir um app baixado da internet, clique em **Abrir**.
4. **Flash from file** → escolha o `.iso` → **Select target** → escolha o **pendrive** (confira o tamanho, para não escolher outro disco) → **Flash!**
5. Digite a senha do Mac e espere o "Validating" terminar. Se o macOS disser que "o disco não pode ser lido", clique em **Ejetar**. É normal.

<details>
<summary>Sem o Etcher (pelo Terminal)</summary>

```bash
diskutil list
```
Ache o pendrive: ele aparece como `(external, physical)`, com o tamanho dele (ex.: `/dev/disk2`). **Errar o número apaga o disco errado.**
```bash
diskutil unmountDisk /dev/disk2
```
```bash
sudo dd if=$HOME/Downloads/xubuntu-26.04.1-desktop-amd64.iso of=/dev/rdisk2 bs=4m
```
Ele não mostra progresso sozinho: aperte **Ctrl+T** para ver quanto já foi gravado. Termina em 5 a 15 minutos.
```bash
diskutil eject /dev/disk2
```
</details>

---

## Parte B — Instalar o Xubuntu

### B1. Ligar pelo pendrive
1. Desligue o Mac. Coloque o **pendrive** e o **carregador**.
2. Ligue **segurando a tecla ⌥ (Option)** até aparecerem os ícones de disco.
3. Escolha o **EFI Boot do pendrive**: o ícone **laranja/amarelo de disco externo**. O Alpine pode aparecer como outro "EFI Boot" com **ícone cinza**: esse é o disco interno, não escolha. Aperte Enter.
4. No menu preto, escolha **Try or Install Xubuntu** (se você não escolher, ele entra sozinho em 30 segundos).

> Se a tela ficar preta ou travar no logo: reinicie e, nesse menu, escolha **Xubuntu (safe graphics)**.

### B2. Internet pelo celular
O Wi-Fi do Mac **ainda não funciona** nesta etapa (falta o driver). Use o cabo:
- **iPhone:** conecte o cabo → toque em **Confiar** → **Ajustes → Acesso Pessoal → Permitir Acesso a Outros**.
- **Android Samsung:** conecte o cabo → **Configurações → Conexões → Roteador Wi-Fi e ancoragem → Ancoragem via USB**.
- **Outros Android (Motorola, Pixel…):** conecte o cabo → **Configurações → Rede e Internet → Ponto de acesso e tethering → Tethering USB**.
- Não achou? Na busca das Configurações, digite **ancoragem** ou **tethering**.

No canto superior direito do Xubuntu deve aparecer o ícone de rede **com fio**.

### B3. O instalador, tela por tela
Os nomes abaixo são os do instalador em português, conferidos na própria imagem do Xubuntu 26.04.1.

| Tela | O que escolher |
|---|---|
| **Bem-vindo** (idioma) | **Português (Brasil)** |
| **Acessibilidade** | Próximo |
| **Layout do teclado** | **English (US)** / **English (US)**. O script ajusta os acentos depois. |
| **Conecte-se a uma rede** | **Usar conexão via cabo** (é o celular) |
| **Atualização disponível** (só se aparecer) | Pode seguir sem atualizar |
| **Experimentar ou instalar o Xubuntu** | **Instalar o Xubuntu**. Quer testar teclado, touchpad e som antes? Escolha "Experimentar" e, depois, use o ícone "Instalar Xubuntu" na área de trabalho. |
| **Tipo de instalação** | **Instalação interativa** |
| **Aplicativos** | **Xubuntu Desktop** (o padrão). **Não** escolha "Xubuntu Minimal". |
| **Otimize seu computador** | ✅ **Instalar software de terceiros para gráficos e hardware Wi-Fi**: **marque!** É o driver do Wi-Fi. ✅ Formatos de mídia adicionais: opcional. |
| **Como você deseja instalar o Xubuntu?** (ele avisa que encontrou "múltiplos sistemas operacionais") | **Apagar o disco e instalar o Xubuntu**. Não use "Instale o Xubuntu juntamente com…" nem "Particionamento manual". |
| **Escolha onde instalar o Xubuntu** | Em **Selecione o disco**, escolha o **SSD interno: APPLE SSD** (121 GB no modelo de 128 GB). **Nunca o pendrive.** |
| **Criptografia e sistema de arquivos** | **Sem criptografia** (já vem marcado) → Próximo. Não precisa abrir as opções avançadas. |
| **Configurar sua conta** | Seu nome · Nome do seu computador · **Escolha um nome de usuário** (minúsculas, sem espaço) · **Escolha uma senha** que você não vai esquecer (o `sudo` pede ela) · deixe **Solicitar minha senha para entrar** marcado |
| **Selecione seu fuso horário** | **São Paulo** (ou o seu) |
| **Pronto para instalar** | Confira que diz **Apagado** para o disco APPLE SSD → **Instalar**. Leva de 15 a 30 minutos. |
| **Instalação concluída** | **Reiniciar agora** |

### B4. Reiniciar
Quando pedir, **tire o pendrive** e aperte Enter.
**Guarde o pendrive.** Ele tem o driver do Wi-Fi de reserva (veja F3).

> **Se o Mac não iniciar no Ubuntu sozinho** (aparece uma pasta com "?", ou ele só entra segurando ⌥): ele ainda está procurando o sistema antigo, que era o padrão. Faça o **reset da NVRAM**: desligue, ligue segurando **⌥ ⌘ P R** juntas por uns 20 segundos e solte. Ele passa a iniciar o Ubuntu sozinho (o reset não apaga nada do disco). Para entrar uma vez sem o reset: segure **⌥** e escolha **EFI Boot** (agora o do disco interno).

---

## Parte C — O comando que configura tudo

### C1. Entrar e conectar
1. Entre com a sua senha.
2. Clique no ícone de rede (canto superior direito):
   - Se aparecerem **redes Wi-Fi**, conecte na de casa. É melhor que os dados do celular.
   - Se não aparecer nenhuma, continue com o **celular no cabo**. O script instala o Wi-Fi.

> **Espere uns 5 minutos depois do primeiro login antes do próximo passo.** Nesse tempo o Ubuntu termina a preparação inicial e baixa atualizações em segundo plano. Se você rodar antes, não tem problema: o script espera. Só demora mais.

### C2. Abrir o Terminal
Aperte **Ctrl+Alt+T**. No teclado do Mac são as teclas **⌃ ⌥ T**.

> Até o script rodar, as teclas ainda são as do Linux: o ⌘ ainda não funciona como no Mac. Para não digitar o comando, abra este guia no **Firefox do próprio Mac** (github.com/LifeB69/Ubuntu-Mac → PASSO-A-PASSO.md), selecione o comando, copie com **Ctrl+C** (⌃C) e cole no Terminal com **Ctrl+Shift+V** (⌃⇧V).

### C3. Rodar o comando

```bash
wget -qO- https://raw.githubusercontent.com/LifeB69/Ubuntu-Mac/main/comecar.sh | bash
```

<details>
<summary>Se esse comando não funcionar: pelo ZIP</summary>

Baixe o projeto pelo Firefox:

| | |
|---|---|
| **Arquivo** | `Ubuntu-Mac-main.zip` (vai para Downloads) |
| **Link direto** | https://github.com/LifeB69/Ubuntu-Mac/archive/refs/heads/main.zip |

Depois, no Terminal:
```bash
cd ~/Downloads && unzip -oq Ubuntu-Mac-*.zip && bash Ubuntu-Mac-*/comecar.sh
```
</details>

### C4. Esperar
- Ele pede a **sua senha uma vez**. Ao digitar, não aparece nada na tela; isso é normal.
- Cada passo aparece com **OK**, **FALHOU** ou **pulado**, e os passos longos mostram o tempo decorrido. A primeira parte, "Atualizar todos os pacotes", pode levar de 10 a 20 minutos.
- **Se algo falhar, ele não para:** anota o erro e segue.
- **Deixe a tampa aberta e o carregador ligado.** Leva de 20 a 40 minutos.
- A tela não bloqueia e o notebook não entra em suspensão enquanto a instalação roda. Se a tela **apagar** (economia de energia), mexa no touchpad: a instalação continua por trás.

### C5. Final
Aparece um **resumo** (OK, falhas, pulados) e a pergunta **"Reiniciar agora? [s/N]"**: digite `s` e Enter.

> Teve falhas? Rode de novo depois de reiniciar (passo D1). É seguro repetir, e muitas falhas somem na segunda vez, como as de internet que caiu ou de "dpkg ocupado".

---

## Parte D — Depois de reiniciar

### D1. Conferir se está tudo certo
Abra o Terminal (**⌃ ⌥ T**) e rode:

```bash
ubuntu-mac --verificar
```

Ele confere Wi-Fi, memória, bateria, teclado, touchpad, gestos, programas e dock, com ✔ ou ✘ e a dica de como resolver cada ✘.
Para rodar a instalação de novo (atualiza os scripts e só refaz o que falta), basta digitar:

```bash
ubuntu-mac
```

### D2. Claude Desktop
Clique no ícone do **Claude** na dock (embaixo) → faça login.
Feche e abra de novo para confirmar que o login ficou salvo.

### D3. Claude Code: o Claude termina o ajuste fino
No Terminal:

```bash
cd ~/Ubuntu-Mac && claude
```

Faça login e peça:

> leia o CLAUDE.md e faça a checagem pós-instalação

Ele lê os logs, corrige o que falhou e testa com você o que só dá para testar no Mac de verdade: suspensão (fechar a tampa), webcam, ventoinha, gestos.

### D4. Opcional: Claude usando o navegador
1. Abra o **Google Chrome** (Menu → Internet). O script já instalou.
2. Instale a extensão **Claude** (oficial da Anthropic) e faça login com a mesma conta:
   https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn
3. No Claude Code, digite `/chrome`.

(No Firefox essa extensão não existe; o Firefox continua sendo o navegador do dia a dia.)

---

## Parte E — Teclado e touchpad

O teclado funciona **como no Mac**: ⌘C/⌘V (inclusive no Terminal), ⌘Q, ⌘Tab, ⌘Espaço, ⌥e+a = á, ⌥n+a = ã, ⌥c = ç, F3 mostra todas as janelas, F4 os aplicativos.
A lista completa, com touchpad e gestos, está em **[ATALHOS.md](ATALHOS.md)**.

Três detalhes:
- No Terminal, **⌃C** (Control) interrompe o programa e **⌘C** copia, igual ao Mac.
- A tecla **⏻** pergunta o que fazer (suspender, reiniciar ou desligar), em vez de desligar direto.
- Os **gestos** do touchpad começam a funcionar depois de reiniciar.

---

## Parte F — Se algo der errado

**F1. Segurando ⌥, o "EFI Boot" do pendrive não aparece** (só aparecem "EFI Boot" cinza e "Macintosh HD", que são o disco interno).
1. Desligue, use a **porta USB do lado esquerdo**, ligue segurando ⌥ e espere uns 15 segundos com o menu aberto.
2. Entre no macOS e confira a gravação com `diskutil list external`: tem que aparecer um disco externo com uma partição pequena chamada **EFI**. Se não aparecer, grave de novo (A4).
3. **Cartão SD em leitor USB:** muitos leitores de cartão não aparecem no menu do ⌥, mesmo gravados certo, porque o firmware do Mac não os reconhece. Use um **pendrive USB comum**.

**F2. Sem internet no instalador.**
iPhone: desconecte, reconecte, toque em **Confiar** e deixe a tela do **Acesso Pessoal** aberta. Android: desligue e ligue a ancoragem/tethering USB. Se não der, escolha "Não quero conectar à internet neste momento" e instale sem internet: o driver do Wi-Fi vem no pendrive.

**F3. Depois de instalar, o Wi-Fi não aparece.**
Conecte o celular no cabo e rode o comando do C3: o script instala o driver.
**Sem internet nenhuma:** o driver está no pendrive do Xubuntu. Conecte o pendrive, abra-o no gerenciador de arquivos (para ele ser montado) e rode no Terminal:
```bash
sudo apt install /media/$USER/*/pool/main/d/dkms/dkms_*.deb /media/$USER/*/pool/restricted/b/broadcom-sta/broadcom-sta-dkms_*.deb
```
Reinicie, conecte no Wi-Fi e siga do passo C3.

**F4. O comando do C3 diz "Não consegui baixar o projeto do GitHub".**
Confira a internet. Se continuar, use o caminho do **ZIP** (C3, "Se esse comando não funcionar").

**F5. "O Ubuntu-Mac já está rodando em outro terminal."**
Outra janela ainda está instalando. Espere ela terminar.

**F6. Algum passo deu FALHOU.**
Rode `ubuntu-mac` de novo. Se continuar, abra o Claude Code em `~/Ubuntu-Mac` e peça "leia logs/ultimo e resolva as falhas". Os detalhes ficam em `~/Ubuntu-Mac/logs/ultimo/`.

**F7. Quero o macOS de volta.**
Desligue, ligue segurando **⌥ ⌘ R** (Recuperação pela Internet, precisa de Wi-Fi) → **Utilitário de Disco**: apague o disco interno (formato APFS) → **Reinstalar o macOS**.

---

## Checklist

- [ ] A1 Backup conferido (macOS e Alpine)
- [ ] A2/A3 Xubuntu 26.04.1 baixado e conferido (`0cd5160f…`)
- [ ] A4 Pendrive gravado (balenaEtcher 2.1.8)
- [ ] B1–B4 Xubuntu instalado: Xubuntu Desktop, ✅ software de terceiros, disco APPLE SSD
- [ ] C1–C5 Comando rodado e computador reiniciado
- [ ] D1 `ubuntu-mac --verificar` sem ✘
- [ ] D2 Claude Desktop logado
- [ ] D3 Claude Code fez a checagem pós-instalação
