### Ajout du package dma_driver

## Se mettre à jour

Aller sur le gitlab de M.Bresson, dans le dossier OS:
https://gitlab.com/projet_implementation_eise_2019/os

Faire la partie 1 : Instructions générales pour le build

## Récuperer le dossier

Récuperer le dossier dma_driver
Placer le dossier dans os/impl/package

## Mettre à jour les fichiers Config.in

Les fichiers Config.in permettent à Buildroot de trouver les packages, ils sont composés de chemin vers d'autres fichiers Config.in. Il y a un Config.in par étage dans l'arborescence 

# os/impl/package/dma_driver/Config.in

à jour, maintenu par Ludovic

#os/impl/package/Config.in

Créer le fichier Config.in (en plus du fichier Config.in.host déjà présent)
Ouvrir le fichier Config.in
Ecrire la ligne:
source "$BR2_EXTERNAL_IMPL_PATH/package/dma_driver/Config.in"

#os/impl/Config.in

Ouvrir le fichier Config.in
Ajouter la ligne :
source "$BR2_EXTERNAL_IMPL_PATH/package/Config.in"
(normalement la ligne :
source "$BR2_EXTERNAL_IMPL_PATH/package/Config.in.host"
est déjà présente)

## Sélectionner notre package dans Buildroot

Se placer dans le fichier os/
Lancer la commande:
make BR2_EXTERNAL=$PWD/impl O=$PWD/output -C buildroot menuconfig
Aller dans : External options
Selectionner le package "dma_driver" avec la touche espace
Sauvegarder
Quitter

## Construire le paquet

make BR2_EXTERNAL=$PWD/impl O=$PWD/output -C buildroot dma_driver-rebuild
make BR2_EXTERNAL=$PWD/impl O=$PWD/output -C buildroot 

