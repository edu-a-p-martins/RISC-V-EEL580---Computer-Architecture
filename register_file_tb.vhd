library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file_tb is
end entity;

architecture sim of register_file_tb is
    signal clk_i : std_logic := '0';
    signal reset_i : std_logic := '0';
    signal we_i : std_logic := '0';
    signal rs1_addr_i : std_logic_vector(4 downto 0) := (others => '0');
    signal rs2_addr_i : std_logic_vector(4 downto 0) := (others => '0');
    signal rd_addr_i : std_logic_vector(4 downto 0) := (others => '0');
    signal rd_data_i : std_logic_vector(31 downto 0) := (others => '0');
    signal rs1_data_o : std_logic_vector(31 downto 0);
    signal rs2_data_o : std_logic_vector(31 downto 0);
    signal reg_debug_o : std_logic_vector(31 downto 0);
    signal reg_sel_i : std_logic_vector(4 downto 0) := (others => '0');
begin
    uut: entity work.register_file
        port map (
            clk_i => clk_i,
            reset_i => reset_i,
            we_i => we_i,
            rs1_addr_i => rs1_addr_i,
            rs2_addr_i => rs2_addr_i,
            rd_addr_i => rd_addr_i,
            rd_data_i => rd_data_i,
            rs1_data_o => rs1_data_o,
            rs2_data_o => rs2_data_o,
            reg_debug_o => reg_debug_o,
            reg_sel_i => reg_sel_i
        );

    clk_i <= not clk_i after 10 ns;

    process
    begin
        wait for 20 ns;
        reset_i <= '1';
        wait for 20 ns;
        reset_i <= '0';
        wait for 20 ns;
        rd_addr_i <= "00001";
        rd_data_i <= x"0000000A";
        we_i <= '1';
        wait for 20 ns;
        we_i <= '0';
        reg_sel_i <= "00001";
        wait for 20 ns;
        assert reg_debug_o = x"0000000A" report "reg_debug_o nao atualizou" severity error;
        wait;
    end process;
end architecture;
