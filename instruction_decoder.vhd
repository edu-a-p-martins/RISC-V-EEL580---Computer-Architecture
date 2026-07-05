library ieee;
use ieee.std_logic_1164.all;

entity instruction_decoder is
    port (
        instruction : in std_logic_vector(31 downto 0);
        --Outputs 
        opcode : out std_logic_vector(6 downto 0);
        funct3 : out std_logic_vector(2 downto 0);
        funct7 : out std_logic_vector(6 downto 0);
        register1 : out std_logic_vector(4 downto 0);
        register2 : out std_logic_vector(4 downto 0);
        registerdestination : out std_logic_vector(4 downto 0);
        immediate : out std_logic_vector(31 downto 0) -- Expanded immediate number
        
    );
end entity;

architecture rtl of instruction_decoder is

begin
    
    --Extracting all of the information out of the instructions
    opcode <= instruction(6 downto 0);
    funct3 <= instruction(14 downto 12);
    funct7 <= instruction(31 downto 25);
    register1 <= instruction(19 downto 15);
    register2 <= instruction(24 downto 20);
    registerdestination <= instruction(11 downto 7);
    
    --Determines the value of the immediate depending on the type of instruction
    immediate_determination : process(instruction)
    begin
        case instruction(6 downto 0) is
            --I-Type
            when "0010011" or "0000011" or "1100111" =>
                immediate <= (31 downto 12 => instruction(31)) & instruction(31 downto 20);
            --S-Type
            when "0100011" =>
                immediate <= (31 downto 12 => instruction(31)) & instruction(31 downto 25) & instruction(11 downto 7);
            -- B-Type (beq, bne)
            when "1100011" =>
                immediate <= (31 downto 13 => instruction(31)) & instruction(31) & instruction(7) & instruction(30 downto 25) & instruction(11 downto 8) & '0';
            -- U-Type (lui, auipc)
            when "0110111" or "0010111" => 
                immediate <= instruction(31 downto 12) & (11 downto 0 => '0');
            -- J-Type (jal)
            when "1101111" =>
                immediate <= (31 downto 21 => instruction(31)) & instruction(31) & instruction(19 downto 12) & instruction(20) & instruction(30 downto 21) & '0';
            when others =>
                immediate <= (others => '0');
        end case;
    end process;
    


end architecture;
