
library ieee;
use ieee.std_logic_1164.all;

entity hazard_unit is
    port (
        rs1_id_i       : in  std_logic_vector(4 downto 0);
        rs2_id_i       : in  std_logic_vector(4 downto 0);
        rd_ex_i        : in  std_logic_vector(4 downto 0);
        mem_read_ex_i  : in  std_logic;                    
        branch_taken_i : in  std_logic;                     
        jump_i         : in  std_logic;  
        stall_if_o     : out std_logic;    
        stall_id_o     : out std_logic;         
        flush_id_o     : out std_logic; 
        flush_ex_o     : out std_logic;
        -- Debug
        hazard_type_o  : out std_logic_vector(1 downto 0)
    );
end entity hazard_unit;

architecture rtl of hazard_unit is

    signal load_use_hazard  : std_logic;
    signal control_hazard   : std_logic;

begin
    load_use_hazard <= '1' when (mem_read_ex_i = '1') and (rd_ex_i /= "00000") and
                                ((rd_ex_i = rs1_id_i) or (rd_ex_i = rs2_id_i))

    control_hazard <= branch_taken_i or jump_i;

    P_HAZARD_CONTROL : process(load_use_hazard, control_hazard, branch_taken_i, jump_i)
    begin
        -- Valores padrão
        stall_if_o    <= '0';
        stall_id_o    <= '0';
        flush_id_o    <= '0';
        flush_ex_o    <= '0';
        hazard_type_o <= "00";

        if load_use_hazard = '1' then
            stall_if_o    <= '1';
            stall_id_o    <= '1';
            flush_ex_o    <= '1'; 
            hazard_type_o <= "01";
        end if;

        if control_hazard = '1' then
            flush_id_o    <= '1'; 
            flush_ex_o    <= '1'; 
            hazard_type_o <= "10";
        end if;

    end process P_HAZARD_CONTROL;

end architecture rtl;
