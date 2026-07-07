library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity forwarding_unit is
    port (
        rs1_ex_i        : in  std_logic_vector(4 downto 0);
        rs2_ex_i        : in  std_logic_vector(4 downto 0);
        rd_mem_i        : in  std_logic_vector(4 downto 0);
        reg_write_mem_i : in  std_logic;
        rd_wb_i         : in  std_logic_vector(4 downto 0);
        reg_write_wb_i  : in  std_logic;
        forward_a_o     : out std_logic_vector(1 downto 0);
        forward_b_o     : out std_logic_vector(1 downto 0)
    );
end entity forwarding_unit;

architecture rtl of forwarding_unit is

    -- encoding: "00" = use ex operand; "01" = forward from MEM; "10" = forward from WB
begin

    P_FORWARD_A : process(rs1_ex_i, rd_mem_i, reg_write_mem_i, rd_wb_i, reg_write_wb_i)
    begin
        -- default: no forwarding
        forward_a_o <= "00";

        if (reg_write_mem_i = '1') and (rd_mem_i /= "00000") and (rd_mem_i = rs1_ex_i) then
            forward_a_o <= "01"; -- take from MEM stage
        elsif (reg_write_wb_i = '1') and (rd_wb_i /= "00000") and (rd_wb_i = rs1_ex_i) then
            forward_a_o <= "10"; -- take from WB stage
        else
            forward_a_o <= "00";
        end if;
    end process P_FORWARD_A;

    P_FORWARD_B : process(rs2_ex_i, rd_mem_i, reg_write_mem_i, rd_wb_i, reg_write_wb_i)
    begin
        forward_b_o <= "00";

        if (reg_write_mem_i = '1') and (rd_mem_i /= "00000") and (rd_mem_i = rs2_ex_i) then
            forward_b_o <= "01";
        elsif (reg_write_wb_i = '1') and (rd_wb_i /= "00000") and (rd_wb_i = rs2_ex_i) then
            forward_b_o <= "10";
        else
            forward_b_o <= "00";
        end if;
    end process P_FORWARD_B;

end architecture rtl;