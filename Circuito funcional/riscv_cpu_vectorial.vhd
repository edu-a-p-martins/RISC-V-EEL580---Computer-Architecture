library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity riscv_cpu_vector is
    port (
        clk_i           : in  std_logic;
        reset_i         : in  std_logic;
        load_enable_i   : in  std_logic; 
        
        dmem_addr_o     : out std_logic_vector(31 downto 0); --RAM MEMORY ADDRESS
        dmem_wdata_o    : out std_logic_vector(31 downto 0); --RAM MEMORY WRITE DATA
        dmem_rdata_i    : in  std_logic_vector(31 downto 0); --RAM MEMORY READ DATA
        dmem_we_o       : out std_logic;
        
        imem_addr_o     : out std_logic_vector(31 downto 0); -- ROM MEMORY ADDRESS
        imem_data_i     : in  std_logic_vector(31 downto 0); -- ROM MEMORY DATA
        
        
        -- VARIABLES FOCUSED ON DEBUGGING
        pc_debug_o      : out std_logic_vector(31 downto 0);
        instr_debug_o   : out std_logic_vector(31 downto 0);
        alu_result_debug_o : out std_logic_vector(31 downto 0);
        reg_debug_o     : out std_logic_vector(31 downto 0);
        reg_sel_i       : in  std_logic_vector(4 downto 0);
        stage_if_pc_o   : out std_logic_vector(31 downto 0);
        stage_id_pc_o   : out std_logic_vector(31 downto 0);
        stage_ex_pc_o   : out std_logic_vector(31 downto 0);
        hazard_stall_o  : out std_logic;
        hazard_flush_o  : out std_logic;
        
        -- VARIABLES FOCUSED ON DEBUGGING (VECTORIAL)
        vreg_debug_lane0_o  : out std_logic_vector(31 downto 0);
        vreg_debug_lane1_o  : out std_logic_vector(31 downto 0);
        vreg_debug_lane2_o  : out std_logic_vector(31 downto 0);
        vreg_debug_lane3_o  : out std_logic_vector(31 downto 0);
        vreg_sel_i          : in  std_logic_vector(4 downto 0);
        valu_result_lane0_o : out std_logic_vector(31 downto 0);
        valu_result_lane1_o : out std_logic_vector(31 downto 0);
        valu_result_lane2_o : out std_logic_vector(31 downto 0);
        valu_result_lane3_o : out std_logic_vector(31 downto 0)
        );
    end entity riscv_cpu_vector;
    
    architecture rtl of riscv_cpu_vector is
        
    -- Hazard Control
    signal stall_if       : std_logic;
    signal stall_id       : std_logic;
    signal flush_id       : std_logic;
    signal flush_ex       : std_logic;
    signal hazard_type    : std_logic_vector(1 downto 0);
        
    -- IF Signals
    signal if_pc          : std_logic_vector(31 downto 0);
    signal if_pc_plus4    : std_logic_vector(31 downto 0);
    signal if_instruction : std_logic_vector(31 downto 0);
        
    --IF/ID Registers
    signal id_pc          : std_logic_vector(31 downto 0);
    signal id_instruction : std_logic_vector(31 downto 0);
    signal id_pc_plus4    : std_logic_vector(31 downto 0);
    
    --ID SIgnals
    signal id_opcode      : std_logic_vector(6 downto 0);
    signal id_rd          : std_logic_vector(4 downto 0);
    signal id_funct3      : std_logic_vector(2 downto 0);
    signal id_rs1         : std_logic_vector(4 downto 0);
    signal id_rs2         : std_logic_vector(4 downto 0);
    signal id_funct7      : std_logic_vector(6 downto 0);
    signal id_imm         : std_logic_vector(31 downto 0);
    signal id_instr_type  : std_logic_vector(2 downto 0);
    signal id_is_vector   : std_logic;
    signal id_rs1_data    : std_logic_vector(31 downto 0);
    signal id_rs2_data    : std_logic_vector(31 downto 0);
    signal id_reg_write   : std_logic;
    signal id_mem_to_reg  : std_logic;
    signal id_mem_write   : std_logic;
    signal id_mem_read    : std_logic;
    signal id_alu_src     : std_logic;
    signal id_alu_ctrl    : std_logic_vector(3 downto 0);
    signal id_branch      : std_logic;
    signal id_jump        : std_logic;
    signal id_auipc       : std_logic;
    signal id_jalr        : std_logic;
    signal id_lui         : std_logic;
    
    -- Vectorial ID variables
    signal id_ctrl_is_vector : std_logic;
    signal id_vreg_write  : std_logic;
    signal id_valu_ctrl   : std_logic_vector(3 downto 0);
    signal id_valu_src    : std_logic;
    signal id_vauipc      : std_logic;
    
    -- Dados vetoriais do ID
    signal id_vs1_data    : std_logic_vector(127 downto 0);
    signal id_vs2_data    : std_logic_vector(127 downto 0);
    
    -- ID/EX Signals
    signal ex_pc          : std_logic_vector(31 downto 0);
    signal ex_pc_plus4    : std_logic_vector(31 downto 0);
    signal ex_rs1_data    : std_logic_vector(31 downto 0);
    signal ex_rs2_data    : std_logic_vector(31 downto 0);
    signal ex_imm         : std_logic_vector(31 downto 0);
    signal ex_rs1_addr    : std_logic_vector(4 downto 0);
    signal ex_rs2_addr    : std_logic_vector(4 downto 0);
    signal ex_rd_addr     : std_logic_vector(4 downto 0);
    signal ex_funct3      : std_logic_vector(2 downto 0);
    signal ex_reg_write   : std_logic;
    signal ex_mem_to_reg  : std_logic;
    signal ex_mem_write   : std_logic;
    signal ex_mem_read    : std_logic;
    signal ex_alu_src     : std_logic;
    signal ex_alu_ctrl    : std_logic_vector(3 downto 0);
    signal ex_branch      : std_logic;
    signal ex_jump        : std_logic;
    signal ex_auipc       : std_logic;
    signal ex_jalr        : std_logic;
    signal ex_lui         : std_logic;
    
    -- Vectorial ID/EX Signals
    signal ex_vs1_data    : std_logic_vector(127 downto 0);
    signal ex_vs2_data    : std_logic_vector(127 downto 0);
    signal ex_is_vector   : std_logic;
    signal ex_vreg_write  : std_logic;
    signal ex_valu_ctrl   : std_logic_vector(3 downto 0);
    signal ex_valu_src    : std_logic;
    signal ex_vauipc      : std_logic;
    
    -- EX Signals
    signal ex_alu_a       : std_logic_vector(31 downto 0);
    signal ex_alu_b       : std_logic_vector(31 downto 0);
    signal ex_alu_result  : std_logic_vector(31 downto 0);
    signal ex_alu_zero    : std_logic;
    signal ex_branch_taken: std_logic;
    signal ex_target_addr : std_logic_vector(31 downto 0);
    signal ex_forward_a   : std_logic_vector(1 downto 0);
    signal ex_forward_b   : std_logic_vector(1 downto 0);
    signal ex_rs1_forwarded : std_logic_vector(31 downto 0);
    signal ex_rs2_forwarded : std_logic_vector(31 downto 0);
    
    -- Vectorial EX Signals
    signal ex_valu_a      : std_logic_vector(127 downto 0);
    signal ex_valu_b      : std_logic_vector(127 downto 0);
    signal ex_valu_result : std_logic_vector(127 downto 0);
    signal ex_vforward_a  : std_logic_vector(1 downto 0);
    signal ex_vforward_b  : std_logic_vector(1 downto 0);
    signal ex_vs1_forwarded : std_logic_vector(127 downto 0);
    signal ex_vs2_forwarded : std_logic_vector(127 downto 0);
    
    -- MEM Signals
    signal mem_pc_plus4   : std_logic_vector(31 downto 0);
    signal mem_alu_result : std_logic_vector(31 downto 0);
    signal mem_rs2_data   : std_logic_vector(31 downto 0);
    signal mem_rd_addr    : std_logic_vector(4 downto 0);
    signal mem_zero       : std_logic;
    signal mem_reg_write  : std_logic;
    signal mem_mem_to_reg : std_logic;
    signal mem_mem_write  : std_logic;
    signal mem_mem_read   : std_logic;
    signal mem_branch     : std_logic;
    signal mem_jump       : std_logic;
    signal mem_read_data  : std_logic_vector(31 downto 0);
    
    -- Vectorial MEM Signals
    signal mem_valu_result : std_logic_vector(127 downto 0);
    signal mem_vrd_addr    : std_logic_vector(4 downto 0);
    signal mem_is_vector   : std_logic;
    signal mem_vreg_write  : std_logic;
    
    
    -- MEM/WB Signals
    signal wb_pc_plus4    : std_logic_vector(31 downto 0);
    signal wb_alu_result  : std_logic_vector(31 downto 0);
    signal wb_mem_data    : std_logic_vector(31 downto 0);
    signal wb_rd_addr     : std_logic_vector(4 downto 0);
    signal wb_reg_write   : std_logic;
    signal wb_mem_to_reg  : std_logic;
    signal wb_jump        : std_logic;
    
    -- Vectorial MEM/WB Signals
    signal wb_valu_result : std_logic_vector(127 downto 0);
    signal wb_vrd_addr    : std_logic_vector(4 downto 0);
    signal wb_vreg_write  : std_logic;
    
    -- WB Signals
    signal wb_write_data  : std_logic_vector(31 downto 0);
    

    signal vreg_debug_internal : std_logic_vector(127 downto 0); --Vectorial debug

    -- Function created with the sole purpose of expanding the immediate to a vector
    function imm_vector(immediate : std_logic_vector(31 downto 0)) 
        return std_logic_vector is
    begin
        return immediate & immediate & immediate & immediate;
    end function;

