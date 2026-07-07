library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--The vectorial fowarding unit is, essecially, just the same as the forwarding unit but dedicated to the vectors
entity vector_forwarding_unit is
    port (
        --Adrress of the registers
        vrs1_ex_i        : in  std_logic_vector(4 downto 0);
        vrs2_ex_i        : in  std_logic_vector(4 downto 0);
        vrd_mem_i        : in  std_logic_vector(4 downto 0);
        vector_ex_i   : in  std_logic;  -- EX vectorial instruction

        --Control signals
        vreg_write_mem_i : in  std_logic;
        vrd_wb_i         : in  std_logic_vector(4 downto 0);
        vreg_write_wb_i  : in  std_logic;
        --Forward Outputs
        vforward_a_o     : out std_logic_vector(1 downto 0);
        vforward_b_o     : out std_logic_vector(1 downto 0)
    );
end entity vector_forwarding_unit;

architecture rtl of vector_forwarding_unit is

    -- Encoding: "00" = use ex operand; "01" = forward from MEM; "10" = forward from WB
begin

    FORWARD_A : process(vrs1_ex_i, vrd_mem_i, vreg_write_mem_i, vrd_wb_i, vreg_write_wb_i)
    begin
        -- Default: no forwarding
        vforward_a_o <= "00";
        if vector_ex_i = '1' then
            if (vreg_write_mem_i = '1') and (vrd_mem_i = vrs1_ex_i) then
                vforward_a_o <= "01"; -- take from MEM stage
            elsif (vreg_write_wb_i = '1') and (vrd_wb_i = vrs1_ex_i) then
                vforward_a_o <= "10"; -- take from WB stage
            else
                vforward_a_o <= "00";
            end if;
        end if;
    end process FORWARD_A;

    FORWARD_B : process(vrs2_ex_i, vrd_mem_i, vreg_write_mem_i, vrd_wb_i, vreg_write_wb_i)
    begin
        vforward_b_o <= "00";
        
        if vector_ex_i = '1' then
            if (vreg_write_mem_i = '1') and (vrd_mem_i = vrs2_ex_i) then
                vforward_b_o <= "01";
            elsif (vreg_write_wb_i = '1') and (vrd_wb_i = vrs2_ex_i) then
                vforward_b_o <= "10";
            else
                vforward_b_o <= "00";
            end if;
        end if;
    end process FORWARD_B;

end architecture rtl;