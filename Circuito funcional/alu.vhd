library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity alu is

    port(
        a_i  : in std_logic_vector(31 downto 0); -- Operand A
        b_i  : in std_logic_vector(31 downto 0); -- Operand B
        alu_ctrl_i : in std_logic_vector(3 downto 0); -- Selects the type of operation  
        result_o : out std_logic_vector(31 downto 0); --The result given from the operation
        zero_o : out std_logic; -- Flag Zero      
        carry_o    : out std_logic;                      -- carry 
        overflow_o : out std_logic                       -- overflow
        );

end entity alu;

architecture main of alu is

    -- Constantes para controle da ALU
    constant ALU_ADD    : std_logic_vector(3 downto 0) := "0000";
    constant ALU_SUB    : std_logic_vector(3 downto 0) := "0001";
    constant ALU_AND    : std_logic_vector(3 downto 0) := "0010";
    constant ALU_OR     : std_logic_vector(3 downto 0) := "0011";
    constant ALU_XOR    : std_logic_vector(3 downto 0) := "0100";
    constant ALU_SLL    : std_logic_vector(3 downto 0) := "0101";
    constant ALU_SRL    : std_logic_vector(3 downto 0) := "0110";
    constant ALU_PASS_B : std_logic_vector(3 downto 0) := "0111";

    -- Sinais internos para cálculo e flags
    signal result_internal : std_logic_vector(31 downto 0);
    signal add_result      : std_logic_vector(32 downto 0);
    signal sub_result      : std_logic_vector(32 downto 0);
    signal shamt           : natural range 0 to 31;
begin

    shamt <= to_integer(unsigned(b_i(4 downto 0)));
    add_result <= std_logic_vector(unsigned('0' & a_i) + unsigned('0' & b_i));
    sub_result <= std_logic_vector(unsigned('0' & a_i) - unsigned('0' & b_i));

    ALU_calculation : process(a_i, b_i, alu_ctrl_i, add_result, sub_result, shamt)
    begin
        case alu_ctrl_i is
            when ALU_ADD =>
                result_internal <= add_result(31 downto 0);
            when ALU_SUB =>
                result_internal <= sub_result(31 downto 0);
            when ALU_AND =>
                result_internal <= a_i and b_i;
            when ALU_OR =>
                result_internal <= a_i or b_i;
            when ALU_XOR =>
                result_internal <= a_i xor b_i;
            when ALU_SLL =>
                result_internal <= std_logic_vector(shift_left(unsigned(a_i), shamt));
            when ALU_SRL =>
                result_internal <= std_logic_vector(shift_right(unsigned(a_i), shamt));
            when ALU_PASS_B =>
                result_internal <= b_i;
            when others =>
                result_internal <= (others => '0');
        end case;
    end process ALU_calculation;

    result_o <= result_internal;
    zero_o <= '1' when result_internal = x"00000000" else '0';
    carry_o <= add_result(32) when alu_ctrl_i = ALU_ADD else '0';
    overflow_o <= ((not a_i(31) and not b_i(31) and result_internal(31)) or
                   (a_i(31) and b_i(31) and not result_internal(31)))
                  when alu_ctrl_i = ALU_ADD else '0';

end architecture main;