# Passo a passo: Ubuntu no MacBook Air 11" (2015)

Guia completo para trocar o macOS pelo **Xubuntu 26.04** já configurado, com Claude Desktop e Claude Code.
**Abra este guia no celular**, porque o Mac vai ser apagado no meio do caminho.

**Tempo total:** cerca de 2 horas, quase todo esperando barra de progresso.

**O que você precisa:**

- [ ] Pendrive de **8 GB ou mais**. Ele será apagado.
- [ ] **Carregador** do Mac, ligado na tomada o tempo todo.
- [ ] **Cabo USB do celular** (o MacBook Air 2015 tem USB-A normal).
- [ ] Senha do Wi-Fi de casa.
- [ ] Internet para baixar cerca de **3 GB**: 5 GB do sistema no passo A3, mais uns 2 a 3 GB de atualizações e programas no passo C. Se puder, use Wi-Fi em vez dos dados do celular.

---

## Parte A — No macOS (antes de apagar)

### A1. Backup
A instalação **apaga o disco inteiro**. Copie para a nuvem ou para um HD externo:
documentos, fotos, downloads, área de trabalho, favoritos e senhas do navegador.
Confira que o backup abre em outro aparelho antes de seguir.

> Arrependeu depois? Dá para voltar ao macOS a qualquer momento: veja **F7** no final.

### A2. Repositório público ou privado?
O comando que configura tudo baixa os scripts do GitHub (`LifeB69/Ubuntu-Mac`).

- **Público (mais fácil):** no GitHub, abra o repositório → **Settings → General → Danger Zone → Change visibility → Public**. Não há senhas nem nada pessoal nele.
- **Privado:** sem problema. No passo C3 você baixa o ZIP pelo navegador, já logado no GitHub.

### A3. Baixar o Xubuntu
Baixe pelo navegador (cerca de 5 GB):
https://cdimage.ubuntu.com/xubuntu/releases/26.04/release/xubuntu-26.04.1-desktop-amd64.iso

### A4. Conferir se o arquivo veio inteiro
Abra o **Terminal** (⌘Espaço → "Terminal") e rode:

```bash
shasum -a 256 ~/Downloads/xubuntu-26.04.1-desktop-amd64.iso
```

O resultado **tem que ser exatamente**:
`0cd5160f72ae6b7a26be7a29248b60cbd579b9e6aa8fbd274e95264da0ade43d`

Se for diferente, apague o arquivo e baixe de novo.

### A5. Gravar o pendrive
1. Baixe e instale o **balenaEtcher**: https://etcher.balena.io/ (versão para macOS; ele exige macOS 11 ou mais novo, e o seu Monterey 12 atende)
   (se o macOS bloquear: **Preferências do Sistema → Segurança e Privacidade → Abrir Mesmo Assim**)
2. Abra o Etcher → **Flash from file** → escolha o `.iso` → **Select target** → escolha o **pendrive** (confira o tamanho, para não escolher outro disco) → **Flash!**
3. Ele pede a senha do Mac. Espere terminar o "Validating". Se o macOS disser que "o disco não pode ser lido", clique em **Ejetar**. Isso é normal.

<details>
<summary>Sem o Etcher (pelo Terminal)</summary>

```bash
diskutil list
```
Ache o pendrive pelo tamanho (ex.: `/dev/disk2`). **Errar o número apaga o disco errado.**
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
3. Escolha o ícone amarelo **EFI Boot** e aperte Enter.
4. No menu preto, escolha **Try or Install Xubuntu**.

### B2. Internet pelo celular
O Wi-Fi do Mac **ainda não funciona** nesta etapa (falta o driver). Use o cabo:
- **Android:** conecte o cabo → **Configurações → Rede e Internet → Ponto de acesso → Ancoragem USB**
- **iPhone:** conecte o cabo → toque em **Confiar** → **Ajustes → Acesso Pessoal → Permitir que outros acessem**

No canto superior direito deve aparecer o ícone de rede **com fio**.

> **Dica:** dá para testar antes de apagar. No começo do instalador, escolha **Experimentar o Xubuntu** e confira se teclado, touchpad, som e tela funcionam. Para instalar depois, use o ícone **Instalar Xubuntu** na área de trabalho.

### B3. O instalador, tela por tela

| Tela | O que escolher |
|---|---|
| Idioma | **Português (Brasil)** |
| Acessibilidade | Próximo |
| Teclado | **English (US)** / **English (US)** (o script ajusta os acentos depois) |
| Internet | **Usar conexão com fio** (é o celular) |
| Atualizar o instalador | Se aparecer, pode pular |
| Tipo de instalação | **Instalação interativa** |
| Aplicativos | **Seleção padrão** |
| Software adicional | ✅ **Instalar software de terceiros para placas gráficas e Wi-Fi**: **marque!** É o driver do Wi-Fi. ✅ Formatos de mídia (opcional) |
| Como instalar | **Apagar o disco e instalar o Xubuntu**. Confirme que apaga tudo. Não precisa de criptografia. |
| Conta | Seu nome, nome do computador, **usuário em minúsculas** e uma senha que você **não vai esquecer** (o `sudo` pede ela) |
| Fuso horário | **São Paulo** (ou o seu) |
| Revisar | **Instalar** |

A instalação leva de 15 a 30 minutos.

### B4. Reiniciar
Clique em **Reiniciar agora**. Quando pedir, **tire o pendrive** e aperte Enter.
**Guarde o pendrive.** Ele serve de reserva para o driver do Wi-Fi (veja F3).

