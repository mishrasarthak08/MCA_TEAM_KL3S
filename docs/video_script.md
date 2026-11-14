# Prototype Demonstration Video Script & Storyboard

**Project Title:** Single-Cycle MIPS Processor with Memory Interface  
**Target Video Duration:** 4 Minutes 30 Seconds (Strict Limit: < 5 Minutes)  
**Deliverable Document:** `docs/video_script.md`  
**Video Link Placeholder:** `https://youtu.be/[REPLACE_WITH_YOUR_UNLISTED_DEMO_VIDEO_ID]`

---

## Recording Guidelines for the Team

1. **Resolution & Audio:** Record screen at 1080p (1920x1080) at 30 fps or 60 fps. Use a clean microphone with noise suppression.
2. **Terminal Setup:** Use a high-contrast terminal with enlarged font (e.g. 16pt bold).
3. **Presenter Transitions:** Either have one lead presenter introduce the team members or have all 5 members record their respective sections according to the speaker tags below.
4. **Timing Discipline:** Keep each section strictly within the designated time window so the total duration remains approximately 4:30.

---

## Detailed Video Storyboard & Script

---

### [0:00 - 0:25] Section 1: Project Introduction & Objectives (Duration: 25s)
- **Speaker:** Member 1 (Lead Presenter)
- **Screen Display:** Project Title Slide: *Single-Cycle MIPS Processor with Memory Interface*, Academic Institution, Course Name, Team Roster.
- **Spoken Audio:**
  > "Hello everyone, and welcome to our final project presentation. Today, we present the design, Verilog implementation, synthesis, and verification of a genuinely functional 32-bit Single-Cycle MIPS Processor with a dedicated memory interface. Our core objective is to execute an educational subset of the MIPS32 ISA—including arithmetic, logic, immediate, memory load and store, branch, and jump operations—with single-cycle execution, modular Harvard memory separation, and complete self-checking verification."

---

### [0:25 - 0:50] Section 2: Introduction of Team Members (Duration: 25s)
- **Speaker:** Member 1 (introducing all members, or each member speaking 5s)
- **Screen Display:** Slide showing photos/names/student IDs and engineering roles of all 5 team members.
- **Spoken Audio:**
  > "Our engineering team consists of five members:  
  > - **[MEMBER 1 NAME]**, serving as System Architect and Top-Level Integration Lead.  
  > - **[MEMBER 2 NAME]**, our Control Unit and Instruction Decoder Specialist.  
  > - **[MEMBER 3 NAME]**, responsible for the Datapath, ALU, and Yosys Synthesis.  
  > - **[MEMBER 4 NAME]**, who implemented the Register File and Memory subsystems.  
  > - **[MEMBER 5 NAME]**, who built our Python Assembler and led CPU Verification."

---

### [0:50 - 1:20] Section 3: Architecture & Supported ISA (Duration: 30s)
- **Speaker:** Member 2
- **Screen Display:** Architecture Overview slide showing the supported instructions table (R-Type: ADD, SUB, AND, OR, XOR, SLT; I-Type: ADDI, LW, SW, BEQ; J-Type: J).
- **Spoken Audio:**
  > "Our processor implements a 32-bit Harvard architecture. We support 11 fundamental MIPS instructions. In R-type: ADD, SUB, AND, OR, XOR, and signed SLT. In I-type: ADDI for immediate arithmetic, Load Word and Store Word for data memory access, and Branch on Equal for conditional control flow. Finally, the J-type instruction provides unconditional jumps. Crucially, each instruction completes in exactly one clock cycle with a CPI of 1.0, and our implementation avoids complex branch delay slots for clean educational semantics."

---

### [1:20 - 1:55] Section 4: Block Diagram & Datapath Flow (Duration: 35s)
- **Speaker:** Member 3
- **Screen Display:** Displaying `docs/block_diagram.mmd` or rendered diagram showing the complete closed loop: PC $\to$ Instruction Memory $\to$ Decoder $\to$ Register File $\to$ ALU $\to$ Data Memory $\to$ Write-Back Multiplexer.
- **Spoken Audio:**
  > "Here is our complete processor block diagram. During each cycle, the Program Counter outputs the instruction address to a 256-word Instruction ROM. The instruction fields are immediately dispatched: opcode to the Main Decoder, register indices $rs$ and $rt$ to the asynchronous read ports of our 32-entry Register File, and immediate fields to the Sign Extension unit. The ALU computes arithmetic results or memory addresses, while the Branch and Jump logic evaluates branch conditions and computes the next PC in parallel. For loads, data is retrieved from Data Memory, and the Write-Back logic routes the final result back to the register file before the next clock edge."

---

