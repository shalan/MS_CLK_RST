# Makefile for compiling and running a testbench with RTL files using VCS

# Compiler and simulation settings
PDK_ROOT ?= ""
MGMT_ROOT ?= ""


PDK ?= sky130A
VCS = vcs
VCS_FLAGS = -sverilog -debug_acc+all +define+FUNCTIONAL +define+UNIT_DELAY=\#1 +define+VCS 
RTL_FLAGS = +define+RTL_SIM
GL_FLAGS = +define+USE_POWER_PINS
TB_TOP = MS_CLK_RST_tb.v
RTL_FILES = ../hdl/rtl/*.v ../hdl/rtl/**/*.v
GL_FILES = ../hdl/gl/*.v
PDK_INCLUDES = +incdir+$(PDK_ROOT)/$(PDK)/
PDK_INCLUDES = $(PDK_ROOT)/$(PDK)/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v $(PDK_ROOT)/$(PDK)/libs.ref/sky130_fd_sc_hd/verilog/primitives.v +incdir+"\"$(PDK_ROOT)/$(PDK)/\""
TB_LOG = simulation.log
RUN_LOG = run.log
# sdf 
CORNER ?= nom-Typical
CORNER_1 = $(firstword $(subst -, ,$(CORNER)))
CORNER_2 = $(word 2,$(subst -, ,$(CORNER)))
RUN_PATH = $(CURDIR)
SDF_PATH = $(RUN_PATH)/../timing/sdf

SDF_FLAGS = $(GL_FLAGS) +define+ENABLE_SDF +define+CORNER_1="\"$(CORNER_1)\"" +define+CORNER_2="\"$(CORNER_2)\"" +define+RUN_PATH="\"$(RUN_PATH)\"" +define+SDF_PATH="\"$(SDF_PATH)\"" +neg_tchk -diag=sdf:verbose +sdfverbose
SDF_PDK_INCLUDES = $(MGMT_ROOT)/verilog/cvc-pdk/sky130_fd_sc_hd.v  $(MGMT_ROOT)/verilog/cvc-pdk/primitives_hd.v  $(MGMT_ROOT)/verilog/cvc-pdk/sky130_ef_sc_hd__decap_12.v
# Targets
all: sim

rtl: $(TB_TOP) $(RTL_FILES) $(PDK_INCLUDES)
	$(VCS) $(VCS_FLAGS) $(RTL_FLAGS)  $(PDK_INCLUDES) $(RTL_FILES)  $(TB_TOP) -o simv -l $(TB_LOG)

gl: $(TB_TOP) $(GL_FILES) $(PDK_INCLUDES)
	$(VCS) $(VCS_FLAGS) $(GL_FLAGS) $(PDK_INCLUDES) $(GL_FILES)  $(TB_TOP) -o simv -l $(TB_LOG)

sdf: $(TB_TOP) $(GL_FILES) 
	$(VCS) $(VCS_FLAGS) $(SDF_FLAGS) $(SDF_PDK_INCLUDES) $(GL_FILES)  $(TB_TOP) -o simv -l $(TB_LOG)

$(TB_TOP):
	@echo "Error: Testbench source file not found!"
	@exit 1

run: sim
	./simv > $(RUN_LOG)

clean:
	rm -rf csrc simv* ucli.key $(TB_LOG) $(RUN_LOG) *.vcd sdf.log sdfAnnotateInfo *.vpd

.PHONY: all sim run clean
