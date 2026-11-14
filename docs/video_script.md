# Prototype Demonstration Video Script & Recording Storyboard

**Project Title:** Single-Cycle MIPS Processor with Memory Interface
**Target Duration:** 4 Minutes 30 Seconds (Academic Hard Limit: $\le$ 5 Minutes 00 Seconds)
**Deliverable File:** `docs/video_script.md`
**Video URL Placeholder:** `https://youtu.be/[REPLACE_WITH_YOUR_UNLISTED_DEMO_VIDEO_ID]`

---

## 1. Technical Recording Guidelines

1. **Resolution & Audio:** Record screen at 1080p (1920x1080) at 30 fps or 60 fps. Use a headset or cardioid microphone with noise suppression enabled.
2. **Terminal Appearance:** Use a dark, high-contrast terminal theme with font size enlarged to 16pt or 18pt bold for clear legibility on video.
3. **Presenter Options:** Either have one primary presenter narrate the script (introducing each group member), or have each of the five members speak during their designated segments.
4. **Pacing:** Maintain a steady, conversational delivery rate of approximately 130–140 words per minute to remain strictly within the 4:30 target.

---

## 2. Timed Storyboard & Spoken Script

---

### [0:00 - 0:25] Segment 1: Project Overview & Objectives (25s)
- **Speaker:** Member 1 (Lead Presenter)
- **Visual Cue (On Screen):** Title slide in slide presentation or browser showing project title: *Single-Cycle MIPS Processor with Memory Interface*, Course Title, Academic Term, and Team Roster.
- **Spoken Audio:**
  > "Hello everyone, and welcome to our project demonstration. Today, we present the design, Verilog-2001 implementation, synthesis, and verification of a genuinely functional 32-bit Single-Cycle MIPS processor with modular memory interfaces. Our objective is to execute an educational subset of MIPS32 instructions—including arithmetic, logical, memory load and store, conditional branch, and jump operations—with deterministic single-cycle execution, segregated Harvard memory buses, and automated self-checking verification."

---

### [0:25 - 0:50] Segment 2: Introduction of the Five Team Members (25s)
- **Speaker:** Member 1
- **Visual Cue (On Screen):** Team slide displaying the names, student IDs, and assigned engineering specializations of all five members.
- **Spoken Audio:**
  > "Our project was developed collaboratively by five team members:
  > - **[MEMBER 1 FULL NAME]** (ID: [STUDENT_ID_1]), serving as System Architect and Top-Level Integration Lead.
  > - **[MEMBER 2 FULL NAME]** (ID: [STUDENT_ID_2]), our Control Unit and Instruction Decoder Specialist.
  > - **[MEMBER 3 FULL NAME]** (ID: [STUDENT_ID_3]), responsible for the Datapath, ALU, and RTL Synthesis.
  > - **[MEMBER 4 FULL NAME]** (ID: [STUDENT_ID_4]), who developed the Register File and Memory subsystems.
  > - **[MEMBER 5 FULL NAME]** (ID: [STUDENT_ID_5]), who built our Python Assembler and led Verification."

---

### [0:50 - 1:15] Segment 3: Architecture & Supported Instruction Set (25s)
- **Speaker:** Member 2
- **Visual Cue (On Screen):** Slide displaying the Supported Instruction Set summary table (R-Type: ADD, SUB, AND, OR, XOR, SLT; I-Type: ADDI, LW, SW, BEQ; J-Type: J).
- **Spoken Audio:**
  > "Our processor microarchitecture implements an 11-instruction educational subset of MIPS32. In R-type, we support addition, subtraction, bitwise AND, OR, XOR, and signed set-on-less-than. In I-type, we provide ADDI for immediate arithmetic, Load Word and Store Word for 32-bit aligned data memory access, and Branch on Equal for conditional control flow. For unconditional branching, we implement the J-type Jump instruction. In our educational model, branch delay slots are omitted so control updates take effect immediately on the next clock cycle."

---

### [1:15 - 1:45] Segment 4: Datapath & Block Diagram Walkthrough (30s)
- **Speaker:** Member 3
- **Visual Cue (On Screen):** Full-screen display of the processor block diagram (`docs/block_diagram.mmd` or graphic diagram). Presenter highlights the path: PC $\to$ Instruction Memory $\to$ Decoder $\to$ Register File $\to$ ALU $\to$ Data Memory $\to$ Write-Back Multiplexers.
- **Spoken Audio:**
  > "Here is our complete processor block diagram. On each rising clock edge, the Program Counter supplies the byte address to a 256-word Instruction ROM. Instruction bits are decoded in parallel: opcodes go to the Main Decoder, register indices to the dual asynchronous read ports of our 32-entry Register File, and immediate fields to the Sign Extension unit. The ALU computes results or data memory addresses, while the Branch and Jump logic evaluates next-PC targets. For load instructions, data is read from Data Memory, and the write-back multiplexer selects the final word to commit into the register file."

---

### [1:45 - 2:15] Segment 5: Verilog RTL Implementation Walkthrough (30s)
- **Speaker:** Member 4
- **Visual Cue (On Screen):** Code editor (VS Code) displaying `rtl/mips_core.v`, `rtl/mips_decoder.v`, and `rtl/register_file.v`.
- **Spoken Audio:**
  > "Our Verilog-2001 codebase is strictly modular, partitioned into 12 synthesizable files. In `mips_decoder.v`, all control outputs have safe combinational defaults to eliminate latches and suppress writes on illegal opcodes. In `register_file.v`, register zero ($0) is physically hardwired to zero, and write attempts targeting $0$ are dropped. Both instruction and data memories include word-alignment checking and bounds protection. In `mips_core.v`, all modules are connected using clean buses, making the core portable to external memory systems."