### [1:55 - 2:30] Section 5: Verilog RTL Architecture & Code Walkthrough (Duration: 35s)
- **Speaker:** Member 4
- **Screen Display:** Split screen or code editor showing `rtl/mips_core.v`, `rtl/mips_decoder.v`, and `rtl/register_file.v`.
- **Spoken Audio:**
  > "Our Verilog-2001 codebase is strictly modular. In `mips_decoder.v`, all control outputs feature safe combinational defaults to eliminate unintended latches and protect architectural state against invalid opcodes. In `register_file.v`, register zero ($0) is physically hardwired to zero, and write attempts targeting $0$ are safely suppressed. Both instruction and data memories feature address alignment checks and bounds protection. In `mips_core.v`, all eleven modules are cleanly wired with separate instruction and data memory buses, making the core portable to external memory controllers."

---

### [2:30 - 3:05] Section 6: Automated Assembly & Simulation Workflow (Duration: 35s)
- **Speaker:** Member 5
- **Screen Display:** Live terminal terminal window running `make assemble` followed by `make test`.
- **Action / Command:**
  ```bash
  make assemble
  make test
  ```
- **Spoken Audio:**
  > "To verify our processor, we developed a two-pass Python assembler in `tools/assemble.py` that translates symbolic MIPS assembly with labels into machine-code hex files. By typing `make assemble`, our sample programs are compiled automatically. Then, typing `make test` executes our full regression suite across the ALU, Register File, Decoder, Memory interfaces, Branch-Jump logic, and CPU robustness. Notice that all 85 unit and integration assertions pass with zero failures."

---

### [3:05 - 3:35] Section 7: Program 1 Demo: Array Sum (Duration: 30s)
- **Speaker:** Member 5
- **Screen Display:** Terminal executing `make demo-sum`. Show output trace and final PASS assertion.
- **Action / Command:**
  ```bash
  make demo-sum
  ```
- **Spoken Audio:**
  > "Now let us demonstrate our first real benchmark: Array Sum. The data memory is initialized with the array [3, 1, 4, 1, 5]. The CPU executes a loop that traverses the array using LW, accumulates the sum in register $s0 using ADD, increments the pointer and counter, and branches with BEQ when complete. Finally, SW writes the accumulated sum into memory word 5. As seen in the console output, the simulation completes in exactly 39 clock cycles, verifying that memory address 20 holds 14, perfectly matching the theoretical sum."

---

### [3:35 - 4:05] Section 8: Program 2 Demo: Maximum Element Search (Duration: 30s)
- **Speaker:** Member 3
- **Screen Display:** Terminal executing `make demo-max`. Show output trace and final PASS assertion.
- **Action / Command:**
  ```bash
  make demo-max
  ```
- **Spoken Audio:**
  > "Next, we demonstrate Program 2: Maximum Element Search. We initialize data memory with [7, 2, 11, 4, 9]. The processor loads the first element as the initial candidate, loops through the remaining elements using signed SLT comparisons, and uses conditional branches to update the maximum in register $s0. At cycle 16, when 11 is encountered, the candidate updates, while subsequent smaller values like 4 and 9 are bypassed. At cycle 36, the maximum is stored to memory word 5. The self-checking testbench confirms that memory location 20 contains 11, completing in 39 cycles."

---

### [4:05 - 4:25] Section 9: Waveform & Synthesis Results (Duration: 20s)
- **Speaker:** Member 1
- **Screen Display:** Show GTKWave displaying `mips_cpu_array_sum.vcd` with signal groups (`current_pc`, `instruction`, `alu_result`, `dmem_write`), followed by a brief view of `reports/synthesis_report.md`.
- **Spoken Audio:**
  > "Inspecting our GTKWave waveforms, we observe clean, single-cycle transitions without hazards. In Yosys synthesis, our `mips_core` synthesized into 9,002 generic cells, including 1,024 flip-flops and zero latches, confirming complete hardware synthesizability for FPGA deployment."

---

### [4:25 - 4:30] Section 10: Conclusion (Duration: 5s)
- **Speaker:** Member 1
- **Screen Display:** Concluding slide showing GitHub Repository URL and IEEE Report link.
- **Spoken Audio:**
  > "Thank you for your time. All RTL source code, testbenches, assemblers, synthesis reports, and the IEEE project report are fully accessible in our GitHub repository."

---

## Pre-Recording Checklist

- [ ] All 5 members confirmed their names and assigned speaking segments.
- [ ] Terminal environment verified: `iverilog`, `vvp`, `python3`, `yosys` functional.
- [ ] Screen recorder tested with audio levels balanced.
- [ ] Command `make test`, `make demo-sum`, and `make demo-max` tested from clean state.
- [ ] GTKWave layout saved and verified (`waveforms/mips_cpu.gtkw`).
- [ ] Timer running during rehearsal to guarantee total duration $\le$ 4 minutes 30 seconds.
- [ ] Video uploaded to YouTube / Google Drive with view permissions set to "Unlisted" or "Public".
- [ ] Link added to `README.md`, `docs/video_script.md`, and `report/main.tex`.
