library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity program_counter is
    port (
        clk   : in std_logic;
        reset : in std_logic;
        stall : in std_logic; --Dictates where to stay in the same PC or not
        branch : in std_logic;
        jump : in std_logic;
        ld_enable : in std_logic; --Is used during the load of data
        target_address : in std_logic_vector(31 downto 0); --Address when we jump or branch

        pc : out std_logic_vector(31 downto 0);
        pc_plus4 : out std_logic_vector(31 downto 0) --This is used for jal and jalr instructions
    );
end entity;

architecture rtl of program_counter is
    --Register that holds the value of PC
    signal pc_register : std_logic_vector(31 downto 0) := (others => '0');
begin

    --Determines the changes in the PC register
    pc_reg_changes : process(clk, reset)
    begin
        if reset = '1' then
            pc_register <= (others => '0');
        elsif rising_edge(clk) then
            --Only activates the PC when we arent loading and there is no stall
            if ld_enable = '0' and stall = '0' then 
                --If we either do a jump or take a branch
                if branch = '1' or jump <= '1' then
                    pc_register <= target_address;
                else
                    pc_register <= std_logic_vector(unsigned(pc_register) + 4);
                end if;
            end if;
        end if;
    end process;
    
    pc <= pc_register;
    pc_plus4 <= std_logic_vector(unsigned(pc_register) + 4);

end architecture;