---

### [2:15 - 2:45] Segment 6: Toolchain & Automated Regression Demo (30s)
- **Speaker:** Member 5
- **Visual Cue (On Screen):** Clean terminal window. Presenter runs `make assemble` followed by `make test`.
- **Terminal Commands Demonstrated:**
  ```bash
  make assemble
  make test
  ```
- **Spoken Audio:**
  > "To verify our processor, we created a custom two-pass Python assembler in `tools/assemble.py` that translates symbolic MIPS assembly programs with labels into machine-code hex files. By running `make assemble`, our programs are compiled automatically. Then, typing `make test` executes our full verification suite across the ALU, Register File, Decoder, Memory, Branch/Jump logic, and CPU robustness. All 85 self-checking assertions pass with zero failures."

---

### [2:45 - 3:15] Segment 7: Program 1 Demo: Array Sum (30s)
- **Speaker:** Member 5
- **Visual Cue (On Screen):** Terminal window executing `make demo-sum`. Show the cycle-by-cycle trace table on screen, pausing briefly on cycle 36 and the final PASS confirmation.
- **Terminal Command Demonstrated:**
  ```bash
  make demo-sum
  ```
- **Spoken Audio:**
  > "Now let us demonstrate our first real benchmark: Array Sum. Data memory is pre-loaded with the array [3, 1, 4, 1, 5]. The CPU executes an iterative loop that loads each element using LW, accumulates the sum in register $s0 using ADD, advances the pointer and counter, and branches with BEQ when five elements are read. At cycle 36, SW stores the accumulated sum into memory byte address 20. The testbench confirms that memory location 20 holds 14 (0x0E), completing in 39 clock cycles with a CPI of 1.0."

---

### [3:15 - 3:45] Segment 8: Program 2 Demo: Maximum Search (30s)
- **Speaker:** Member 3
- **Visual Cue (On Screen):** Terminal window executing `make demo-max`. Show the cycle trace highlighting cycle 16 where the candidate updates, cycle 36 where it writes back, and the final PASS confirmation.
- **Terminal Command Demonstrated:**
  ```bash
  make demo-max
  ```
- **Spoken Audio:**
  > "Next, we run Program 2: Maximum Element Search. Data memory is initialized with [7, 2, 11, 4, 9]. The processor loads the first element as the initial candidate, then iterates through remaining elements using signed SLT comparisons and conditional branches. At cycle 16, when 11 is encountered, the maximum candidate updates to 11, while smaller elements like 4 and 9 are bypassed. At cycle 36, SW writes 11 into memory byte address 20. The self-checking testbench confirms memory location 20 contains 11, verified in 39 cycles."

---

### [3:45 - 4:10] Segment 9: Waveform Analysis & Synthesis Overview (25s)
- **Speaker:** Member 1
- **Visual Cue (On Screen):** Switch to GTKWave displaying `waveforms/mips_cpu_array_sum.vcd` with grouped signals (`clk`, `current_pc`, `instruction`, `alu_result`, `dmem_write`), then show the summary table in `reports/synthesis_report.md`.
- **Spoken Audio:**
  > "In GTKWave, we inspect the execution waveforms, observing clean single-cycle transitions without race conditions. In Yosys synthesis, our `mips_core` synthesized into 9,002 generic logic cells, including 1,024 flip-flops and zero latches, confirming clean hardware synthesizability with technology-independent primitives."

---

### [4:10 - 4:30] Segment 10: Conclusion & Repository Links (20s)
- **Speaker:** Member 1
- **Visual Cue (On Screen):** Web browser displaying the GitHub repository page (`https://github.com/mishrasarthak08/MCA_TEAM_KL3S`) showing the compiled IEEE report PDF and documentation.
- **Spoken Audio:**
  > "In conclusion, we have designed, simulated, synthesized, and verified a 32-bit Single-Cycle MIPS processor that satisfies all academic requirements. All Verilog RTL source files, testbenches, assemblers, synthesis reports, and the compiled IEEE project report PDF are available in our public GitHub repository. Thank you for watching!"

---

## 3. Pre-Recording Verification Checklist

- [ ] All five team members confirmed their assigned speaking roles and names.
- [ ] Terminal environment tested: `iverilog`, `vvp`, `python3`, `yosys`, and `make` available.
- [ ] Terminal font size enlarged to 16pt+ bold for clear readability on video.
- [ ] Screen recording software tested with clean audio balance and no background noise.
- [ ] Commands `make test`, `make demo-sum`, and `make demo-max` tested from a clean state.
- [ ] GTKWave layout verified with pre-saved `waveforms/mips_cpu.gtkw` profile.
- [ ] Timer running during rehearsal to verify total video duration is between 4m15s and 4m45s (< 5m00s).
- [ ] Video uploaded to YouTube / Google Drive with visibility set to "Public" or "Unlisted".
- [ ] Video URL added to `README.md`, `docs/video_script.md`, and `report/main.tex`.
