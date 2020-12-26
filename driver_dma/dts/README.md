# Adaptation du device tree

## dma_phandles.dtsi
'''
- Fichier implémentant un noeud par dma dans notre système (i2s, fft, vga)
- Ces noeuds sont fils du bus amba
- Ces noeud contiennent un tableau "dmas" (<> = tableau), contenant des tuples appelés "phandles"
- Ces phandles font alors référence aux channels du dma
- Chaque phandle possède également un nom, listé dans dma-names

On inclut alors ce fichier dans le fichier system-top.dts, représentant la board
(fichier top-level)
'''

