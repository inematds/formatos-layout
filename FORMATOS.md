# Catálogo de formatos

Cada formato tem um **nome fixo**. Para pedir um vídeo num formato, basta dizer o nome e o aspecto:
"monta no **Bolha 16:9**", "faz em **Telejornal 9:16**".

Todos saem do mesmo par de entradas:

- **cena**: o vídeo do conteúdo (mapa, gráficos, prints, fotos), já no aspecto final (1920×1080 ou 1080×1920);
- **avatar**: o vídeo 16:9 do apresentador (HeyGen 1920×1080), com a voz.

```bash
./compor.sh --formato <nome> --aspecto 16x9|9x16 --cena cena.mp4 --avatar avatar.mp4 --saida saida.mp4
```

Opções: `--ss` / `--t` (trecho), `--trechos "0-4,30-34"` (Telejornal), `--fim 6` (Documentário),
`--nome "NEI MALDANER | INEMA"` (plaquinha), `MUSICA=trilha.mp3` (trilha baixa com ducking),
`AV_CX` / `AV_CY` (centro do rosto no avatar; padrão 1140/510).
A voz sai sempre em −14 LUFS.

## Onde o avatar aparece

Uma imagem real de cada formato. Nos que alternam (Telejornal, Documentário, Viral), a imagem mostra os dois momentos: conteúdo à esquerda, avatar à direita.

| Imagem | Formato | Onde o avatar aparece | Tamanho | Quando aparece |
|---|---|---|---|---|
| <img src="guia/assets/tabela/16x9-largo.jpg" width="260"> | **Largo** 16:9 | coluna à direita, ao lado do conteúdo | 640×1080 (1/3 da tela) | o vídeo todo |
| <img src="guia/assets/tabela/16x9-canto.jpg" width="260"> | **Canto** 16:9 | quadro âmbar no canto de baixo à direita, sobre o conteúdo | 400×453 | o vídeo todo |
| <img src="guia/assets/tabela/16x9-bolha.jpg" width="260"> | **Bolha** 16:9 | círculo com aro âmbar no canto de baixo à direita | Ø 360 px | o vídeo todo |
| <img src="guia/assets/tabela/16x9-telejornal.jpg" width="260"> | **Telejornal** 16:9 | tela inteira, no lugar do conteúdo | 1920×1080 | só nos trechos escolhidos (padrão: 4 s no início e 5 s no fim) |
| <img src="guia/assets/tabela/16x9-dividido.jpg" width="260"> | **Dividido** 16:9 | metade direita da tela | 960×1080 (1/2) | o vídeo todo |
| <img src="guia/assets/tabela/16x9-apresentador.jpg" width="260"> | **Apresentador** 16:9 | tela inteira ao fundo, deslocado à direita; conteúdo num cartão à esquerda | 1920×1080 (cartão 1040×585) | o vídeo todo |
| <img src="guia/assets/tabela/16x9-documentario.jpg" width="260"> | **Documentário** 16:9 | tela inteira, só no fechamento | 1920×1080 | só nos últimos segundos (padrão 6 s, --fim) |
| <img src="guia/assets/tabela/9x16-faixa.jpg" height="160"> | **Faixa** 9:16 | faixa horizontal na parte de baixo, abaixo do conteúdo | 1080×608 | o vídeo todo |
| <img src="guia/assets/tabela/9x16-canto.jpg" height="160"> | **Canto** 9:16 | quadro âmbar embaixo à direita, sobre o conteúdo | 400×453 | o vídeo todo |
| <img src="guia/assets/tabela/9x16-bolha.jpg" height="160"> | **Bolha** 9:16 | círculo com aro âmbar embaixo à direita | Ø 400 px | o vídeo todo |
| <img src="guia/assets/tabela/9x16-telejornal.jpg" height="160"> | **Telejornal** 9:16 | tela inteira (rosto centrado sobre fundo desfocado) | 1080×1920 | só nos trechos escolhidos (padrão: 4 s no início e 5 s no fim) |
| <img src="guia/assets/tabela/9x16-apresentador.jpg" height="160"> | **Apresentador** 9:16 | metade de baixo, grande; conteúdo num cartão quadrado em cima | 1080×1215 (cartão 620×620) | o vídeo todo |
| <img src="guia/assets/tabela/9x16-viral.jpg" height="160"> | **Viral** 9:16 | tela inteira, alternando com o conteúdo (normal e close) | 1080×1920 | a cada 2 s (conteúdo → avatar → conteúdo → close); os últimos 5 s inteiros |
| <img src="guia/assets/tabela/9x16-documentario.jpg" height="160"> | **Documentário** 9:16 | tela inteira, só no fechamento | 1080×1920 | só nos últimos segundos (padrão 6 s, --fim) |

