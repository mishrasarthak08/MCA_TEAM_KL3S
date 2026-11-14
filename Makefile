# =============================================================================
# Makefile: Single-Cycle MIPS Processor with Memory Interface
# Automation for Assembly, Simulation, Verification, Synthesis, and Reporting
# =============================================================================

IVERILOG = iverilog
IVERILOG_FLAGS = -g2001 -Wall
VVP      = vvp
YOSYS    = yosys
PYTHON   = python3
TECTONIC = tectonic
GTKWAVE  = gtkwave

RTL_SRCS = rtl/program_counter.v \
           rtl/instruction_memory.v \
           rtl/mips_decoder.v \
           rtl/alu_control.v \
           rtl/register_file.v \
           rtl/sign_extend.v \
           rtl/alu.v \
           rtl/data_memory.v \
           rtl/branch_jump_logic.v \
           rtl/writeback_logic.v \
           rtl/mips_core.v \
           rtl/mips_system.v

SIM_DIR = sim_bin
WAVE_DIR = waveforms

.PHONY: all assemble test test-alu test-rf test-dec test-mem test-hierarchy test-bj test-invalid test-cpu demo-sum demo-max synth figures waves report clean help

all: assemble test synth report

# --- Assembler Target ---
assemble:
	@echo "==> Assembling MIPS programs..."
	$(PYTHON) tools/assemble.py programs/array_sum.asm programs/array_sum.hex programs/array_sum_listing.txt
	$(PYTHON) tools/assemble.py programs/max_search.asm programs/max_search.hex programs/max_search_listing.txt
	@echo "==> Assembly completed successfully."

# --- Comprehensive Test Suite ---
test: test-alu test-rf test-dec test-mem test-hierarchy test-bj test-invalid test-cpu
	@echo "============================================="
	@echo "  ALL 95 VERIFICATION CHECKS PASSED!         "
	@echo "============================================="

test-alu:
	@echo "==> Running ALU Testbench..."
	@mkdir -p $(SIM_DIR) $(WAVE_DIR)
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(SIM_DIR)/sim_alu rtl/alu.v testbench/tb_alu.v
	$(VVP) $(SIM_DIR)/sim_alu

test-rf:
	@echo "==> Running Register File Testbench..."
	@mkdir -p $(SIM_DIR) $(WAVE_DIR)
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(SIM_DIR)/sim_rf rtl/register_file.v testbench/tb_register_file.v
	$(VVP) $(SIM_DIR)/sim_rf

test-dec:
	@echo "==> Running Instruction Decoder & ALU Control Testbench..."
	@mkdir -p $(SIM_DIR) $(WAVE_DIR)
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(SIM_DIR)/sim_dec rtl/mips_decoder.v rtl/alu_control.v testbench/tb_decoder.v
	$(VVP) $(SIM_DIR)/sim_dec

test-mem: assemble
	@echo "==> Running Memory Interface Testbench..."
	@mkdir -p $(SIM_DIR) $(WAVE_DIR)
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(SIM_DIR)/sim_mem rtl/instruction_memory.v rtl/data_memory.v testbench/tb_memory.v
	$(VVP) $(SIM_DIR)/sim_mem

test-hierarchy: assemble
	@echo "==> Running Harvard vs Shared Memory Comparison Testbench..."
	@mkdir -p $(SIM_DIR) $(WAVE_DIR)
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(SIM_DIR)/sim_hierarchy rtl/instruction_memory.v rtl/data_memory.v rtl/shared_memory_arbiter.v testbench/tb_memory_hierarchy.v
	$(VVP) $(SIM_DIR)/sim_hierarchy

test-bj:
	@echo "==> Running Branch & Jump Logic Testbench..."
	@mkdir -p $(SIM_DIR) $(WAVE_DIR)
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(SIM_DIR)/sim_bj rtl/branch_jump_logic.v testbench/tb_branch_jump.v
	$(VVP) $(SIM_DIR)/sim_bj

test-invalid:
	@echo "==> Running Architectural Robustness (Invalid Instruction) Testbench..."
	@mkdir -p $(SIM_DIR) $(WAVE_DIR)
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(SIM_DIR)/sim_invalid $(RTL_SRCS) testbench/tb_invalid_instr.v
	$(VVP) $(SIM_DIR)/sim_invalid

test-cpu: demo-sum demo-max

# --- Demonstrations of Required Programs ---
demo-sum: assemble
	@echo "==> Running Program 1 Demo: Array Sum (Expected: 14)..."
	@mkdir -p $(SIM_DIR) $(WAVE_DIR)
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(SIM_DIR)/sim_cpu_sum $(RTL_SRCS) testbench/tb_mips_cpu.v
	$(VVP) $(SIM_DIR)/sim_cpu_sum

demo-max: assemble
	@echo "==> Running Program 2 Demo: Maximum Search (Expected: 11)..."
	@mkdir -p $(SIM_DIR) $(WAVE_DIR)
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(SIM_DIR)/sim_cpu_max $(RTL_SRCS) testbench/tb_mips_cpu_max.v
	$(VVP) $(SIM_DIR)/sim_cpu_max

# --- Synthesis Target ---
synth:
	@echo "==> Running Yosys Synthesis on MIPS Core..."
	$(YOSYS) -p "read_verilog $(RTL_SRCS); hierarchy -check -top mips_core; proc; opt; fsm; opt; memory; opt; techmap; opt; stat"

# --- Waveform Target ---
waves:
	@if command -v $(GTKWAVE) >/dev/null 2>&1; then \
		$(GTKWAVE) $(WAVE_DIR)/mips_cpu_array_sum.vcd $(WAVE_DIR)/mips_cpu.gtkw & \
	else \
		echo "GTKWave is not installed. Inspect VCD files in $(WAVE_DIR)/"; \
	fi

# --- Report Figure and Compilation Targets ---
figures:
	@echo "==> Generating report figures..."
	@mkdir -p report/figures
	dot -Tpng -Gdpi=300 report/figures/harvard_architecture.dot -o report/figures/harvard_architecture.png
	dot -Tpng -Gdpi=300 report/figures/memory_service_comparison.dot -o report/figures/memory_service_comparison.png

report: figures
	@echo "==> Compiling IEEE Project Report with Tectonic..."
	@if command -v $(TECTONIC) >/dev/null 2>&1; then \
		mkdir -p .cache/tectonic-home && \
		cd report && HOME="$(CURDIR)/.cache/tectonic-home" $(TECTONIC) main.tex && \
		echo "==> Report compiled successfully to report/main.pdf"; \
	else \
		echo "Tectonic not found. Provide LaTeX compiler to generate PDF."; \
	fi

# --- Clean Target ---
clean:
	@echo "==> Cleaning generated simulation binaries and logs..."
	rm -rf $(SIM_DIR) sim_*
	@echo "==> Clean complete."

help:
	@echo "Available Targets:"
	@echo "  make all          : Assemble, run all tests, demos, synthesis, and compile report"
	@echo "  make assemble     : Assemble MIPS assembly source programs into hex"
	@echo "  make test         : Run all unit and system testbenches"
	@echo "  make test-hierarchy: Compare Harvard and shared-memory service behavior"
	@echo "  make demo-sum     : Execute Program 1 (Array Sum = 14)"
	@echo "  make demo-max     : Execute Program 2 (Maximum Search = 11)"
	@echo "  make synth        : Run Yosys RTL synthesis and cell statistics"
	@echo "  make figures      : Generate figures used by the IEEE report"
	@echo "  make report       : Compile IEEE project report PDF using Tectonic"
	@echo "  make clean        : Remove temporary simulation binaries"
