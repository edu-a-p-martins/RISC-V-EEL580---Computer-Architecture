library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- sinal de reset estava assincrono, agora eh sincrono

entity register_file is
    port (
        clk : in std_logic;
        reset : in std_logic;
        write : in std_logic; --Responsible from allowing to write in the other registers
        register1_address : in std_logic_vector(4 downto 0);
        register2_address : in std_logic_vector(4 downto 0);
        registerdestination_address : in std_logic_vector(4 downto 0);
        registerdestination_wdata : in std_logic_vector(31 downto 0); --Data that will be written in the register 

        --Data extracted from the registers
        register1_data : out std_logic_vector(31 downto 0);
        register2_data : out std_logic_vector(31 downto 0)

    );
end entity;

architecture rtl of register_file is

    --Creates a new type that represents the conglomerate of registers that we have
    type register_array is array (0 to 31) of std_logic_vector(31 downto 0); 
    signal registers : register_array := (others => (others => '0'));
begin
    --Synchronous reset and writing
    write_process : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                --Resets all of the registers (synchronous)
                registers <= (others => (others => '0'));
            else
                --Writing the value in the register
                if write = '1' and registerdestination_address /= "00000" then
                    registers(to_integer(unsigned(registerdestination_address))) <= registerdestination_wdata;
                end if;
            end if;
        end if;
    end process;
    --Assincronou reading process
    register1_data <= (others => '0') when register1_address = "00000" else registers(to_integer(unsigned(register1_address)));
    register2_data <= (others => '0') when register2_address = "00000" else registers(to_integer(unsigned(register2_address)));

end architecture;