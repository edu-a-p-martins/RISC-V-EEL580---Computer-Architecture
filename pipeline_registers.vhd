library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- ld_enable zero?
-- adicionado lui, ainda nao esta feito
---------------------------------------------------------------
--IF-ID register
---------------------------------------------------------------
entity if_id_register is
    port (
        --Signals that alter the way the register works
        clk   : in std_logic;
        reset : in std_logic;
        stall : in std_logic; --Maintains the value
        flush : in std_logic; --Makes a NOP instruction
        ld_enable : in std_logic; -- Loading from the memory
        --IF Inputs 
        pc_if : in std_logic_vector(31 downto 0);
        pc_plus4_if : in std_logic_vector(31 downto 0);
        instruction_if : in std_logic_vector(31 downto 0);
        --ID Outputs
        pc_id : out std_logic_vector(31 downto 0);
        pc_plus4_id : out std_logic_vector(31 downto 0);
        instruction_id : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of if_id_register is

begin
    updating_id : process(clk, reset)
    begin
        if reset = '1' then
            pc_id <= (others => '0');
            pc_plus4_id <= (others => '0');
            instruction_id <= (others => '0');
        elsif rising_edge(clk) then 
            if ld_enable = '0' then
                --Does a NOP 
                if flush = '1' then
                    pc_id <= (others => '0');
                    pc_plus4_id <= (others => '0');
                    instruction_id <= x"00000013"; --Equivalent to addi x0, x0, 0
                --Passes on the values
                elsif stall = '0' then
                    pc_id <= pc_if;
                    pc_plus4_id <= pc_plus4_if;
                    instruction_id <= instruction_if;
                end if;
            end if;
        end if ;
    end process;

end architecture;
---------------------------------------------------------------
--ID-EX register
---------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity id_ex_register is
    port (
        --Signals that alter the way the register works
        clk   : in std_logic;
        reset : in std_logic;
        stall : in std_logic; --Maintains the value
        flush : in std_logic; --Makes a NOP instruction
        ld_enable : in std_logic; -- Loading from the memory
        --ID Inputs 
        pc_id : in std_logic_vector(31 downto 0);
        pc_plus4_id : in std_logic_vector(31 downto 0);
        register1_address_id : in std_logic_vector(4 downto 0);
        register2_address_id : in std_logic_vector(4 downto 0);
        registerdestination_address_id : in std_logic_vector(4 downto 0);
        register1_data_id : in std_logic_vector(31 downto 0);
        register2_data_id : in std_logic_vector(31 downto 0);
        immediate_id : in std_logic_vector(31 downto 0);
        funct3_id : in std_logic_vector(2 downto 0);

        --Control Unity Signals
        branch_id      : in  std_logic;
        mem_read_id    : in  std_logic;
        mem_to_reg_id  : in  std_logic;
        ALU_op_id    : in  std_logic_vector(3 downto 0);
        mem_write_id   : in  std_logic;
        ALU_src_id     : in  std_logic;
        reg_write_id   : in  std_logic;
        jump_id        : in  std_logic;
        jalr_id       : in  std_logic;
           auipc_id       : in  std_logic;
           lui_id         : in  std_logic;

        --EX Outputs
        pc_ex : out std_logic_vector(31 downto 0);
        pc_plus4_ex : out std_logic_vector(31 downto 0);
        register1_address_ex : out std_logic_vector(4 downto 0);
        register2_address_ex : out std_logic_vector(4 downto 0);
        registerdestination_address_ex : out std_logic_vector(4 downto 0);
        register1_data_ex : out std_logic_vector(31 downto 0);
        register2_data_ex : out std_logic_vector(31 downto 0);
        immediate_ex : out std_logic_vector(31 downto 0);
        funct3_ex : out std_logic_vector(2 downto 0);
        branch_ex      : out  std_logic;
        mem_read_ex    : out  std_logic;
        mem_to_reg_ex  : out  std_logic;
        ALU_op_ex    : out  std_logic_vector(3 downto 0);
        mem_write_ex   : out  std_logic;
        ALU_src_ex     : out  std_logic;
        reg_write_ex   : out  std_logic;
        jump_ex        : out  std_logic;
        jalr_ex       : out  std_logic;
           auipc_ex       : out  std_logic;
           lui_ex         : out  std_logic
    );
end entity id_ex_register;

architecture rtl of id_ex_register is

begin
    updating_ex : process(clk, reset)
    begin
        --Resets all values
        if reset = '1' then
            pc_ex                          <= (others => '0');
            pc_plus4_ex                    <= (others => '0');
            register1_address_ex           <= (others => '0');
            register2_address_ex           <= (others => '0');
            registerdestination_address_ex <= (others => '0');
            register1_data_ex              <= (others => '0');
            register2_data_ex              <= (others => '0');
            immediate_ex                   <= (others => '0');
            funct3_ex                      <= (others => '0');
            branch_ex      <= '0';
            mem_read_ex    <= '0';
            mem_to_reg_ex  <= '0';
            ALU_op_ex      <= (others => '0');
            mem_write_ex   <= '0';
            ALU_src_ex     <= '0';
            reg_write_ex   <= '0';
            jump_ex        <= '0';
            jalr_ex        <= '0';
                auipc_ex       <= '0';
                lui_ex         <= '0';
        elsif rising_edge(clk) then 
            if ld_enable = '0' then
                --Does a NOP 
                if flush = '1' then
                    pc_ex <= (others => '0');
                    pc_plus4_ex <= (others => '0');
                    register1_address_ex <= (others => '0');
                    register2_address_ex <= (others => '0');
                    registerdestination_address_ex <= (others => '0');
                    register1_data_ex <= (others => '0');
                    register2_data_ex <= (others => '0');
                    immediate_ex <= (others => '0');
                    funct3_ex <= (others => '0');
                    branch_ex <= '0';
                    mem_read_ex <= '0';
                    mem_to_reg_ex <= '0';
                    ALU_op_ex <= (others => '0');
                    mem_write_ex <= '0';
                    ALU_src_ex <= '0';
                    reg_write_ex <= '0';
                    jump_ex <= '0';
                    jalr_ex <= '0';
                        auipc_ex <= '0';
                        lui_ex <= '0';
                --Passes on the values
                elsif stall = '0' then
                    pc_ex <= pc_id;
                    pc_plus4_ex <= pc_plus4_id;
                    register1_address_ex <= register1_address_id;
                    register2_address_ex <= register2_address_id;
                    registerdestination_address_ex <= registerdestination_address_id;
                    register1_data_ex <= register1_data_id;
                    register2_data_ex <= register2_data_id;
                    immediate_ex <= immediate_id;
                    funct3_ex <= funct3_id;
                    branch_ex <= branch_id;
                    mem_read_ex <= mem_read_id;
                    mem_to_reg_ex <= mem_to_reg_id;
                    ALU_op_ex <= ALU_op_id;
                    mem_write_ex <= mem_write_id;
                    ALU_src_ex <= ALU_src_id;
                    reg_write_ex <= reg_write_id;
                    jump_ex <= jump_id;
                    jalr_ex <= jalr_id;
                        auipc_ex <= auipc_id;
                        lui_ex <= lui_id;
                end if;
            end if;
        end if ;
    end process;

end architecture;

---------------------------------------------------------------
--EX-MEM register
---------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ex_mem_register is
    port (
        --Signals that alter the way the register works
        clk   : in std_logic;
        reset : in std_logic;
        flush : in std_logic; --Makes a NOP instruction
        ld_enable : in std_logic; -- Loading from the memory
        --EX Inputs
        alu_result_ex : in std_logic_vector(31 downto 0);
        pc_plus4_ex : in std_logic_vector(31 downto 0);
        registerdestination_address_ex : in std_logic_vector(4 downto 0);
        register2_data_ex : in std_logic_vector(31 downto 0);
        zero_flag_ex : in std_logic;
        --Control Unity Signals
        branch_ex      : in  std_logic;
        mem_read_ex    : in  std_logic;
        mem_to_reg_ex  : in  std_logic;
        ALU_op_ex    : in  std_logic_vector(3 downto 0);
        mem_write_ex   : in  std_logic;
        ALU_src_ex     : in  std_logic;
        reg_write_ex   : in  std_logic;
        jump_ex        : in  std_logic;

        --MEM Outputs
        alu_result_mem : out std_logic_vector(31 downto 0);
        pc_plus4_mem : out std_logic_vector(31 downto 0);
        registerdestination_address_mem : out std_logic_vector(4 downto 0);
        register2_data_mem : out std_logic_vector(31 downto 0);
        zero_flag_mem : out std_logic;
        branch_mem      : out  std_logic;
        mem_read_mem    : out  std_logic;
        mem_to_reg_mem  : out  std_logic;
        ALU_op_mem    : out  std_logic_vector(3 downto 0);
        mem_write_mem   : out  std_logic;
        ALU_src_mem     : out  std_logic;
        reg_write_mem   : out  std_logic;
        jump_mem        : out  std_logic

    );
end entity;

architecture rtl of ex_mem_register is

begin
    updating_mem : process(clk, reset)
    begin
        if reset = '1' then
            alu_result_mem <= (others => '0');
            pc_plus4_mem <= (others => '0');
            registerdestination_address_mem <= (others => '0');
            register2_data_mem <= (others => '0');
            zero_flag_mem <= '0';
            branch_mem <= '0';
            mem_read_mem <= '0';
            mem_to_reg_mem <= '0';
            ALU_op_mem <= (others => '0');
            mem_write_mem <= '0';
            ALU_src_mem <= '0';
            reg_write_mem <= '0';
            jump_mem <= '0';
        elsif rising_edge(clk) then 
            if ld_enable = '0' then
                --Does a NOP 
                if flush = '1' then
                    alu_result_mem <= (others => '0');
                    pc_plus4_mem <= (others => '0');
                    registerdestination_address_mem <= (others => '0');
                    register2_data_mem <= (others => '0');
                    zero_flag_mem <= '0';
                    branch_mem <= '0';
                    mem_read_mem <= '0';
                    mem_to_reg_mem <= '0';
                    ALU_op_mem <= (others => '0');
                    mem_write_mem <= '0';
                    ALU_src_mem <= '0';
                    reg_write_mem <= '0';
                    jump_mem <= '0';
                --Passes on the values
                else
                    alu_result_mem <= alu_result_ex;
                    pc_plus4_mem <= pc_plus4_ex;
                    registerdestination_address_mem <= registerdestination_address_ex;
                    register2_data_mem <= register2_data_ex;
                    zero_flag_mem <= zero_flag_ex;
                    branch_mem <= branch_ex;
                    mem_read_mem <= mem_read_ex;
                    mem_to_reg_mem <= mem_to_reg_ex;
                    ALU_op_mem <= ALU_op_ex;
                    mem_write_mem <= mem_write_ex;
                    ALU_src_mem <= ALU_src_ex;
                    reg_write_mem <= reg_write_ex;
                    jump_mem <= jump_ex;
                end if;
            end if;
        end if ;
    end process;

end architecture;
---------------------------------------------------------------
--MEM-WB register
---------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem_wb_register is
    port (
        --Signals that alter the way the register works
        clk   : in std_logic;
        reset : in std_logic;
        ld_enable : in std_logic; -- Loading from the memory
        --MEM Inputs
        alu_result_mem : in std_logic_vector(31 downto 0);
        pc_plus4_mem : in std_logic_vector(31 downto 0);
        registerdestination_address_mem : in std_logic_vector(4 downto 0);
        memory_data_mem : in std_logic_vector(31 downto 0); --Data read during MEM
        --Control Unity Signals
        mem_to_reg_mem  : in  std_logic;
        reg_write_mem   : in  std_logic;
        jump_mem        : in  std_logic;

        --WB outputs
        alu_result_wb: out std_logic_vector(31 downto 0);
        pc_plus4_wb: out std_logic_vector(31 downto 0);
        registerdestination_address_wb: out std_logic_vector(4 downto 0);
        memory_data_wb: out std_logic_vector(31 downto 0);
        mem_to_reg_wb : out  std_logic;
        reg_write_wb  : out  std_logic;
        jump_wb       : out  std_logic

    );
end entity;

architecture rtl of mem_wb_register is

begin
    updating_wb : process(clk, reset)
    begin
        if reset = '1' then
            alu_result_wb <= (others => '0');
            pc_plus4_wb <= (others => '0');
            registerdestination_address_wb <= (others => '0');
            memory_data_wb <= (others => '0');
            mem_to_reg_wb <= '0';
            reg_write_wb <= '0';
            jump_wb <= '0';
        elsif rising_edge(clk) then 
            if ld_enable = '0' then
                alu_result_wb <= alu_result_mem;
                pc_plus4_wb <= pc_plus4_mem;
                registerdestination_address_wb <= registerdestination_address_mem;
                memory_data_wb <= memory_data_mem;
                mem_to_reg_wb <= mem_to_reg_mem;
                reg_write_wb <= reg_write_mem;
                jump_wb <= jump_mem;
            end if;
        end if ;
    end process;

end architecture;