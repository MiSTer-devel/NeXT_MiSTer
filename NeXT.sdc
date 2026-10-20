derive_pll_clocks
derive_clock_uncertainty

# core specific constraints

# clk_sys (27.5 MHz, outclk_0) and clk_cpu (55 MHz, outclk_2) are the
# 68040's bus clock and processor clock: the CPU (rtl/ap68040) changes its
# bus outputs and samples its bus inputs only on the processor clock edges
# that end a bus clock (bclk_en, made in rtl/next/next_cpu040.sv so that
# those are the clk_sys edges), and everything of the CPU's that the
# clk_sys side reads is such a flip-flop.  Every path between the two
# domains therefore has a whole bus clock period, 36.4 ns, not the 18.2 ns
# the default single-cycle analysis to the mid-bus-clock edge assumes.
# The one exception is the bclk_en generator itself: sys_tog -> tog_q must
# be captured on the very next processor clock edge.  clk_vid (100 MHz,
# outclk_1) exchanges data with clk_sys only through the dual-clock VRAM
# scan port and a 2FF synchronizer on the vertical blank level, so it is
# an asynchronous group.
set_clock_groups -asynchronous \
	-group [get_clocks {emu|pll|pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk \
	                    emu|pll|pll_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}] \
	-group [get_clocks {emu|pll|pll_inst|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|divclk}]

set_multicycle_path -setup -end 2 \
	-from [get_clocks {emu|pll|pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] \
	-to   [get_clocks {emu|pll|pll_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}]
set_multicycle_path -hold -end 1 \
	-from [get_clocks {emu|pll|pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] \
	-to   [get_clocks {emu|pll|pll_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}]
set_multicycle_path -setup -start 2 \
	-from [get_clocks {emu|pll|pll_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}] \
	-to   [get_clocks {emu|pll|pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]
set_multicycle_path -hold -start 1 \
	-from [get_clocks {emu|pll|pll_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}] \
	-to   [get_clocks {emu|pll|pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]
# the bclk_en generator: single cycle
set_multicycle_path -setup -end 1 -to [get_registers {*|cpubus|tog_q}]
set_multicycle_path -hold  -end 0 -to [get_registers {*|cpubus|tog_q}]

# LTC2308 interface: core uses SCK_DIV=2 (7 MHz), long CONVST (2 us),
# and two clk_sys cycles from CONVST falling to the first SDO capture.
# SCK is gated and its start phase moves with the fractional sample divider;
# a continuously running divide-by-four generated clock would be incorrect.
# Instead bound the root-clock-referenced Tco and Tsu explicitly. TimeQuest
# includes launch clock insertion in output Tco and subtracts capture clock
# insertion from input Tsu; these are NOT bounds on data routing alone.
# The two sides use the same clk_sys reference, so their clock insertion
# terms combine into the actual round-trip skew. Each 71.429 ns half-period
# allows 18 ns output Tco + 2 ns board + 15 ns ADC enable/data-valid +
# 2 ns board + 18 ns input Tsu = 55 ns, leaving >16 ns margin.
# SDI changes on SCK falling; it has the same half-period setup budget and
# a further half-period hold before its next change (ADC hold requirement 2.5 ns).
# CONVST remains high for 2 us: even 18 ns output skew leaves >1.6 us for
# conversion. The 2 ns one-way board allowance covers the on-board interface.
# tb/check_adc_timing.tcl checks all corners, both budgets, and their common
# clock reference. No input/output delay is added on top of these exceptions.
set_max_delay 18.000 -from [get_ports ADC_SDO]
set_min_delay 0.000 -from [get_ports ADC_SDO]
set_max_delay 18.000 -to [get_ports {ADC_SCK ADC_SDI ADC_CONVST}]
set_min_delay 0.000 -to [get_ports {ADC_SCK ADC_SDI ADC_CONVST}]
