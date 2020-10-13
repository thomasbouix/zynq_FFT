# Penser à sourcer settings64.sh
# ==> les scripts .tcl utilisent des commandes vivado


SYNTH_FILES = $(shell find -name *.vhd | grep synth/)
SIM_FILES = $(shell find -name *.vhd | grep sim/)

# All: ghdl_all vivado_all
all : vivado_all

# include mk/ghdl.mk
include mk/vivado.mk

# clean: ghdl_clean vivado_clean
clean : vivado_clean
