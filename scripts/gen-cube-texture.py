#!/usr/bin/env python3
"""Renders the digital-rain skydome texture shown behind the 3D workspace cube.

  python scripts/gen-cube-texture.py airootfs/usr/share/matrix-os/cube-rain.png
"""
import random
import sys

import cairo

W, H, CELL = 2048, 1024, 18
GLYPHS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ@#$%&*+=<>:;|/?"
FONT = sys.argv[2] if len(sys.argv) > 2 else "monospace"

random.seed(1999)
surf = cairo.ImageSurface(cairo.FORMAT_RGB24, W, H)
cr = cairo.Context(surf)
grad = cairo.LinearGradient(0, 0, 0, H)
grad.add_color_stop_rgb(0, 0.0, 0.035, 0.012)
grad.add_color_stop_rgb(1, 0.0, 0.006, 0.002)
cr.set_source(grad)
cr.paint()
cr.select_font_face(FONT, cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)

for col in range(W // CELL):
    for _ in range(random.randint(1, 3)):  # a few streams per column
        depth = random.random()
        size = CELL * (0.6 + 0.4 * depth)
        length = random.randint(6, 34)
        head = random.randint(0, H // CELL + length)
        cr.set_font_size(size)
        for k in range(length):
            row = head - k
            if not 0 <= row < H // CELL:
                continue
            fade = (1 - k / length) * (0.25 + 0.75 * depth)
            if k == 0:
                cr.set_source_rgb(0.7 * fade, 1.0 * fade, 0.8 * fade)
            else:
                cr.set_source_rgb(0.04 * fade, 0.85 * fade, 0.3 * fade)
            x, y = col * CELL, row * CELL + CELL
            cr.save()
            cr.translate(x + CELL, y)
            cr.scale(-1, 1)
            cr.move_to(0, 0)
            cr.show_text(random.choice(GLYPHS))
            cr.restore()

surf.write_to_png(sys.argv[1])
print("wrote", sys.argv[1])
