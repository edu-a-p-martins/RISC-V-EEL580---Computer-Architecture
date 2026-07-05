library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity branch_detector is
    port (
        -- Sinal de controle vindo da control_unit indicando que é um Branch
        branch_enable : in std_logic; 
        
        -- funct3 para decidir qual o tipo da comparação (beq, bne, blt, bge, etc.)
        funct3 : in std_logic_vector(2 downto 0); 
        
        -- Operandos que serão comparados
        operator_a : in std_logic_vector(31 downto 0); 
        operator_b : in std_logic_vector(31 downto 0); 

        -- Resultado final (1 = toma o branch, 0 = não toma)
        branch_taken : out std_logic 
    );
end entity branch_detector;

architecture rtl of branch_detector is
begin
    process(branch_enable, funct3, operator_a, operator_b)
        variable is_equal : boolean;
        variable is_less_than_signed : boolean;
        variable is_less_than_unsigned : boolean;
    begin
        -- Por padrão o branch não é tomado
        branch_taken <= '0'; 

        if branch_enable = '1' then
            -- Precomputa as comparações básicas
            is_equal := (operator_a = operator_b);
            is_less_than_signed := (signed(operator_a) < signed(operator_b));
            is_less_than_unsigned := (unsigned(operator_a) < unsigned(operator_b));

            -- Avalia a condição baseada no funct3 do RISC-V
            case funct3 is
                when "000" => -- beq
                    if is_equal then branch_taken <= '1'; end if;
                when "001" => -- bne
                    if not is_equal then branch_taken <= '1'; end if;
                when "100" => -- blt (signed)
                    if is_less_than_signed then branch_taken <= '1'; end if;
                when "101" => -- bge (signed)
                    if not is_less_than_signed then branch_taken <= '1'; end if;
                when "110" => -- bltu (unsigned)
                    if is_less_than_unsigned then branch_taken <= '1'; end if;
                when "111" => -- bgeu (unsigned)
                    if not is_less_than_unsigned then branch_taken <= '1'; end if;
                when others =>
                    branch_taken <= '0';
            end case;
        end if;
    end process;
end architecture rtl;