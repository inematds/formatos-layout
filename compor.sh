#!/usr/bin/env bash
# formatos-layout — monta CENA + AVATAR num dos formatos nomeados (16x9 ou 9x16). Só ffmpeg, sem GPU.
# uso: ./compor.sh --formato <nome> --aspecto 16x9|9x16 --cena cena.mp4 --avatar avatar.mp4 --saida saida.mp4 \
#        [--ss 0] [--t 10] [--trechos "0-4,30-34"] [--fim 6] [--nome "NEI MALDANER | INEMA"]
#   16x9: largo canto bolha telejornal dividido apresentador documentario
#   9x16: faixa canto bolha telejornal apresentador viral documentario
# CENA = vídeo do conteúdo já no aspecto (1920x1080 ou 1080x1920). AVATAR = vídeo 16:9 do apresentador (HeyGen 1920x1080),
# rosto perto do centro: AV_CX/AV_CY (padrão 1140/510) dizem onde fica o centro do rosto. Voz sai a -14 LUFS;
# MUSICA=arquivo.mp3 acrescenta trilha baixa com ducking. Ver FORMATOS.md.
set -euo pipefail
AQUI="$(cd "$(dirname "$0")" && pwd)"
FORMATO=""; ASP=""; CENA=""; AVATAR=""; SAIDA=""; SS=0; T=""; TRECHOS=""; FIM=6; NOME="NEI MALDANER  |  INEMA"
while [ $# -gt 0 ]; do case "$1" in
  --formato) FORMATO="$2"; shift 2;; --aspecto) ASP="$2"; shift 2;; --cena) CENA="$2"; shift 2;;
  --avatar) AVATAR="$2"; shift 2;; --saida) SAIDA="$2"; shift 2;; --ss) SS="$2"; shift 2;; --t) T="$2"; shift 2;;
  --trechos) TRECHOS="$2"; shift 2;; --fim) FIM="$2"; shift 2;; --nome) NOME="$2"; shift 2;;
  -h|--help) sed -n 2,9p "$0"; exit 0;; *) echo "opção desconhecida: $1" >&2; exit 2;; esac; done
[ -n "$FORMATO" ] && [ -n "$ASP" ] && [ -s "$CENA" ] && [ -s "$AVATAR" ] && [ -n "$SAIDA" ] || { sed -n 2,9p "$0"; exit 2; }
case "$ASP:$FORMATO" in
  16x9:largo|16x9:canto|16x9:bolha|16x9:telejornal|16x9:dividido|16x9:apresentador|16x9:documentario) W=1920; H=1080;;
  9x16:faixa|9x16:canto|9x16:bolha|9x16:telejornal|9x16:apresentador|9x16:viral|9x16:documentario) W=1080; H=1920;;
  *) echo "formato '$FORMATO' não existe em $ASP (ver FORMATOS.md)" >&2; exit 2;; esac

CX=${AV_CX:-1140}; CY=${AV_CY:-510}
AMB="0xE2A23B@1"; FUNDO="0x0c0c10"
FONTE="$HOME/.local/share/fonts/Montserrat-ExtraBold.ttf"; [ -s "$FONTE" ] || FONTE=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf
mkdir -p "$AQUI/.cache"; TAGF="$AQUI/.cache/tag.txt"; printf '%s' "$NOME" > "$TAGF"
# duração: o que sobra do avatar depois de --ss (ou --t)
DA=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$AVATAR")
D=$(python3 -c "d=$DA-$SS; t='$T'; print(round(min(d, float(t)) if t else d, 3))")
pos(){ python3 -c "print(max(0,int($1)))"; }
# plaquinha com o nome: tag X Y LARGURA [enable]
tag(){ local en=""; [ -n "${4:-}" ] && en=":enable='$4'"
  echo "drawbox=x=$1:y=$2:w=$3:h=44:color=0x0b0f14@0.85:t=fill$en,drawbox=x=$1:y=$2:w=6:h=44:color=0xff2a1f@1:t=fill$en,drawtext=fontfile=$FONTE:textfile=$TAGF:x=$(($1+18)):y=$(($2+12)):fontsize=21:fontcolor=white$en"; }
