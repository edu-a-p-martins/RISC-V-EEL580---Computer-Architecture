ghdl -a --std=08 --ieee=synopsys alu.vhd
ghdl -a --std=08 --ieee=synopsys register_file.vhd
ghdl -a --std=08 --ieee=synopsys instruction_decoder.vhd
ghdl -a --std=08 --ieee=synopsys control_unit.vhd
ghdl -a --std=08 --ieee=synopsys pipeline_regs.vhd
ghdl -a --std=08 --ieee=synopsys hazard_unit.vhd
ghdl -a --std=08 --ieee=synopsys forwarding_unit.vhd
ghdl -a --std=08 --ieee=synopsys branch_comparator.vhd
ghdl -a --std=08 --ieee=synopsys program_counter.vhd

