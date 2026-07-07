library ieee;
use ieee.std_logic_1164.all;

-- =============================================================================
-- ID/EX REGISTER
-- =============================================================================
entity id_ex_vreg is
    port (
        clk_i           : in  std_logic;
        reset_i         : in  std_logic;
        stall_i         : in  std_logic;
        flush_i         : in  std_logic;
        load_enable_i   : in  std_logic;
        
        -- ID entrys input
        vs1_data_i      : in  std_logic_vector(127 downto 0);
        vs2_data_i      : in  std_logic_vector(127 downto 0);
        
        -- Control signals
        is_vector_i     : in  std_logic;
        vreg_write_i    : in  std_logic;
        valu_ctrl_i     : in  std_logic_vector(3 downto 0);
        valu_src_i      : in  std_logic;
        vauipc_i        : in  std_logic;
        
        -- Ex outputs
        vs1_data_o      : out std_logic_vector(127 downto 0);
        vs2_data_o      : out std_logic_vector(127 downto 0);
        is_vector_o     : out std_logic;
        vreg_write_o    : out std_logic;
        valu_ctrl_o     : out std_logic_vector(3 downto 0);
        valu_src_o      : out std_logic;
        vauipc_o        : out std_logic
    );
end entity id_ex_vreg;

architecture behavioral of id_ex_vreg is
    --The registers
    signal r_vs1_data   : std_logic_vector(127 downto 0);
    signal r_vs2_data   : std_logic_vector(127 downto 0);
    signal r_is_vector  : std_logic;
    signal r_vreg_write : std_logic;
    signal r_valu_ctrl  : std_logic_vector(3 downto 0);
    signal r_valu_src   : std_logic;
    signal r_vauipc     : std_logic;
begin
    process(clk_i, reset_i)
    begin
        -- Assincronous reset
        if reset_i = '1' then
            r_vs1_data   <= (others => '0');
            r_vs2_data   <= (others => '0');
            r_is_vector  <= '0';
            r_vreg_write <= '0';
            r_valu_ctrl  <= (others => '0');
            r_valu_src   <= '0';
            r_vauipc     <= '0';
            
        elsif rising_edge(clk_i) then
            if load_enable_i = '0' then
                if flush_i = '1' then
                    -- FLush
                    r_vs1_data   <= (others => '0');
                    r_vs2_data   <= (others => '0');
                    r_is_vector  <= '0';
                    r_vreg_write <= '0';
                    r_valu_ctrl  <= (others => '0');
                    r_valu_src   <= '0';
                    r_vauipc     <= '0';
                elsif stall_i = '0' then
                    -- Stall
                    r_vs1_data   <= vs1_data_i;
                    r_vs2_data   <= vs2_data_i;
                    r_is_vector  <= is_vector_i;
                    r_vreg_write <= vreg_write_i;
                    r_valu_ctrl  <= valu_ctrl_i;
                    r_valu_src   <= valu_src_i;
                    r_vauipc     <= vauipc_i;
                end if;
            end if;
        end if;
    end process;

    --Outputs that come from the registesr
    vs1_data_o   <= r_vs1_data;
    vs2_data_o   <= r_vs2_data;
    is_vector_o  <= r_is_vector;
    vreg_write_o <= r_vreg_write;
    valu_ctrl_o  <= r_valu_ctrl;
    valu_src_o   <= r_valu_src;
    vauipc_o     <= r_vauipc;
    
end architecture behavioral;


-- =============================================================================
-- EX/MEM REGISTER
-- =============================================================================
library ieee;
use ieee.std_logic_1164.all;

entity ex_mem_vreg is
    port (
        clk_i           : in  std_logic;
        reset_i         : in  std_logic;
        flush_i         : in  std_logic;
        load_enable_i   : in  std_logic;
        
        -- EX Inputs
        valu_result_i   : in  std_logic_vector(127 downto 0);
        vrd_addr_i      : in  std_logic_vector(4 downto 0);
        
        -- Control signal inputs
        is_vector_i     : in  std_logic;
        vreg_write_i    : in  std_logic;
        
        -- MEM Outputs
        valu_result_o   : out std_logic_vector(127 downto 0);
        vrd_addr_o      : out std_logic_vector(4 downto 0);
        is_vector_o     : out std_logic;
        vreg_write_o    : out std_logic
    );
end entity ex_mem_vreg;

architecture behavioral of ex_mem_vreg is
    -- The registers
    signal r_valu_result : std_logic_vector(127 downto 0);
    signal r_vrd_addr    : std_logic_vector(4 downto 0);
    signal r_is_vector   : std_logic;
    signal r_vreg_write  : std_logic;
begin
    process(clk_i, reset_i)
    begin
        -- Assincronous Reset 
        if reset_i = '1' then
            r_valu_result <= (others => '0');
            r_vrd_addr    <= (others => '0');
            r_is_vector   <= '0';
            r_vreg_write  <= '0';
            
        elsif rising_edge(clk_i) then
            if load_enable_i = '0' then
                if flush_i = '1' then
                    -- Flush
                    r_valu_result <= (others => '0');
                    r_vrd_addr    <= (others => '0');
                    r_is_vector   <= '0';
                    r_vreg_write  <= '0';
                else
                    r_valu_result <= valu_result_i;
                    r_vrd_addr    <= vrd_addr_i;
                    r_is_vector   <= is_vector_i;
                    r_vreg_write  <= vreg_write_i;
                end if;
            end if;
        end if;
    end process;

    valu_result_o <= r_valu_result;
    vrd_addr_o    <= r_vrd_addr;
    is_vector_o   <= r_is_vector;
    vreg_write_o  <= r_vreg_write;
    
end architecture behavioral;


-- =============================================================================
-- MEM/WB REGISTER
-- =============================================================================
library ieee;
use ieee.std_logic_1164.all;

entity mem_wb_vreg is
    port (
        clk_i           : in  std_logic;
        reset_i         : in  std_logic;
        load_enable_i   : in  std_logic;
        
        -- MEM Inputs
        valu_result_i   : in  std_logic_vector(127 downto 0);
        vrd_addr_i      : in  std_logic_vector(4 downto 0);
        
        -- Control Signals
        vreg_write_i    : in  std_logic;
        
        -- WB Outputs
        valu_result_o   : out std_logic_vector(127 downto 0);
        vrd_addr_o      : out std_logic_vector(4 downto 0);
        vreg_write_o    : out std_logic
    );
end entity mem_wb_vreg;

architecture behavioral of mem_wb_vreg is
    -- The registers
    signal r_valu_result : std_logic_vector(127 downto 0);
    signal r_vrd_addr    : std_logic_vector(4 downto 0);
    signal r_vreg_write  : std_logic;
begin
    process(clk_i, reset_i)
    begin
        -- Assincronous Reset
        if reset_i = '1' then
            r_valu_result <= (others => '0');
            r_vrd_addr    <= (others => '0');
            r_vreg_write  <= '0';

        elsif rising_edge(clk_i) then
            if load_enable_i = '0' then
                r_valu_result <= valu_result_i;
                r_vrd_addr    <= vrd_addr_i;
                r_vreg_write  <= vreg_write_i;
            end if;
        end if;
    end process;

    valu_result_o <= r_valu_result;
    vrd_addr_o    <= r_vrd_addr;
    vreg_write_o  <= r_vreg_write;
    
end architecture behavioral;