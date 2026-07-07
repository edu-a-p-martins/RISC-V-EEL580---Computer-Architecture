library ieee;
use ieee.std_logic_1164.all;

entity instruction_decoder is
    port (
        instruction_i : in std_logic_vector(31 downto 0);
        --Outputs 
        opcode_o : out std_logic_vector(6 downto 0);
        funct3_o : out std_logic_vector(2 downto 0);
        funct7_o : out std_logic_vector(6 downto 0);
        rs1_o : out std_logic_vector(4 downto 0);
        rs2_o : out std_logic_vector(4 downto 0);
        rd_o : out std_logic_vector(4 downto 0);
        imm_o : out std_logic_vector(31 downto 0); -- Expanded imm_o number
        instr_type_o  : out std_logic_vector(2 downto 0)
    );
end entity;

architecture rtl of instruction_decoder is

    constant TYPE_R : std_logic_vector(3 downto 0) := "0000";
    constant TYPE_I : std_logic_vector(3 downto 0) := "0001";
    constant TYPE_S : std_logic_vector(3 downto 0) := "0010";
    constant TYPE_B : std_logic_vector(3 downto 0) := "0011";
    constant TYPE_U : std_logic_vector(3 downto 0) := "0100";
    constant TYPE_J : std_logic_vector(3 downto 0) := "0101";
    constant TYPE_VR : std_logic_vector(3 downto 0) := "0110";
    constant TYPE_VI : std_logic_vector(3 downto 0) := "0111";
    constant TYPE_VAUIPC : std_logic_vector(3 downto 0) := "1000";

begin
    
    --Extracting all of the information out of the instruction_is
    opcode_o <= instruction_i(6 downto 0);
    funct3_o <= instruction_i(14 downto 12);
    funct7_o <= instruction_i(31 downto 25);
    rs1_o <= instruction_i(19 downto 15);
    rs2_o <= instruction_i(24 downto 20);
    rd_o <= instruction_i(11 downto 7);
    instr_type_o <= TYPE_R; -- Default value, will be updated based on instruction type

    --Determines the value of the imm_o depending on the type of instruction_i
    imm_o_determination : process(instruction_i)
    begin
        case instruction_i(6 downto 0) is
            --I-Type
            when "0010011" | "0000011" | "1100111" =>
                imm_o <= (31 downto 12 => instruction_i(31)) & instruction_i(31 downto 20);
                instr_type_o <= TYPE_I;
            --S-Type
            when "0100011" =>
                imm_o <= (31 downto 12 => instruction_i(31)) & instruction_i(31 downto 25) & instruction_i(11 downto 7);
                instr_type_o <= TYPE_S;
            -- B-Type (beq, bne)
            when "1100011" =>
                imm_o <= (31 downto 13 => instruction_i(31)) & instruction_i(31) & instruction_i(7) & instruction_i(30 downto 25) & instruction_i(11 downto 8) & '0';
                instr_type_o <= TYPE_B;
            -- U-Type (lui, auipc)
            when "0110111" | "0010111" => 
                imm_o <= instruction_i(31 downto 12) & (11 downto 0 => '0');
                instr_type_o <= TYPE_U;
            -- J-Type (jal)
            when "1101111" =>
                imm_o <= (31 downto 21 => instruction_i(31)) & instruction_i(31) & instruction_i(19 downto 12) & instruction_i(20) & instruction_i(30 downto 21) & '0';
                instr_type_o <= TYPE_J;
            -- Vectorial R-Type 
            when "01101100" =>
                instr_type_o <= TYPE_VR;
            -- Vectorial I-Type
            when "01111100" =>
                imm_o <= (31 downto 12 => instruction_i(31)) & instruction_i(31 downto 20);
                instr_type_o <= TYPE_VI;
            -- Vectorial AIUPC
            when "11111100" =>
                imm_o <= instruction_i(31 downto 12) & (11 downto 0 => '0');
                instr_type_o <= TYPE_VAUIPC;
            when others =>
                imm_o <= (others => '0');
        end case;
    end process;
    


end architecture;