# FALHAS

| data | o que quebrou | menor correção | prompt \| infra |
|---|---|---|---|
| 2026-10-15 | guia publicado sem os clipes (404): `.gitignore` com `demos/` também ignorava `guia/assets/demos/` | ancorar na raiz: `/demos/` | prompt |
| 2026-10-15 | `compor.sh` travou 5 min sem sair: fonte `color` sem duração + ffmpeg lendo stdin | `color=...:d=$D` só nos formatos que usam fundo + `ffmpeg -nostdin` | infra |