## 16:9 (horizontal)

| Nome | Como fica | Quando usar | Exemplo |
|---|---|---|---|
| **Largo** | Conteúdo nos 2/3 da esquerda; apresentador numa coluna de 640 px à direita, com divisória âmbar | Explicativo longo com muito gráfico; o rosto fica sempre visível | `demos/16x9/largo.mp4` · Queimadas na Amazônia (lives10) |
| **Canto** | Conteúdo em tela cheia; rosto num quadro âmbar de 400×453 no canto de baixo à direita | Quando o visual é a estrela (mapa 3D, demo de tela) e o apresentador só acompanha | `demos/16x9/canto.mp4` |
| **Bolha** | Conteúdo em tela cheia; rosto num círculo de 360 px com aro âmbar | Igual ao Canto, com um ar mais leve e moderno | `demos/16x9/bolha.mp4` |
| **Telejornal** | Conteúdo em tela cheia; o apresentador ocupa a tela inteira nos trechos escolhidos (padrão: 4 s no início e 5 s no fim) | Abertura e fechamento "olho no olho", com o conteúdo inteiro no meio | `demos/16x9/telejornal.mp4` |
| **Dividido** | Metade conteúdo, metade apresentador, lado a lado | Conversa, comparação, entrevista; peso igual entre fala e conteúdo | `demos/16x9/dividido.mp4` |
| **Apresentador** | O apresentador domina a tela; o conteúdo entra num cartão âmbar à esquerda | Opinião, comentário, recado pessoal, em que o conteúdo é só apoio | `demos/16x9/apresentador.mp4` |
| **Documentário** | Só o conteúdo com a voz por cima; o apresentador aparece apenas nos últimos segundos (CTA) | Narrativa de documentário; o rosto só no fechamento | `demos/16x9/documentario.mp4` · docflow |

> **Viral não existe em 16:9.** É regra do kit de design INEMA (`inema-design/video/style.md`):
> o preset viral é só para 9:16.

## 9:16 (vertical)

| Nome | Como fica | Quando usar | Exemplo |
|---|---|---|---|
| **Faixa** | Conteúdo em cima; apresentador numa faixa 1080×608 embaixo (padrão explicavideos) | Reel explicativo com conteúdo e rosto o tempo todo | `demos/9x16/faixa.mp4` |
| **Canto** | Conteúdo em tela cheia; rosto num quadro âmbar 400×453 embaixo à direita | Reel em que o visual manda (mapa, gráfico) | `demos/9x16/canto.mp4` · Queimadas reel |
| **Bolha** | Conteúdo em tela cheia; rosto num círculo de 400 px com aro âmbar | Igual ao Canto, mais leve | `demos/9x16/bolha.mp4` |
| **Telejornal** | Conteúdo em tela cheia; o apresentador ocupa a tela nos trechos escolhidos (recorte centrado no rosto sobre fundo desfocado) | Gancho e CTA com o rosto; o meio inteiro de conteúdo | `demos/9x16/telejornal.mp4` |
| **Apresentador** | O apresentador ocupa a metade de baixo, grande; o conteúdo entra num cartão quadrado em cima | Comentário pessoal sobre um dado ou print | `demos/9x16/apresentador.mp4` |
| **Viral** | Cortes secos a cada 2 s: conteúdo → apresentador → conteúdo → close; fecha no apresentador | Short de retenção alta. Versão simples: o viral completo (carimbos, legenda palavra a palavra) é o perfil viral do explicavideos | `demos/9x16/viral.mp4` |
| **Documentário** | Só o conteúdo com a voz por cima; o apresentador aparece nos últimos segundos | Reel narrado, com o rosto só no CTA | `demos/9x16/documentario.mp4` |

## De onde veio

Os formatos Largo, Canto (9:16) e Faixa já rodavam no motor do
[eventosextremospub](https://github.com/inematds/eventosextremospub) (`motor/compor_avatar.sh`). Os outros foram
criados aqui. As demonstrações usam o vídeo "Queimadas na Amazônia" de 15/10/2026 (cena + avatar do Nei pelo estúdio HeyGen).
