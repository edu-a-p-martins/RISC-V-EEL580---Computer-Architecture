library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vectorial_register_file is
    port( 
        clk_i : in std_logic;
        reset_i : in std_logic;
        we_i : in std_logic; --Responsible from allowing to write in the other registers

        vrs1_addr_i : in std_logic_vector(4 downto 0); --Address of first register
        vrs2_addr_i : in std_logic_vector(4 downto 0); --Address of second register
        vrd_addr_i : in std_logic_vector(4 downto 0); --Address of the destination register

        vrd_data_i : in std_logic_vector(127 downto 0); --Data that will be written in the register 

        --Data extracted from the registers
        vrs1_data_o : out std_logic_vector(127 downto 0);
        vrs2_data_o : out std_logic_vector(127 downto 0);
        vreg_debug_o  : out std_logic_vector(127 downto 0);  -- Register
        vreg_sel_i    : in  std_logic_vector(4 downto 0)    -- Selecting debug 


    );
end entity;

architecture rtl of vectorial_register_file is

    --Creates a new type that represents the conglomerate of vectorial registers that we have
    type vector_register_array is array (0 to 31) of std_logic_vector(127 downto 0); 
    signal vregisters : vector_register_array := (others => (others => '0'));
begin
    --Synchronous reset_i and writing
    write_process : process(clk_i)
    begin
        if rising_edge(clk_i) then
            if reset_i = '1' then
                --Resets all of the registers (synchronous)
                vregisters <= (others => (others => '0'));
            else
                --Writing the value in the register
                if we_i = '1' then
                    vregisters(to_integer(unsigned(vrd_addr_i))) <= vrd_data_i;
                end if;
            end if;
        end if;
    end process;
    
    -- Assincronous reading with internal forwarding
    vrs1_data_o <= vrd_data_i when (we_i = '1' and vrs1_addr_i = vrd_addr_i) else vregisters(to_integer(unsigned(vrs1_addr_i)));

    vrs2_data_o <= vrd_data_i when (we_i = '1' and vrs2_addr_i = vrd_addr_i) else vregisters(to_integer(unsigned(vrs2_addr_i)));
    
    vreg_debug_o <= (others => '0') when vreg_sel_i = "00000" else vregisters(to_integer(unsigned(vreg_sel_i)));

end architecture;