> Se o Mac não iniciar no Ubuntu sozinho, ligue segurando **⌥** e escolha **EFI Boot** (agora o do disco interno). Depois de entrar, o próximo boot costuma ir direto.

---

## Parte C — O comando que configura tudo

### C1. Entrar e conectar
1. Entre com a sua senha.
2. Clique no ícone de rede (canto superior direito):
   - Se aparecerem **redes Wi-Fi**, conecte na de casa. É melhor que os dados do celular.
   - Se não aparecer nenhuma, continue com o **celular no cabo**. O script instala o Wi-Fi.

> **Espere uns 5 minutos depois do primeiro login antes do próximo passo.** Nesse tempo o Ubuntu termina a preparação inicial e baixa atualizações em segundo plano. Se você rodar antes, não tem problema: o script espera. Só demora mais.

### C2. Abrir o Terminal
Aperte **Ctrl+Alt+T** (ou Menu → Terminal).

### C3. Rodar o comando
**Se o repositório é público**, digite (ou copie e cole com **Ctrl+Shift+V**):

```bash
wget -qO- https://raw.githubusercontent.com/LifeB69/Ubuntu-Mac/main/comecar.sh | bash
```

**Se o repositório é privado:**
1. Abra o **Firefox** → entre em **github.com** com a sua conta → abra **LifeB69/Ubuntu-Mac**.
2. Clique em **Code** (botão verde) → **Download ZIP**. O arquivo vai para **Downloads**.
3. No Terminal:

```bash
cd ~/Downloads && unzip -oq Ubuntu-Mac-*.zip && bash Ubuntu-Mac-*/comecar.sh
```

### C4. Esperar
- Ele pede a **sua senha uma vez**. Ao digitar, não aparece nada na tela; isso é normal.
- Cada passo aparece com **OK**, **FALHOU** ou **pulado**, e os passos longos mostram o tempo decorrido. A primeira parte, "Atualizar todos os pacotes", pode levar de 10 a 20 minutos.
- **Se algo falhar, ele não para:** anota o erro e segue.
- **Deixe a tampa aberta e o carregador ligado.** Leva de 20 a 40 minutos.
- Se a tela **apagar ou bloquear** no meio, é só o protetor de tela: mexa no touchpad e digite a senha. A instalação continua por trás, e o notebook não entra em suspensão enquanto ela roda.

### C5. Final
Aparece um **resumo** (OK, falhas, pulados) e a pergunta **"Reiniciar agora? [s/N]"**: digite `s` e Enter.

> Teve falhas? Rode de novo depois de reiniciar (passo D1). É seguro repetir, e muitas falhas somem na segunda vez, como as de internet que caiu ou de "dpkg ocupado".

---

## Parte D — Depois de reiniciar

### D1. Conferir se está tudo certo
Abra o Terminal (**Ctrl+Alt+T**) e rode:

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
1. Abra o **Google Chrome** (Menu → Internet).
2. Instale a extensão **Claude** pela Chrome Web Store e faça login com a mesma conta.
3. No Claude Code, digite `/chrome`.

(No Firefox isso não existe; o Firefox continua sendo o navegador do dia a dia.)

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

**F1. Segurando ⌥, o "EFI Boot" não aparece.**
Grave o pendrive de novo (A5), use a outra porta USB e segure ⌥ **antes** do som de inicialização.

**F2. Sem internet no instalador.**
Android: desligue e ligue a "Ancoragem USB". iPhone: desconecte, reconecte, toque em **Confiar** e deixe a tela de **Acesso Pessoal** aberta. Se não der, instale sem internet: o driver do Wi-Fi vem no pendrive.

**F3. Depois de instalar, o Wi-Fi não aparece.**
Conecte o celular no cabo e rode o comando do C3. **Sem internet nenhuma:** conecte o **pendrive do Xubuntu** e rode `~/Ubuntu-Mac/instalar.sh --somente 02`, que instala o driver direto do pendrive (para isso a pasta `~/Ubuntu-Mac` já precisa existir). Reinicie.

**F4. O comando do C3 diz "Não consegui baixar o projeto do GitHub".**
O repositório é privado: use o caminho do **ZIP** (C3, segunda opção).

**F5. "O Ubuntu-Mac já está rodando em outro terminal."**
Outra janela ainda está instalando. Espere ela terminar.

**F6. Algum passo deu FALHOU.**
Rode `ubuntu-mac` de novo. Se continuar, abra o Claude Code em `~/Ubuntu-Mac` e peça "leia logs/ultimo e resolva as falhas". Os detalhes ficam em `~/Ubuntu-Mac/logs/ultimo/`.

**F7. Quero o macOS de volta.**
Desligue, ligue segurando **⌥ ⌘ R** (Recuperação pela Internet, precisa de Wi-Fi) → **Utilitário de Disco**: apague o disco interno (formato APFS) → **Reinstalar o macOS**.

---

## Checklist

- [ ] A1 Backup conferido
- [ ] A2 Repositório público ou ZIP combinado
- [ ] A3/A4 ISO baixada e conferida (`0cd5160f…`)
- [ ] A5 Pendrive gravado
- [ ] B1–B4 Xubuntu instalado, com ✅ software de terceiros
- [ ] C1–C5 Comando rodado e computador reiniciado
- [ ] D1 `ubuntu-mac --verificar` sem ✘
- [ ] D2 Claude Desktop logado
- [ ] D3 Claude Code fez a checagem pós-instalação
