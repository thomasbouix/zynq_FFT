VIVADO_CLI = vivado -mode batch -nojournal

VIVADO_SCRIPTS_IP_PATH = script/vivado/
VIVADO_SCRIPTS_IP      = $(shell ls -R $(VIVADO_SCRIPTS_IP_PATH) | grep tcl)
VIVADO_TARGETS_IP      = $(subst .tcl,,$(VIVADO_SCRIPTS_IP))
VIVADO_TARGETS_IP_PATH = ip_repo/
VIVADO_IP_TARGETS      = $(addprefix $(VIVADO_TARGETS_IP_PATH),$(VIVADO_TARGETS_IP))


vivado_all: $(VIVADO_IP_TARGETS)

vivado_clean:
	rm -rf $(VIVADO_TARGETS_IP_PATH) vivado*


$(VIVADO_IP_TARGETS):$(VIVADO_TARGETS_IP_PATH)%:$(VIVADO_SCRIPTS_IP_PATH)%.tcl
ifeq (, $(shell PATH=$(PATH) which vivado)) 
	$(error "No vivado found in PATH.") 
endif
	mkdir -p $(VIVADO_TARGETS_IP_PATH)
	$(VIVADO_CLI) -source $<
	rm -rf project_1.*
	rm -f vivado.log
