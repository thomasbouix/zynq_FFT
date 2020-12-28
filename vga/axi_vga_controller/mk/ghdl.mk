GHDL = ghdl
GHDL_SIM_TIME = 500us

GHDL_TARGETS = $(subst .vhd,,$(subst sim/,,$(SIM_FILES)))
GHDL_SIM_TARGETS = $(addsuffix .vcd,$(GHDL_TARGETS))

ghdl_all: $(GHDL_TARGETS)

ghdl_sim: $(GHDL_SIM_TARGETS)

ghdl_clean:
	$(GHDL) --clean
	rm -f work-obj93.cf *.vcd *.ghw

$(GHDL_TARGETS):%:sim/%.vhd
	$(GHDL) -i $(SYNTH_FILES) $(SIM_FILES)
	$(GHDL) -m -Wl,-no-pie $@
 
$(GHDL_SIM_TARGETS):%.vcd:% $(GHDL_TARGETS)
	./$< --stop-time=$(GHDL_SIM_TIME) --wave=$<.ghw

