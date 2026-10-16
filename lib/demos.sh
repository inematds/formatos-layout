#!/usr/bin/env bash
# demos.sh — refaz os 20 demos do guia, cada formato com um evento diferente dos shorts do Eventos Extremos
# (cena + avatar de cada edição em ~/projetos/eventosextremospub/edicoes/<edição>/{build/mapa-avatar.mp4,avatar/avatar.mp4}).
# Saídas: demos/<asp>/<fmt>.mp4 (cheio), guia/assets/demos/<asp>-<fmt>.{mp4,jpg} (web + pôster),
#         guia/assets/tabela/<asp>-<fmt>.jpg (imagem da tabela "Onde o avatar aparece").
# uso: lib/demos.sh [filtro]   (filtro = trecho do nome, ex.: "9x16" ou "16x9:bolha")
set -euo pipefail
AQUI="$(cd "$(dirname "$0")/.." && pwd)"
ED="${EDICOES:-$HOME/projetos/eventosextremospub/edicoes}"
AMB="0xE2A23B"
# aspecto:formato  edição  início(s)  duração(s)
LISTA="
16x9:largo         2026-10-15-itaipu             55 10
16x9:canto         2026-10-12-mundo-clima        55 10
16x9:bolha         2026-10-10-el-nino-explicado  15 10
16x9:telejornal    2026-10-13-semana-mundo       45 14
16x9:dividido      2026-10-12-amazonia-mundo     55 10
16x9:apresentador  2026-10-15-queimadas-refeito  55 10
16x9:documentario  2026-10-15-itaipu             92 15
16x9:aula          2026-10-13-semana-mundo       95 10
9x16:faixa         2026-10-09-alerta-sul         20 10
9x16:canto         2026-10-09-alerta-norte-nordeste 22 10
9x16:bolha         2026-10-09-el-nino             8 10
9x16:telejornal    2026-10-13-semana-foto         5 14
9x16:apresentador  2026-10-13-clima-do-dia       25 10
9x16:viral         2026-10-13-24h-foto           20 16
9x16:documentario  2026-10-15-previsao-do-dia     5 14.6
9x16:metade        2026-10-15-mundo-7d            8 10
9x16:invertido     2026-10-11-semana              8 10
9x16:pergunta      2026-10-15-ultimas-24h        15 14
9x16:empilhado     2026-10-12-amazonia-reel      20 10
9x16:personagem    2026-10-15-queimadas-reel      5 10
"
# momentos da imagem da tabela (conteúdo → avatar) e do pôster, por formato
momentos(){ case "$1" in
  telejornal) echo "7 2";; documentario) echo "3 $(python3 -c "print($2-2)")";; viral) echo "1 3";;
  pergunta) echo "1 5 9.5";; *) echo "4";; esac; }
quadro(){ ffmpeg -nostdin -v error -y -ss "$2" -i "$1" -frames:v 1 -q:v 3 -vf "scale=$3" "$4"; }
echo "$LISTA" | while read -r CHAVE EDI SS T; do
  [ -n "$CHAVE" ] || continue; [[ "$CHAVE" == *"${1:-}"* ]] || continue
  ASP=${CHAVE%%:*}; FMT=${CHAVE#*:}; NOME="$ASP-$FMT"
  CENA="$ED/$EDI/build/mapa-avatar.mp4"; AV="$ED/$EDI/avatar/avatar.mp4"
  CHEIO="$AQUI/demos/$ASP/$FMT.mp4"; mkdir -p "$AQUI/demos/$ASP" "$AQUI/guia/assets/demos" "$AQUI/guia/assets/tabela"
  "$AQUI/compor.sh" --formato "$FMT" --aspecto "$ASP" --cena "$CENA" --avatar "$AV" --ss "$SS" --t "$T" --saida "$CHEIO"
  if [ "$ASP" = 16x9 ]; then WEB=960:540; TAB=480:270; else WEB=540:960; TAB=270:480; fi
  ffmpeg -nostdin -v error -y -i "$CHEIO" -vf "scale=$WEB" -c:v libx264 -crf 28 -preset slow -pix_fmt yuv420p \
    -c:a aac -b:a 96k -movflags +faststart "$AQUI/guia/assets/demos/$NOME.mp4"
  read -r -a MS <<< "$(momentos "$FMT" "$T")"
  quadro "$CHEIO" "${MS[0]}" "$WEB" "$AQUI/guia/assets/demos/$NOME.jpg"
  TMP="$AQUI/.cache/tab"; mkdir -p "$TMP"; ARGS=(); FIL=""
  for i in "${!MS[@]}"; do quadro "$CHEIO" "${MS[$i]}" "$TAB" "$TMP/$i.jpg"; ARGS+=(-i "$TMP/$i.jpg"); done
  if [ ${#MS[@]} -eq 1 ]; then cp "$TMP/0.jpg" "$AQUI/guia/assets/tabela/$NOME.jpg"
  else  # quadros lado a lado com divisória âmbar de 6 px
    N=${#MS[@]}; for i in $(seq 0 $((N-1))); do
      if [ $i -lt $((N-1)) ]; then FIL+="[$i:v]pad=iw+6:ih:0:0:color=$AMB[p$i];"; else FIL+="[$i:v]null[p$i];"; fi; done
    for i in $(seq 0 $((N-1))); do FIL+="[p$i]"; done
    ffmpeg -nostdin -v error -y "${ARGS[@]}" -filter_complex "${FIL}hstack=inputs=$N" -q:v 3 "$AQUI/guia/assets/tabela/$NOME.jpg"
  fi
  echo "   web+pôster+tabela: $NOME ($EDI)"
done
