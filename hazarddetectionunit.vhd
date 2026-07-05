library ieee;
use ieee.std_logic_1164.all;

entity hazard_detection_unit is
    port (
        -- Sinal que indica se a instrução no estágio EX é um Load
        mem_read_ex : in std_logic;
        registerdestination_address_ex : in std_logic_vector(4 downto 0);
        
        -- Registradores fontes da instrução atualmente no estágio ID
        register1_address_id : in std_logic_vector(4 downto 0);
        register2_address_id : in std_logic_vector(4 downto 0);

        -- Sinais de controle de mitigação de Hazard
        pc_stall : out std_logic;
        if_id_stall : out std_logic;
        id_ex_flush : out std_logic
    );
end entity hazard_detection_unit;

architecture rtl of hazard_detection_unit is
begin
    process(mem_read_ex, registerdestination_address_ex, register1_address_id, register2_address_id)
    begin
        -- Se a instrução no estágio EX for uma leitura de memória (Load) e seu destino
        -- for um dos operandos da instrução decodificada atualmente no estágio ID:
        if mem_read_ex = '1' and 
          (registerdestination_address_ex = register1_address_id or registerdestination_address_ex = register2_address_id) and 
          registerdestination_address_ex /= "00000" then
            -- Ativa a paralisação (stall) e limpa os sinais de controle (flush)
            pc_stall <= '1';
            if_id_stall <= '1';
            id_ex_flush <= '1';
        else
            -- Funcionamento normal da CPU
            pc_stall <= '0';
            if_id_stall <= '0';
            id_ex_flush <= '0';
        end if;
    end process;
end architecture rtl;