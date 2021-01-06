### Créer une IP Vivado ### 
Se placer dans le dossier racine du projet
sourcer /Vivado/settings64.sh :
$source $(cat path_to_settings)
importer une ip dans synth
importer un test bench (ip_tb.vhd) dans sim
modifier le script /script/vivado/ip_.tcl

make vivado_all
ouvrir un projet

### Importer l’ip ### 
settings
IP > repository > choisir le dossier de l’IP
Créer un block design
Ajouter l’IP

