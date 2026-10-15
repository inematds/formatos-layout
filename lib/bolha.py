#!/usr/bin/env python3
"""Gera as duas imagens do formato Bolha: máscara circular (cinza) e aro âmbar (RGBA).
uso: bolha.py <diametro> <pasta-saida>  → mascara-<d>.png e aro-<d>.png"""
import sys
from pathlib import Path
from PIL import Image, ImageDraw

d = int(sys.argv[1]); out = Path(sys.argv[2]); out.mkdir(parents=True, exist_ok=True)
esc = 4  # desenha 4x maior e reduz: borda sem serrilhado
m = Image.new("L", (d * esc, d * esc), 0)
ImageDraw.Draw(m).ellipse((0, 0, d * esc - 1, d * esc - 1), fill=255)
m.resize((d, d), Image.LANCZOS).save(out / f"mascara-{d}.png")
aro = d + 16
a = Image.new("RGBA", (aro * esc, aro * esc), (0, 0, 0, 0))
ImageDraw.Draw(a).ellipse((0, 0, aro * esc - 1, aro * esc - 1), outline=(226, 162, 59, 255), width=8 * esc)
a.resize((aro, aro), Image.LANCZOS).save(out / f"aro-{d}.png")
