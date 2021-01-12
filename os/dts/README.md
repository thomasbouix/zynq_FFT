# Syntaxe Device Tree
```
label : <name>[@unit-address] {
	property = "";
};
```

- Le label permet à un phandle de faire référence à notre noeud
- Le nom défini le noeud
- L'adresse est celle du device

# Explication des phandles
Un phandle est un pointeur vers un noeud. On le définit ainsi :
```
	phandle = <&node\_label>;
```
On peut également pointer vers une des propriétés du noeud :
```
	phandle = <&node\_label N>;
```
Avec _N_ la nième propriété du noeud.
On peut enfin ajouter des propriétés dans notre phandle :
```
axi_dma_impl_1: axi_dma_impl@1 {
	compatible = "impl,axi-dma-impl";
	dmas = <&axi_dma_1 0 &axi_dma_1 1>;	// Pointe vers les deux cannaux du dma
        dma-names = "fft_tx", "fft_rx";
    };
```

# Explication du fichier user.dtsi
Le fichier user.dtsi permet alors de pointer vers nos différents dma

# Adaptation du Device Tree

```
- Dans le fichier impl/configs/zynq_zedboard_defconfig, modifier la variable 
BR2_LINUX_KERNEL_CUSTOM_DTS_PATH pour y ajouter le chemin de user.dtsi
- Relancer le zynq defconfig
```
