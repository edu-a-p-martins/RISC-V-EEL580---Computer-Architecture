library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
    port (
        --What the control unit receives
        opcode_i : in std_logic_vector(6 downto 0);
        funct3_i : in std_logic_vector(2 downto 0);
        funct7_i : in std_logic_vector(6 downto 0);

        --Outputs that make the instructions work properly
        reg_write_o : out std_logic; -- Decides if the register will be written
        mem_to_reg_o : out std_logic; -- Decides if the output from the memory will come to a register
        mem_write_o : out std_logic; -- Decides if the memory will be written
        mem_read_o : out std_logic; -- Decides if the memory will be read
        alu_src_o : out std_logic; -- Decides the source to the ALU
        alu_ctrl_o : out std_logic_vector(3 downto 0); -- Code that decides the operation in the ALU
        branch_o : out std_logic; -- Decides on whether to branch_o or not
        jump_o : out std_logic; -- Sinalizes the jump instruction
        auipc_o : out std_logic; -- Sinalizes the auipc command
        jalr_o : out std_logic; -- Sinalizes the jalr instruction
        lui_o  : out std_logic; -- Sinalizes the lui instruction
        --Outputs that are related to the vectorial instructions
        vector_instruction_o : out std_logic; --Sinalizes that the instruction is vectorial
        vec_reg_write_o : out std_logic; --Analog to reg_wrte_o but for vectorial registers
        vec_alu_src_o : out std_logic; --Decides the source of the vectorial ALU
        vec_alu_ctrl_o : out std_logic_vector(3 downto 0); --Decides the operation in the ALU
        vauipc_o : out std_logic --Sinalizes the vauipc command
    );
end entity;

architecture rtl of control_unit is

begin

control_system : process(opcode_i, funct3_i, funct7_i)
begin
    --Values if it were a NOP (all 0)
    branch_o <= '0';
    mem_read_o <= '0';
    mem_to_reg_o <= '0';
    alu_ctrl_o <= "0000";
    mem_write_o <= '0';
    alu_src_o <= '0';
    reg_write_o <= '0';
    jalr_o <= '0';
    jump_o <= '0';
    auipc_o <= '0';
    lui_o <= '0';
    vector_instruction_o <= '0';
    vec_reg_write_o <= '0';
    vec_alu_src_o <= '0';
    vec_alu_ctrl_o <= "0000";
    vauipc_o <= '0';

    --Analyzes the opcode_i and the different types of instructions
    case opcode_i is
        --R-Type
        when "0110011" =>
            --Sets the otputs according to what R instructions need
            reg_write_o <= '1';
            --Sets the alu_ctrl_o
            case funct3_i is
                --Addition and Subtraction
                when "000"=>
                    if funct7_i = "0000000" then
                        alu_ctrl_o <= "0000"; --ADD
                    elsif funct7_i = "0100000" then
                        alu_ctrl_o <= "0001";
                    end if;
                --AND
                when "111" =>
                    alu_ctrl_o <= "0010";
                --OR
                when "110" =>
                    alu_ctrl_o <= "0011";
                --XOR
                when "100" =>
                    alu_ctrl_o <= "0100";
                --Shift Left
                when "001" =>
                    alu_ctrl_o <= "0101";
                --Shift Right
                when "101" =>
                    alu_ctrl_o <= "0110";
                when others =>
                    null;
            end case;
        --I-Type (Normal Operations)
        when "0010011" =>
            --Sets the otputs according to what I instructions need
            alu_src_o <= '1';
            reg_write_o <= '1';
            --Sets the alu_ctrl_o
            case funct3_i is
                --Addition
                when "000"=>
                    alu_ctrl_o <= "0000"; --ADD
                --AND
                when "111" =>
                    alu_ctrl_o <= "0010";
                --OR
                when "110" =>
                    alu_ctrl_o <= "0011";
                --XOR
                when "100" =>
                    alu_ctrl_o <= "0100";
                --Shift Left
                when "001" =>
                    alu_ctrl_o <= "0101";
                --Shift Right
                when "101" =>
                    alu_ctrl_o <= "0110";
                when others =>
                    null;
            end case;
        --I-Type (Load Word)
        when "0000011" =>
            mem_read_o <= '1';
            mem_to_reg_o <= '1';
            reg_write_o <= '1';
            alu_src_o <= '1';
            alu_ctrl_o <= "0000";

        --I-Type (jalr_o)
        when "1100111" =>
            reg_write_o <= '1';
            jump_o <= '1';
            jalr_o <= '1';
            alu_src_o <= '1';
            alu_ctrl_o <= "0000";
            
        --S-Type (Store)
        when "0100011" =>
            mem_write_o <= '1';
            alu_src_o <= '1';
            alu_ctrl_o <= "0000";

        --B-Type (branch_o)=>
        when "1100011" =>
            branch_o <= '1';
            -- The ALU operation is defined as subtraction to compare the values
            alu_ctrl_o <= "0001";
        --U-Type (lui_o)
        when "0110111" =>
            reg_write_o <= '1';
            alu_src_o <= '1';
            alu_ctrl_o <= "0111";
            lui_o <= '1';
        --U-Type (auipc_o)
            when "0010111" =>
            reg_write_o <= '1';
            alu_src_o <= '1';
            alu_ctrl_o <= "0000";
            auipc_o <= '1';
        --J-Type
        when "1101111" =>
            reg_write_o <= '1';
            alu_ctrl_o <= "0000";
            jump_o <= '1';
        --Vectorial R-Type
        when "01101100" =>
            vector_instruction_o <= '1';
            vec_reg_write_o <= '1';

            --Sets the alu_ctrl_o
            case funct3_i is
                --Addition and Subtraction
                when "000"=>
                    if funct7_i = "0000000" then
                        vec_alu_ctrl_o <= "0000"; --ADD
                    elsif funct7_i = "0100000" then
                        vec_alu_ctrl_o <= "0001";
                    end if;
                --Shift Left
                when "001" =>
                    vec_alu_ctrl_o <= "0010";
                --Shift Right
                when "101" =>
                    vec_alu_ctrl_o <= "0011";
                when others =>
                    null;
            end case;
        --Vectorial I-Type
        when "01111100" =>
            vector_instruction_o <= '1';
            vec_alu_src_o <= '1';
            vec_reg_write_o <= '1';

            --Sets the alu_ctrl_o
            case funct3_i is
                --Addition and Subtraction
                when "000"=>
                    if funct7_i = "0000000" then
                        vec_alu_ctrl_o <= "0000"; --ADD
                    elsif funct7_i = "0100000" then
                        vec_alu_ctrl_o <= "0001";
                    end if;
                --Shift Left
                when "001" =>
                    vec_alu_ctrl_o <= "0010";
                --Shift Right
                when "101" =>
                    vec_alu_ctrl_o <= "0011";
                when others =>
                    null;
            end case;
        --Vectorial AIUPC
        when "11111100" =>
            vauipc_o <= '1';
            vector_instruction_o <= '1'; 
            vec_reg_write_o <= '1';
            vec_alu_ctrl_o <= "0000";
            vec_alu_src_o <= '1';

        when others =>
            null;
    end case;


end process control_system;

    

end architecture;