# trechos "a-b,c-d" → expressão enable do ffmpeg
expr_trechos(){ python3 - "$1" "$D" <<'PY'
import sys
D=float(sys.argv[2]); out=[]
for p in sys.argv[1].split(','):
    a,b=p.split('-'); a=float(a); b=float(b)
    out.append(f"between(t,{max(0,a)},{min(D,b)})")
print('+'.join(out))
PY
}
# apresentador em tela cheia no 9:16: recorte 860x1080 centrado no rosto sobre o próprio vídeo desfocado (vfull ENTRADA SAIDA)
vfull(){ echo "[$1]split[vf1$2][vf2$2];[vf1$2]scale=-2:1920,crop=1080:1920:$(pos "$CX*1920/1080-540"):0,boxblur=30:2,eq=brightness=-0.25[vb$2];[vf2$2]crop=860:1080:$(pos "$CX-430"):0,scale=1080:1356[vg$2];[vb$2][vg$2]overlay=0:282[$2]"; }
EXTRA=()   # entradas extras (máscara/aro da bolha)
C="[0:v]fps=30,setsar=1,scale=$W:$H[c];[1:v]fps=30,setsar=1[a0];"
BG="color=c=$FUNDO:s=${W}x$H:r=30:d=$D[bg];"
case "$ASP:$FORMATO" in
  16x9:largo)   # coluna do apresentador à direita, conteúdo nos 2/3 da esquerda
    V="[a0]crop=640:1080:$(pos "$CX-320"):0[av];[c][av]overlay=1280:0,drawbox=x=1276:y=0:w=4:h=1080:color=$AMB:t=fill,$(tag 1304 1000 330)[v]";;
  16x9:canto)   # conteúdo em tela cheia, rosto num quadro âmbar no canto de baixo
    V="[a0]crop=760:860:$(pos "$CX-380"):$(pos "$CY-430"),scale=400:453[av];[c]drawbox=x=1468:y=575:w=408:h=461:color=$AMB:t=fill[b];[b][av]overlay=1472:579,$(tag 1472 988 400)[v]";;
  9x16:canto)
    V="[a0]crop=900:1020:$(pos "$CX-450"):0,scale=400:453[av];[c]drawbox=x=636:y=1286:w=408:h=461:color=$AMB:t=fill[b];[b][av]overlay=640:1290,$(tag 640 1699 400)[v]";;
  *:bolha)      # rosto num círculo com aro âmbar
    if [ "$ASP" = 16x9 ]; then B=360; X=1500; Y=630; else B=400; X=620; Y=1230; fi
    [ -s "$AQUI/.cache/mascara-$B.png" ] || python3 "$AQUI/lib/bolha.py" $B "$AQUI/.cache"
    EXTRA=(-loop 1 -i "$AQUI/.cache/mascara-$B.png" -loop 1 -i "$AQUI/.cache/aro-$B.png")
    V="[a0]crop=720:720:$(pos "$CX-360"):$(pos "$CY-360"),scale=$B:$B,format=yuva420p[av];[2:v]format=gray[m];[av][m]alphamerge[ab];[c][3:v]overlay=$((X-8)):$((Y-8))[b];[b][ab]overlay=$X:$Y,$(tag $((X+B/2-170)) $((Y+B+18)) 340)[v]";;
  *:telejornal|*:documentario)   # conteúdo em tela cheia; o apresentador ocupa a tela nos trechos
    if [ "$FORMATO" = documentario ]; then TRECHOS="$(python3 -c "print(f'{max(0,$D-$FIM)}-$D')")"
    elif [ -z "$TRECHOS" ]; then TRECHOS="$(python3 -c "print(f'0-4,{max(0,$D-5)}-$D')")"; fi
    EN=$(expr_trechos "$TRECHOS")
    if [ "$ASP" = 16x9 ]; then AV="scale=1920:1080"; TG=$(tag 60 990 340 "$EN"); else AV=""; TG=$(tag 40 1640 390 "$EN"); fi
    if [ -n "$AV" ]; then V="[a0]$AV[av];"; else V="$(vfull a0 av);"; fi
    V="$V[c][av]overlay=0:0:enable='$EN',$TG[v]";;
  16x9:dividido)  # metade conteúdo, metade apresentador
    V="[c]crop=1280:1080:0:0,scale=960:810[cs];[bg][cs]overlay=0:135[b];[a0]crop=960:1080:$(pos "$CX-480"):0[av];[b][av]overlay=960:0,drawbox=x=958:y=0:w=4:h=1080:color=$AMB:t=fill,$(tag 990 1000 330)[v]";;
  16x9:apresentador)  # apresentador domina a tela, conteúdo num cartão à esquerda
    SH=$(pos "1520-$CX")
    V="[a0]crop=$((1920-SH)):1080:0:0[av];[bg][av]overlay=$SH:0[b];[c]scale=1040:585[cs];[b]drawbox=x=52:y=243:w=1048:h=593:color=$AMB:t=fill[b2];[b2][cs]overlay=56:247,$(tag 1360 1000 330)[v]";;
  9x16:apresentador)
    V="[a0]crop=960:1080:$(pos "$CX-480"):0,scale=1080:1215[av];[bg][av]overlay=0:705[b];[c]crop=1080:1080:0:200,scale=620:620[cs];[b]drawbox=x=226:y=146:w=628:h=628:color=$AMB:t=fill[b2];[b2][cs]overlay=230:150,$(tag 40 1700 390)[v]";;
  9x16:faixa)   # padrão explicavideos: apresentador numa faixa embaixo
    V="[a0]scale=1080:608[av];[c][av]overlay=0:1110,$(tag 28 1652 390)[v]";;
  9x16:viral)   # cortes secos a cada 2 s: conteúdo → apresentador → conteúdo → close; fecha no apresentador
    DE=$(python3 -c "print(max(0,$D-5))")
    V="[a0]split[a1][a2];$(vfull a1 aw);[a2]crop=608:1080:$(pos "$CX-304"):0,scale=1080:1920[ac];[c][aw]overlay=0:0:enable='between(mod(t,8),2,4)+gte(t,$DE)'[v1];[v1][ac]overlay=0:0:enable='between(mod(t,8),6,8)*lt(t,$DE)'[v]";;
