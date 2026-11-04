#!/usr/bin/env bash
# Testa a configuração do teclado (arquivos/keyd-*.conf) no simulador oficial do keyd,
# sem precisar de teclado nem de reiniciar nada.
#
#   testes/keyd/rodar.sh            confere todos os casos
#   testes/keyd/rodar.sh --gerar    regrava as saídas esperadas (depois de revisar!)
#
# Cada linha de casos-*.txt:  nome | teclas apertadas | saída esperada
# Na saída, "+tecla" = apertou e "-tecla" = soltou (o que os programas recebem).
# Precisa de: git, gcc. Baixa o keyd 2.5.0 (mesma versão do Ubuntu 26.04) para ~/.cache.

set -uo pipefail
AQUI="$(cd "$(dirname "$0")" && pwd)"
ARQ="$AQUI/../../arquivos"
VERSAO=v2.5.0
COMMIT=f33dca879a3f871ee2e0fa9c1efd6e8dabb21ed3
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/ubuntu-mac/keyd-$VERSAO"
GERAR=0; [[ "${1:-}" == --gerar ]] && GERAR=1

if [[ ! -x "$CACHE/bin/test-io" ]]; then
  echo "Preparando o simulador do keyd $VERSAO..."
  mkdir -p "$(dirname "$CACHE")"
  [[ -d "$CACHE/.git" ]] || git -c advice.detachedHead=false clone -q --depth 1 --branch "$VERSAO" https://github.com/rvaiya/keyd "$CACHE" || exit 1
  [[ "$(git -C "$CACHE" rev-parse HEAD)" == "$COMMIT" ]] || { echo "Commit inesperado do keyd; abortando."; exit 1; }
  mkdir -p "$CACHE/bin"
  (cd "$CACHE" && gcc -DDATA_DIR= -o bin/test-io t/test-io.c src/keyboard.c src/string.c \
     src/macro.c src/config.c src/log.c src/ini.c src/keys.c src/unicode.c) || exit 1
fi
SIM="$CACHE/bin/test-io"

tmp="$(mktemp -d)"; trap 'rm -rf -- "$tmp"' EXIT
cat "$ARQ/keyd-mac.conf" "$ARQ/keyd-option-mac.conf" >"$tmp/mac.conf"
cp "$ARQ/keyd-mac.conf" "$tmp/alt.conf"

# saída do simulador -> "+a -a ..."
compacto() { sed 's/\x1b\[[0-9;]*m//g' | grep -E ' (down|up)$' | sed 's/^ *//' |
  awk '{printf "%s%s ", ($2=="down"?"+":"-"), $1} END{print ""}' | sed 's/ $//'; }

ok=0 falhas=0
for modo in mac alt; do
  casos="$AQUI/casos-$modo.txt"
  novo="$tmp/casos-$modo.txt"
  while IFS= read -r linha; do
    if [[ -z "$linha" || "$linha" == \#* ]]; then echo "$linha" >>"$novo"; continue; fi
    IFS='|' read -r nome teclas esperado <<<"$linha"
    { tr ';' '\n' <<<"$teclas"; echo; } >"$tmp/t.t"
    obtido="$("$SIM" "$tmp/$modo.conf" "$tmp/t.t" 2>&1 | compacto)"
    if ((GERAR)); then
      echo "$nome|$teclas|$obtido" >>"$novo"
    elif [[ "$obtido" == "$esperado" ]]; then
      ok=$((ok + 1))
    else
      falhas=$((falhas + 1))
      printf '✘ [%s] %s\n    esperado: %s\n    obtido:   %s\n' "$modo" "$nome" "$esperado" "$obtido"
    fi
  done <"$casos"
  ((GERAR)) && cp "$novo" "$casos"
done

if ((GERAR)); then echo "Saídas esperadas regravadas. Revise com: git diff testes/keyd/"; exit 0; fi
echo "Teclado: $ok casos OK, $falhas com diferença."
exit $((falhas > 0))
