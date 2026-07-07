library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- corrigido um "<=" no ultimo if
entity program_counter is
    port (
        clk_i   : in std_logic;
        reset_i : in std_logic;
        stall_i : in std_logic; --Dictates where to stay in the same pc_o or not
        load_enable_i : in std_logic; --Is used during the load of data        
        branch_taken_i : in std_logic;
        jump_i : in std_logic;

        target_addr_i : in std_logic_vector(31 downto 0); --Address when we jump_i or branch_taken_i

        pc_o : out std_logic_vector(31 downto 0);
        pc_plus4_o : out std_logic_vector(31 downto 0) --This is used for jal and jalr instructions
    );
end entity;

architecture rtl of program_counter is
    --Register that holds the value of pc_o
    signal pc_register : std_logic_vector(31 downto 0) := (others => '0');
begin

    --Determines the changes in the pc_o register
    pc_reg_changes : process(clk_i, reset_i)
    begin
        if reset_i = '1' then
            pc_register <= (others => '0');
        elsif rising_edge(clk_i) then
            --Only activates the pc_o when we arent loading and there is no stall_i
            if load_enable_i = '0' and stall_i = '0' then 
                --If we either do a jump_i or take a branch_taken_i
                if branch_taken_i = '1' or jump_i = '1' then
                    pc_register <= target_addr_i;
                else
                    pc_register <= std_logic_vector(unsigned(pc_register) + 4);
                end if;
            end if;
        end if;
    end process;
    
    pc_o <= pc_register;
    pc_plus4_o <= std_logic_vector(unsigned(pc_register) + 4);

end architecture;