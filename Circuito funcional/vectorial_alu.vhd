library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity vector_ALU is

    port(
        operator_a  : in std_logic_vector(127 downto 0); -- Operand A
        operator_b  : in std_logic_vector(127 downto 0); -- Operand B
        alu_operation : in std_logic_vector(3 downto 0); -- Selects the type of operation

        zero_flag : out std_logic; -- Flag Zero
        alu_result : out std_logic_vector(127 downto 0) --The result given from the operation
    );

end entity vector_ALU;

architecture main of vector_ALU is

    --Signals used in the middle of the process
    signal operator_a1, operator_a2, operator_a3, operator_a4 : std_logic_vector(31 downto 0);
    signal operator_b1, operator_b2, operator_b3, operator_b4 : std_logic_vector(31 downto 0);
    signal result1, result2, result3, result4 : std_logic_vector(31 downto 0);
begin
    
    --Stores everything in place as a vetorial lane
    operator_a1 <= operator_a(31 downto 0);
    operator_a2 <= operator_a(63 downto 32);
    operator_a3 <= operator_a(95 downto 64);
    operator_a4 <= operator_a(127 downto 96);

    operator_b1 <= operator_b(31 downto 0);
    operator_b2 <= operator_b(63 downto 32);
    operator_b3 <= operator_b(95 downto 64);
    operator_b4 <= operator_b(127 downto 96);

    ALU_calculation : process(operator_a, operator_b, alu_operation)
    begin
        -- Does the calculations
        case alu_operation is
            --Addition 
            when "0000" =>
                result1 <= std_logic_vector(signed(operator_a1) + signed(operator_b1));
                result2 <= std_logic_vector(signed(operator_a2) + signed(operator_b2));
                result3 <= std_logic_vector(signed(operator_a3) + signed(operator_b3));
                result4 <= std_logic_vector(signed(operator_a4) + signed(operator_b4));
            --Subtraction 
            when "0001" =>
                result1 <= std_logic_vector(signed(operator_a1) - signed(operator_b1));
                result2 <= std_logic_vector(signed(operator_a2) - signed(operator_b2));
                result3 <= std_logic_vector(signed(operator_a3) - signed(operator_b3));
                result4 <= std_logic_vector(signed(operator_a4) - signed(operator_b4));
            --Shift left 
            when "0010" =>
                result1 <= std_logic_vector(shift_left(unsigned(operator_a1), to_integer(unsigned(operator_b1(4 downto 0)))));
                result2 <= std_logic_vector(shift_left(unsigned(operator_a2), to_integer(unsigned(operator_b2(4 downto 0)))));
                result3 <= std_logic_vector(shift_left(unsigned(operator_a3), to_integer(unsigned(operator_b3(4 downto 0)))));
                result4 <= std_logic_vector(shift_left(unsigned(operator_a4), to_integer(unsigned(operator_b4(4 downto 0)))));
            --Shift right  
            when "0011" =>
                result1 <= std_logic_vector(shift_right(unsigned(operator_a1), to_integer(unsigned(operator_b1(4 downto 0)))));
                result2 <= std_logic_vector(shift_right(unsigned(operator_a2), to_integer(unsigned(operator_b2(4 downto 0)))));
                result3 <= std_logic_vector(shift_right(unsigned(operator_a3), to_integer(unsigned(operator_b3(4 downto 0)))));
                result4 <= std_logic_vector(shift_right(unsigned(operator_a4), to_integer(unsigned(operator_b4(4 downto 0)))));
            when others =>
                null;
        end case;
    end process ALU_calculation;

    --Gives final outputs
    alu_result <= result4 & result3 & result2 & result1;
    zero_flag <= '1' when unsigned(result4 & result3 & result2 & result1) = 0 else '0';


end architecture main;