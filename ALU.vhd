library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ALU is

    port(
        operator_a  : in std_logic_vector(31 downto 0); -- Operand A
        operator_b  : in std_logic_vector(31 downto 0); -- Operand B
        alu_operation : in std_logic_vector(3 downto 0); -- Selects the type of operation

        zero_flag : out std_logic; -- Flag Zero
        alu_result : out std_logic_vector(31 downto 0) --The result given from the operation
    );

end entity ALU;

architecture main of ALU is

    --Signals used in the middle of the process
    signal result : std_logic_vector(31 downto 0);
begin

    ALU_calculation : process(operator_a, operator_b, alu_operation)
    begin
        -- Does the calculations
        case alu_operation is
            --Addition 
            when "0000" =>
                result <= std_logic_vector(signed(operator_a) + signed(operator_b));
            --Subtraction 
            when "0001" =>
                result <= std_logic_vector(signed(operator_a) - signed(operator_b));
            --AND
            when "0010" =>
                result <= operator_a and operator_b;
            --OR 
            when "0011" =>
                result <= operator_a or operator_b;
            --XOR 
            when "0100" =>
                result <= operator_a xor operator_b;
            --Shift left 
            when "0101" =>
                result <= std_logic_vector(shift_left(unsigned(operator_a), to_integer(unsigned(operator_b(4 downto 0)))));
            --Shift right  
            when "0110" =>
                result <= std_logic_vector(shift_right(unsigned(operator_a), to_integer(unsigned(operator_b(4 downto 0)))));
            --Pass B with a 12 bit shift
            when "0111" =>
                result <= operator_b(19 downto 0) & x"000";
            when others =>
                result <= (others => '0');
        end case;
    end process ALU_calculation;

    --Gives final outputs
    alu_result <= result;
    zero_flag <= '1' when unsigned(result) = 0 else '0';


end architecture main;