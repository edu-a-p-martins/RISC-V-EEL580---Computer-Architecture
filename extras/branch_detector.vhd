
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity branch_detector is
    port (
        a_i            : in  std_logic_vector(31 downto 0);
        b_i            : in  std_logic_vector(31 downto 0);
        funct3_i       : in  std_logic_vector(2 downto 0);
        branch_i       : in  std_logic;
        branch_taken_o : out std_logic;
        --debug
        eq_o           : out std_logic;
        ne_o           : out std_logic;
        lt_o           : out std_logic;
        ge_o           : out std_logic;
        ltu_o          : out std_logic; 
        geu_o          : out std_logic 
    );
end entity branch_detector;

architecture rtl of branch_detector is

    constant FUNCT3_BEQ  : std_logic_vector(2 downto 0) := "000";
    constant FUNCT3_BNE  : std_logic_vector(2 downto 0) := "001";
    constant FUNCT3_BLT  : std_logic_vector(2 downto 0) := "100";
    constant FUNCT3_BGE  : std_logic_vector(2 downto 0) := "101";
    constant FUNCT3_BLTU : std_logic_vector(2 downto 0) := "110";
    constant FUNCT3_BGEU : std_logic_vector(2 downto 0) := "111";

    signal is_equal     : std_logic;
    signal is_not_equal : std_logic;
    signal is_lt_s      : std_logic;
    signal is_ge_s      : std_logic;
    signal is_lt_u      : std_logic;
    signal is_ge_u      : std_logic;

begin

    is_equal     <= '1' when a_i = b_i else '0';
    is_not_equal <= not is_equal;

    is_lt_s <= '1' when signed(a_i) < signed(b_i) else '0';
    is_ge_s <= not is_lt_s;

    is_lt_u <= '1' when unsigned(a_i) < unsigned(b_i) else '0';
    is_ge_u <= not is_lt_u;


    eq_o  <= is_equal;
    ne_o  <= is_not_equal;
    lt_o  <= is_lt_s;
    ge_o  <= is_ge_s;
    ltu_o <= is_lt_u;
    geu_o <= is_ge_u;


    branch_detection : process(branch_i, funct3_i, is_equal, is_not_equal, is_lt_s, is_ge_s, is_lt_u, is_ge_u)
    begin
        branch_taken_o <= '0';

        if branch_i = '1' then
            case funct3_i is
                when FUNCT3_BEQ  => branch_taken_o <= is_equal;
                when FUNCT3_BNE  => branch_taken_o <= is_not_equal;
                when FUNCT3_BLT  => branch_taken_o <= is_lt_s;
                when FUNCT3_BGE  => branch_taken_o <= is_ge_s;
                when FUNCT3_BLTU => branch_taken_o <= is_lt_u;
                when FUNCT3_BGEU => branch_taken_o <= is_ge_u;
                when others      => branch_taken_o <= '0';
            end case;
        end if;
    end process branch_detection;

end architecture rtl;
