library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
    port (
        --What the control unit receives
        opcode : in std_logic_vector(6 downto 0);
        funct3 : in std_logic_vector(2 downto 0);
        funct7 : in std_logic_vector(6 downto 0);

        --Outputs that make the instructions work properly
        branch : out std_logic; -- Decides on whether to Branch or not
        mem_read : out std_logic; -- Decides if the memory will be read
        mem_to_reg : out std_logic; -- Decides if the output from the memory will come to a register
        ALU_op : out std_logic_vector(3 downto 0); -- Code that decides the operation in the ALU
        mem_write : out std_logic; -- Decides if the memory will be written
        ALU_src : out std_logic; -- Decides the source to the ALU
        reg_write : out std_logic; -- Decides if the register will be written
        jump : out std_logic; -- Sinalizes the JUMP instruction
        jalr : out std_logic; -- Sinalizes the JALR instruction
        aiupc : out std_logic -- Sinalizes the AIUPC command

    );
end entity;

architecture rtl of control_unit is

begin

control_system : process(opcode, funct3, funct7)
begin
    --Values if it were a NOP (all 0)
    branch <= '0';
    mem_read <= '0';
    mem_to_reg <= '0';
    ALU_op <= "0000";
    mem_write <= '0';
    ALU_src <= '0';
    reg_write <= '0';
    jalr <= '0';
    jump <= '0';
    aiupc <= '0';
    --Analyzes the Opcode and the different types of instructions
    case opcode is
        --R-Type
        when "0110011" =>
            --Sets the otputs according to what R instructions need
            reg_write <= '1';
            --Sets the ALU_op
            case funct3 is
                --Addition and Subtraction
                when "000"=>
                    if funct7 = "0000000" then
                        ALU_op <= "0000"; --ADD
                    elsif funct7 = "0100000" then
                        ALU_op <= "0001";
                    end if;
                --AND
                when "111" =>
                    ALU_op <= "0010";
                --OR
                when "110" =>
                    ALU_op <= "0011";
                --XOR
                when "100" =>
                    ALU_op <= "0100";
                --Shift Left
                when "001" =>
                    ALU_op <= "0101";
                --Shift Right
                when "101" =>
                    ALU_op <= "0110";
                when others =>
                    null;
            end case;
        --I-Type (Normal Operations)
        when "0010011" =>
            --Sets the otputs according to what I instructions need
            ALU_src <= '1';
            reg_write <= '1';
            --Sets the ALU_op
            case funct3 is
                --Addition
                when "000"=>
                    ALU_op <= "0000"; --ADD
                --AND
                when "111" =>
                    ALU_op <= "0010";
                --OR
                when "110" =>
                    ALU_op <= "0011";
                --XOR
                when "100" =>
                    ALU_op <= "0100";
                --Shift Left
                when "001" =>
                    ALU_op <= "0101";
                --Shift Right
                when "101" =>
                    ALU_op <= "0110";
                when others =>
                    null;
            end case;
        --I-Type (Load Word)
        when "0000011" =>
            mem_read <= '1';
            mem_to_reg <= '1';
            reg_write <= '1';
            ALU_src <= '1';
            ALU_op <= "0000";

        --I-Type (jalr)
        when "1100111" =>
            reg_write <= '1';
            jump <= '1';
            jalr <= '1';
            ALU_src <= '1';
            ALU_op <= "0000";
            
        --S-Type (Store)
        when "0100011" =>
            mem_write <= '1';
            ALU_src <= '1';
            ALU_op <= "0000";

        --B-Type (Branch)=>
        when "1100011" =>
            branch <= '1';
            -- The ALU operation is defined as subtraction to compare the values
            ALU_op <= "0001";
        --U-Type (lui)
        when "0110111" =>
            reg_write <= '1';
            ALU_src <= '1';
            ALU_op <= "0111";
        --U-Type (auipc)
        when "0010111" =>
            reg_write <= '1';
            ALU_src <= '1';
            ALU_op <= "0000";
            aiupc <= '1';
        --J-Type
        when "1101111" =>
            reg_write <= '1';
            ALU_op <= "0000";
            jump <= '1';
        when others =>
            null;
    end case;


end process control_system;

    

end architecture;