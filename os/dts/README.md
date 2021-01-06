# Adaptation du device tree (depreciated)
_On n'utilise plus le phandle dans le driver DMA_
### Le fichier *dma_phandles.dtsi* 
```
- Fichier implémentant un noeud par dma dans notre système (i2s, fft, vga)
- Ces noeuds sont fils du bus amba
- Ces noeud contiennent un tableau "dmas" (<> = tableau), contenant des tuples appelés "phandles"
- Ces phandles font alors référence aux channels du dma
- Chaque phandle possède également un nom, listé dans dma-names

On inclut alors ce fichier dans le fichier system-top.dts, représentant la board
(fichier top-level)
```

### Procédure
```
- Ajouter le fichier dma_phandles.dtsi dans os/impl/board/zynq-zedboard/dts
- Ouvrir le fichier system-top.dts et inclure dma_phandles.dtsi
- Regénérer le device tree et le fsbl (voir README M.Bresson)
- Linker dma_phandles.dtsi dans os/output/build/linux-xilinx-v2018.2/arch/arm/boot/dts
- regénérer le driver 
- regénérer la distribution
```

