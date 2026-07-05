library ieee;
use ieee.std_logic_1164.all;

entity forwarding_unit is
    port (
        -- Entradas do estágio EX (Fontes atuais)
        register1_address_ex : in std_logic_vector(4 downto 0);
        register2_address_ex : in std_logic_vector(4 downto 0);

        -- Entradas do estágio MEM (Instrução anterior)
        registerdestination_address_mem : in std_logic_vector(4 downto 0);
        reg_write_mem : in std_logic;

        -- Entradas do estágio WB (Instrução retrasada)
        registerdestination_address_wb : in std_logic_vector(4 downto 0);
        reg_write_wb : in std_logic;

        -- Saídas de controle para os Multiplexadores da ULA
        -- "00" = Sem repasse (usa valor original)
        -- "10" = Repasse do estágio MEM
        -- "01" = Repasse do estágio WB
        forward_a : out std_logic_vector(1 downto 0);
        forward_b : out std_logic_vector(1 downto 0)
    );
end entity forwarding_unit;

architecture rtl of forwarding_unit is
begin
    process(register1_address_ex, register2_address_ex, registerdestination_address_mem, reg_write_mem, registerdestination_address_wb, reg_write_wb)
    begin
        -- Valor padrão: sem repasse
        forward_a <= "00";
        forward_b <= "00";

        -- Logica de repasse para a entrada A da ULA
        if (reg_write_mem = '1' and registerdestination_address_mem /= "00000" and registerdestination_address_mem = register1_address_ex) then
            forward_a <= "10"; -- EX hazard
        elsif (reg_write_wb = '1' and registerdestination_address_wb /= "00000" and registerdestination_address_wb = register1_address_ex) then
            forward_a <= "01"; -- MEM hazard
        end if;

        -- Logica de repasse para a entrada B da ULA
        if (reg_write_mem = '1' and registerdestination_address_mem /= "00000" and registerdestination_address_mem = register2_address_ex) then
            forward_b <= "10"; -- EX hazard
        elsif (reg_write_wb = '1' and registerdestination_address_wb /= "00000" and registerdestination_address_wb = register2_address_ex) then
            forward_b <= "01"; -- MEM hazard
        end if;
    end process;
end architecture rtl;