esac
[[ "$V" == *"[bg]"* ]] && C="$C$BG"   # fundo escuro só nos formatos que usam
if [ -n "${MUSICA:-}" ]; then
  [ "$FORMATO" = bolha ] && MI=4 || MI=2   # bolha já usa as entradas 2 e 3 (máscara e aro)
  EXTRA+=(-stream_loop -1 -i "$MUSICA")
  FADE=$(python3 -c "print(max(0,$D-1.4))")
  A="[1:a]aresample=48000,loudnorm=I=-14:TP=-1.5:LRA=11,aresample=48000,asplit=2[voz][sc];[$MI:a]volume=0.2,aresample=48000[m];[m][sc]sidechaincompress=threshold=0.03:ratio=8:attack=20:release=300,afade=t=out:st=$FADE:d=1.4[md];[voz][md]amix=inputs=2:duration=first:normalize=0,alimiter=limit=0.89[a]"
else A="[1:a]aresample=48000,loudnorm=I=-14:TP=-1.5:LRA=11,aresample=48000[a]"; fi
ffmpeg -nostdin -v error -y -ss "$SS" -i "$CENA" -ss "$SS" -i "$AVATAR" "${EXTRA[@]}" -filter_complex "$C$V;$A" \
  -map "[v]" -map "[a]" -t "$D" -c:v libx264 -crf 23 -preset medium -pix_fmt yuv420p -c:a aac -b:a 160k -movflags +faststart "$SAIDA"
echo "ok $FORMATO $ASP → $SAIDA (${D}s, $(du -h "$SAIDA" | cut -f1))"
