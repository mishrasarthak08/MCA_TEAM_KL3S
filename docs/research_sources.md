# Research Sources

These sources were checked on November 14, 2026. The IEEE report cites the first five; the remaining sources support formatting and tool reproducibility.

## Architecture and ISA

1. David A. Patterson and John L. Hennessy, *Computer Organization and Design MIPS Edition: The Hardware/Software Interface*, 6th ed., Morgan Kaufmann, 2020.
   https://shop.elsevier.com/books/computer-organization-and-design-mips-edition/patterson/978-0-12-820109-1
   Used for the single-cycle datapath, memory hierarchy, and instruction/data separation discussion.

2. MIPS Technologies, Inc., *MIPS32 Architecture for Programmers, Volume II: The MIPS32 Instruction Set*, Revision 2.50, 2005.
   https://minnie.tuhs.org/CompArch/Resources/MD00086-2B-MIPS32BIS-AFP-02.50.pdf
   Used to verify the MIPS instruction formats and instruction semantics. The implemented processor remains an educational subset.

## HDL and EDA Tools

3. IEEE Computer Society, *IEEE Standard for Verilog Hardware Description Language*, IEEE Std 1364-2001, DOI 10.1109/IEEESTD.2001.93352.
   https://ieeexplore.ieee.org/document/954909
   Primary standard for the RTL language version used by the project.

4. Clifford Wolf and Johann Glaser, “Yosys — A Free Verilog Synthesis Suite,” *Proceedings of Austrochip 2013*, 2013.
   https://yosyshq.net/yosys/files/yosys-austrochip2013.pdf
   Primary Yosys paper. This replaces an incorrect earlier citation that attributed a different 2019 paper to the wrong authors.

5. Icarus Verilog Project, “Simulation Using Icarus Verilog.”
   https://steveicarus.github.io/iverilog/usage/simulation.html
   Official documentation for compilation, elaboration, simulation, testbenches, and VCD-oriented workflows. This replaces a non-existent earlier ACM journal citation.

## Report Formatting and Build

6. IEEE Author Center, “Authoring Tools and Templates.”
   https://conferences.ieeeauthorcenter.ieee.org/write-your-paper/authoring-tools-and-templates/
   Confirms the use of IEEE conference templates in LaTeX.

7. CTAN, “IEEEtran — Document class for IEEE Transactions journals and conferences.”
   https://ctan.org/pkg/ieeetran
   Package record for the `IEEEtran` class and bibliography style.

8. Tectonic Typesetting System.
   https://tectonic-typesetting.github.io/en-US/
   Build engine used by `make report`.

## Source Quality Notes

- Prefer the primary standard, official project documentation, publisher page, or original tool paper.
- Do not cite search-result pages, unverified blogs, or invented journal articles.
- Keep claims within the evidence. The repository does not contain physical FPGA timing, power, or utilization measurements.