begin

    -- Initialization of the Program Counter
    Program_Counter : entity work.program_counter
        port map (
            clk_i          => clk_i,
            reset_i        => reset_i,
            stall_i        => stall_if,
            load_enable_i  => load_enable_i,
            branch_taken_i => ex_branch_taken,
            jump_i         => ex_jump,
            target_addr_i  => ex_target_addr,
            pc_o           => if_pc,
            pc_plus4_o     => if_pc_plus4
        );
    imem_addr_o    <= if_pc;
    if_instruction <= imem_data_i;
    
    --IF/ID Register
    IF_ID_Register : entity work.if_id_reg
        port map (
            clk_i         => clk_i,
            reset_i       => reset_i,
            stall_i       => stall_id,
            flush_i       => flush_id,
            load_enable_i => load_enable_i,
            pc_i          => if_pc,
            pc_plus4_i    => if_pc_plus4,
            instruction_i => if_instruction,
            pc_o          => id_pc,
            pc_plus4_o    => id_pc_plus4,
            instruction_o => id_instruction
        );
            
    --Initialization of the Instruction Decoder component
    Instruction_Decoder : entity work.instruction_decoder
        port map (
            instruction_i => id_instruction,
            opcode_o      => id_opcode,
            rd_o          => id_rd,
            funct3_o      => id_funct3,
            rs1_o         => id_rs1,
            rs2_o         => id_rs2,
            funct7_o      => id_funct7,
            imm_o         => id_imm,
            instr_type_o  => id_instr_type
        );
    --Initialization of the Control Unity
    U_CONTROL : entity work.control_unit
        port map (
            opcode_i     => id_opcode,
            funct3_i     => id_funct3,
            funct7_i     => id_funct7,
            reg_write_o  => id_reg_write,
            mem_to_reg_o => id_mem_to_reg,
            mem_write_o  => id_mem_write,
            mem_read_o   => id_mem_read,
            alu_src_o    => id_alu_src,
            alu_ctrl_o   => id_alu_ctrl,
            branch_o     => id_branch,
            jump_o       => id_jump,
            auipc_o      => id_auipc,
            jalr_o       => id_jalr,
            lui_o        => id_lui,
            vector_instruction_o  => id_ctrl_is_vector,
            vec_reg_write_o => id_vreg_write,
            vec_alu_ctrl_o  => id_valu_ctrl,
            vec_alu_src_o   => id_valu_src,
            vauipc_o     => id_vauipc
        );
    
    -- Initialization of the Register File
    Register_File : entity work.register_file
        port map (
            clk_i       => clk_i,
            reset_i     => reset_i,
            we_i        => wb_reg_write,
            rs1_addr_i  => id_rs1,
            rs2_addr_i  => id_rs2,
            rd_addr_i   => wb_rd_addr,
            rd_data_i   => wb_write_data,
            rs1_data_o  => id_rs1_data,
            rs2_data_o  => id_rs2_data,
            reg_debug_o => reg_debug_o,
            reg_sel_i   => reg_sel_i
        );
    
    --Initialization of the Vectorial Register File
    Vectorial_Register_File : entity work.vectorial_register_file
        port map (
            clk_i        => clk_i,
            reset_i      => reset_i,
            we_i         => wb_vreg_write,
            vrs1_addr_i   => id_rs1,
            vrs2_addr_i   => id_rs2,
            vrd_addr_i    => wb_vrd_addr,
            vrd_data_i    => wb_valu_result,
            vrs1_data_o   => id_vs1_data,
            vrs2_data_o   => id_vs2_data,
            vreg_debug_o => vreg_debug_internal,
            vreg_sel_i   => vreg_sel_i
        );
    
    --ID/EX Register
    ID_EX_Register : entity work.id_ex_reg
        port map (
            clk_i         => clk_i,
            reset_i       => reset_i,
            stall_i       => '0',
            flush_i       => flush_ex,
            load_enable_i => load_enable_i,
            pc_i          => id_pc,
            pc_plus4_i    => id_pc_plus4,
            rs1_data_i    => id_rs1_data,
            rs2_data_i    => id_rs2_data,
            imm_i         => id_imm,
            rs1_addr_i    => id_rs1,
            rs2_addr_i    => id_rs2,
            rd_addr_i     => id_rd,
            funct3_i      => id_funct3,
            reg_write_i   => id_reg_write,
            mem_to_reg_i  => id_mem_to_reg,
            mem_write_i   => id_mem_write,
            mem_read_i    => id_mem_read,
            alu_src_i     => id_alu_src,
            alu_ctrl_i    => id_alu_ctrl,
            branch_i      => id_branch,
            jump_i        => id_jump,
            auipc_i       => id_auipc,
            jalr_i        => id_jalr,
            lui_i         => id_lui,
            pc_o          => ex_pc,
            pc_plus4_o    => ex_pc_plus4,
            rs1_data_o    => ex_rs1_data,
            rs2_data_o    => ex_rs2_data,
            imm_o         => ex_imm,
            rs1_addr_o    => ex_rs1_addr,
            rs2_addr_o    => ex_rs2_addr,
            rd_addr_o     => ex_rd_addr,
            funct3_o      => ex_funct3,
            reg_write_o   => ex_reg_write,
            mem_to_reg_o  => ex_mem_to_reg,
            mem_write_o   => ex_mem_write,
            mem_read_o    => ex_mem_read,
            alu_src_o     => ex_alu_src,
            alu_ctrl_o    => ex_alu_ctrl,
            branch_o      => ex_branch,
            jump_o        => ex_jump,
            auipc_o       => ex_auipc,
            jalr_o        => ex_jalr,
            lui_o         => ex_lui
        );
    
    -- Vectorial ID/EX Register
    ID_EX_Vectorial_Register : entity work.id_ex_vreg
        port map (
            clk_i         => clk_i,
            reset_i       => reset_i,
            stall_i       => '0',
            flush_i       => flush_ex,
            load_enable_i => load_enable_i,
            vs1_data_i    => id_vs1_data,
            vs2_data_i    => id_vs2_data,
            is_vector_i   => id_ctrl_is_vector,
            vreg_write_i  => id_vreg_write,
            valu_ctrl_i   => id_valu_ctrl,
            valu_src_i    => id_valu_src,
            vauipc_i      => id_vauipc,
            vs1_data_o    => ex_vs1_data,
            vs2_data_o    => ex_vs2_data,
            is_vector_o   => ex_is_vector,
            vreg_write_o  => ex_vreg_write,
            valu_ctrl_o   => ex_valu_ctrl,
            valu_src_o    => ex_valu_src,
            vauipc_o      => ex_vauipc
        );
        
    -- Forwarding Unit
    Forwarding_Unit : entity work.forwarding_unit
        port map (
            rs1_ex_i        => ex_rs1_addr,
            rs2_ex_i        => ex_rs2_addr,
            rd_mem_i        => mem_rd_addr,
            reg_write_mem_i => mem_reg_write,
            rd_wb_i         => wb_rd_addr,
            reg_write_wb_i  => wb_reg_write,
            forward_a_o     => ex_forward_a,
            forward_b_o     => ex_forward_b
        );
    
    -- Vectorial Forwarding
    Vectorial_Forwarding : entity work.vector_forwarding_unit
        port map (
            vrs1_ex_i         => ex_rs1_addr,
            vrs2_ex_i         => ex_rs2_addr,
            vector_ex_i   => ex_is_vector,
            vrd_mem_i        => mem_vrd_addr,
            vreg_write_mem_i => mem_vreg_write,
            vrd_wb_i         => wb_vrd_addr,
            vreg_write_wb_i  => wb_vreg_write,
            vforward_a_o     => ex_vforward_a,
            vforward_b_o     => ex_vforward_b
        );
    
    -- MUX dedicated to what happens in the forwarding A
    Forwarding_A_MUX : process(ex_forward_a, ex_rs1_data, mem_alu_result, wb_write_data)
    begin
        case ex_forward_a is
            --Does the Forwarding
            when "01"   => ex_rs1_forwarded <= mem_alu_result;
            when "10"   => ex_rs1_forwarded <= wb_write_data;
            when others => ex_rs1_forwarded <= ex_rs1_data;
        end case;
    end process Forwarding_A_MUX;
    
    -- MUX dedicated to what happens in the forwarding B
    Forwarding_B_MUX : process(ex_forward_b, ex_rs2_data, mem_alu_result, wb_write_data)
    begin
        case ex_forward_b is
            when "01"   => ex_rs2_forwarded <= mem_alu_result;
            when "10"   => ex_rs2_forwarded <= wb_write_data;
            when others => ex_rs2_forwarded <= ex_rs2_data;
        end case;
    end process Forwarding_B_MUX;
    
    -- MUX dedicated to what happens in the forwarding A (Vectorial)
    ForwardingV_A_MUX : process(ex_vforward_a, ex_vs1_data, mem_valu_result, wb_valu_result)
    begin
        case ex_vforward_a is
            when "01"   => ex_vs1_forwarded <= mem_valu_result;
            when "10"   => ex_vs1_forwarded <= wb_valu_result;
            when others => ex_vs1_forwarded <= ex_vs1_data;
        end case;
    end process ForwardingV_A_MUX;
    
    -- Mux de forwarding vetorial para operando B
    ForwardingV_B_MUX : process(ex_vforward_b, ex_vs2_data, mem_valu_result, wb_valu_result)
    begin
        case ex_vforward_b is
            when "01"   => ex_vs2_forwarded <= mem_valu_result;
            when "10"   => ex_vs2_forwarded <= wb_valu_result;
            when others => ex_vs2_forwarded <= ex_vs2_data;
        end case;
    end process ForwardingV_B_MUX;
    
    -- Selects the operand A of the ALU
    ALU_A_Selection : process(ex_auipc, ex_lui, ex_pc, ex_rs1_forwarded)
    begin
        --Used in the AUIPC and LUI instructions
        if ex_auipc = '1' then
            ex_alu_a <= ex_pc;
        elsif ex_lui = '1' then
            ex_alu_a <= (others => '0');
        else
            ex_alu_a <= ex_rs1_forwarded;
        end if;
    end process ALU_A_Selection;
    
    -- Selecting the B operand based on the source
    ex_alu_b <= ex_imm when ex_alu_src = '1' else ex_rs2_forwarded;
    
    -- Initialization of the ALU
    ALU : entity work.alu
        port map (
            a_i        => ex_alu_a,
            b_i        => ex_alu_b,
            alu_ctrl_i => ex_alu_ctrl,
            result_o   => ex_alu_result,
            zero_o     => ex_alu_zero,
            carry_o    => open,
            overflow_o => open
        );
    
    -- Selecting ALU operand A (vectorial)
    VALU_A_Selection : process(ex_vauipc, ex_pc, ex_vs1_forwarded)
    begin
        if ex_vauipc = '1' then
            ex_valu_a <= ex_pc & ex_pc & ex_pc & ex_pc;
        else
            ex_valu_a <= ex_vs1_forwarded;
        end if;
    end process VALU_A_Selection;

    -- Selecting ALU operand B (vectorial)
    VALU_B_Selection : process(ex_valu_src, ex_imm, ex_vs2_forwarded)
    begin
        if ex_valu_src = '1' then
            -- Transforms the immediate value into a vector
            ex_valu_b <= imm_vector(ex_imm);
        else
            ex_valu_b <= ex_vs2_forwarded;
        end if;
    end process VALU_B_Selection;
    
    -- Vectorial ALU
    VALU : entity work.vector_alu
        port map (
            operator_a        => ex_valu_a,
            operator_b        => ex_valu_b,
            alu_operation => ex_valu_ctrl,
            alu_result  => ex_valu_result
        );
    
    -- Branch Comparator
    BRANCH_CMP : entity work.branch_comparator
        port map (
            a_i            => ex_rs1_forwarded,
            b_i            => ex_rs2_forwarded,
            funct3_i       => ex_funct3,
            branch_i       => ex_branch,
            branch_taken_o => ex_branch_taken,
            eq_o           => open,
            ne_o           => open
        );
    
    -- Deciding which should be the target adrress
    Target_Address_Calculation : process(ex_pc, ex_imm, ex_jalr, ex_rs1_forwarded)
    begin
        --In jumpalr
        if ex_jalr = '1' then
            ex_target_addr <= std_logic_vector(unsigned(ex_rs1_forwarded) + unsigned(ex_imm));
            ex_target_addr(0) <= '0';
        else
            ex_target_addr <= std_logic_vector(unsigned(ex_pc) + unsigned(ex_imm));
        end if;
    end process Target_Address_Calculation;
    
    --Hazard Unit
    Hazard_Unit : entity work.hazard_unit
        port map (
            rs1_id_i       => id_rs1,
            rs2_id_i       => id_rs2,
            rd_ex_i        => ex_rd_addr,
            mem_read_ex_i  => ex_mem_read,
            branch_taken_i => ex_branch_taken,
            jump_i         => ex_jump,
            stall_if_o     => stall_if,
            stall_id_o     => stall_id,
            flush_id_o     => flush_id,
            flush_ex_o     => flush_ex,
            hazard_type_o  => hazard_type
        );
    

    --EX/MEM Register
    EX_MEM_Register : entity work.ex_mem_reg
        port map (
            clk_i         => clk_i,
            reset_i       => reset_i,
            flush_i       => '0',
            load_enable_i => load_enable_i,
            pc_plus4_i    => ex_pc_plus4,
            alu_result_i  => ex_alu_result,
            rs2_data_i    => ex_rs2_forwarded,
            rd_addr_i     => ex_rd_addr,
            zero_i        => ex_alu_zero,
            reg_write_i   => ex_reg_write,
            mem_to_reg_i  => ex_mem_to_reg,
            mem_write_i   => ex_mem_write,
            mem_read_i    => ex_mem_read,
            branch_i      => ex_branch,
            jump_i        => ex_jump,
            pc_plus4_o    => mem_pc_plus4,
            alu_result_o  => mem_alu_result,
            rs2_data_o    => mem_rs2_data,
            rd_addr_o     => mem_rd_addr,
            zero_o        => mem_zero,
            reg_write_o   => mem_reg_write,
            mem_to_reg_o  => mem_mem_to_reg,
            mem_write_o   => mem_mem_write,
            mem_read_o    => mem_mem_read,
            branch_o      => mem_branch,
            jump_o        => mem_jump
        );
    
    -- EX/MEM Vetorial Register
    EX_MEM_Vectorial_Register : entity work.ex_mem_vreg
        port map (
            clk_i          => clk_i,
            reset_i        => reset_i,
            flush_i        => '0',
            load_enable_i  => load_enable_i,
            valu_result_i  => ex_valu_result,
            vrd_addr_i     => ex_rd_addr,
            is_vector_i    => ex_is_vector,
            vreg_write_i   => ex_vreg_write,
            valu_result_o  => mem_valu_result,
            vrd_addr_o     => mem_vrd_addr,
            is_vector_o    => mem_is_vector,
            vreg_write_o   => mem_vreg_write
        );
    
    -- Acessing directly the momory
    dmem_addr_o  <= mem_alu_result;
    dmem_wdata_o <= mem_rs2_data;
    dmem_we_o    <= mem_mem_write and (not load_enable_i);
    mem_read_data <= dmem_rdata_i;
    
    --MEM/WB Register
    MEM_WB_Register : entity work.mem_wb_reg
        port map (
            clk_i         => clk_i,
            reset_i       => reset_i,
            load_enable_i => load_enable_i,
            pc_plus4_i    => mem_pc_plus4,
            alu_result_i  => mem_alu_result,
            mem_data_i    => mem_read_data,
            rd_addr_i     => mem_rd_addr,
            reg_write_i   => mem_reg_write,
            mem_to_reg_i  => mem_mem_to_reg,
            jump_i        => mem_jump,
            pc_plus4_o    => wb_pc_plus4,
            alu_result_o  => wb_alu_result,
            mem_data_o    => wb_mem_data,
            rd_addr_o     => wb_rd_addr,
            reg_write_o   => wb_reg_write,
            mem_to_reg_o  => wb_mem_to_reg,
            jump_o        => wb_jump
        );
    
    -- Vectorial MEM/WB Register
    MEM_WB_Vectorial_Register : entity work.mem_wb_vreg
        port map (
            clk_i          => clk_i,
            reset_i        => reset_i,
            load_enable_i  => load_enable_i,
            valu_result_i  => mem_valu_result,
            vrd_addr_i     => mem_vrd_addr,
            vreg_write_i   => mem_vreg_write,
            valu_result_o  => wb_valu_result,
            vrd_addr_o     => wb_vrd_addr,
            vreg_write_o   => wb_vreg_write
        );
    
    
    --Selecting the data in the Writing Back Stage
    WB_Selection : process(wb_jump, wb_mem_to_reg, wb_pc_plus4, wb_mem_data, wb_alu_result)
    begin
        if wb_jump = '1' then
            wb_write_data <= wb_pc_plus4;
        elsif wb_mem_to_reg = '1' then
            wb_write_data <= wb_mem_data;
        else
            wb_write_data <= wb_alu_result;
        end if;
    end process WB_Selection;
    
    
    -- Regular debugs signals used during testing
    pc_debug_o           <= if_pc;
    instr_debug_o        <= id_instruction;
    alu_result_debug_o   <= ex_alu_result;
    stage_if_pc_o        <= if_pc;
    stage_id_pc_o        <= id_pc;
    stage_ex_pc_o        <= ex_pc;
    hazard_stall_o        <= stall_if or stall_id;
    hazard_flush_o        <= flush_id or flush_ex;
    
    -- Vetorial debugs signals
    vreg_debug_lane0_o    <= vreg_debug_internal(31 downto 0);
    vreg_debug_lane1_o    <= vreg_debug_internal(63 downto 32);
    vreg_debug_lane2_o    <= vreg_debug_internal(95 downto 64);
    vreg_debug_lane3_o    <= vreg_debug_internal(127 downto 96);
    valu_result_lane0_o   <= ex_valu_result(31 downto 0);
    valu_result_lane1_o   <= ex_valu_result(63 downto 32);
    valu_result_lane2_o   <= ex_valu_result(95 downto 64);
    valu_result_lane3_o   <= ex_valu_result(127 downto 96);

end architecture rtl;