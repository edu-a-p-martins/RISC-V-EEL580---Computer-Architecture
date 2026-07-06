library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- sinal de reset_i estava assincrono, agora eh sincrono

entity register_file is
    port( 
        clk_i : in std_logic;
        reset_i : in std_logic;
        we_i : in std_logic; --Responsible from allowing to we_i in the other registers

        rs1_addr_i : in std_logic_vector(4 downto 0);
        rs2_addr_i : in std_logic_vector(4 downto 0);
        rd_addr_i : in std_logic_vector(4 downto 0);

        rd_data_i : in std_logic_vector(31 downto 0); --Data that will be written in the register 

        --Data extracted from the registers
        rs1_data_o : out std_logic_vector(31 downto 0);
        rs2_data_o : out std_logic_vector(31 downto 0);
        reg_debug_o  : out std_logic_vector(31 downto 0);  -- Registrador selecionado para debug
        reg_sel_i    : in  std_logic_vector(4 downto 0)    -- Seleção de registrador para debug


    );
end entity;

architecture rtl of register_file is

    --Creates a new type that represents the conglomerate of registers that we have
    type register_array is array (0 to 31) of std_logic_vector(31 downto 0); 
    signal registers : register_array := (others => (others => '0'));
begin
    --Synchronous reset_i and writing
    write_process : process(clk_i)
    begin
        if rising_edge(clk_i) then
            if reset_i = '1' then
                --Resets all of the registers (synchronous)
                registers <= (others => (others => '0'));
            else
                --Writing the value in the register
                if we_i = '1' and rd_addr_i /= "00000" then
                    registers(to_integer(unsigned(rd_addr_i))) <= rd_data_i;
                end if;
            end if;
        end if;
    end process;
    --Assincronou reading process
    rs1_data_o <= (others => '0') when rs1_addr_i = "00000" else registers(to_integer(unsigned(rs1_addr_i)));
    rs2_data_o <= (others => '0') when rs2_addr_i = "00000" else registers(to_integer(unsigned(rs2_addr_i)));

    reg_debug_o <= (others => '0') when reg_sel_i = "00000" else
                registers(to_integer(unsigned(reg_sel_i)));

end architecture;