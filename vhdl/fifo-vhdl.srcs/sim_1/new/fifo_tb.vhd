library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric.std.ALL;


--small test, depth = 4

entity fifo_tb is
end fifo_tb;

architecture Behavioral of fifo_tb is

component fifo is
generic (
    DATA_WIDTH: integer:= 16;
    FIFO_DEPTH: integer:= 4
);
port (
    clk: in std_logic;
    rst: in std_logic;
    wr_en: in std_logic;
    rd_en: in std_logic;
    data_in: in std_logic_vector(DATA_WIDTH-1 downto 0);
    data_out: out std_logic_vector(DATA_WIDTH-1 downto 0);
    fifo_full: out std_logic;
    fifo_empty: out std_logic
);
end component;

constant DATA_WIDTH: integer:= 16;
constant FIFO_DEPTH: integer:= 4;

constant clk_period: time:= 10 ns;

signal clk_tb: std_logic:= '0';
signal rst_tb: std_logic:= '0';
signal wr_en_tb: std_logic:= '0';
signal rd_en_tb: std_logic:= '0';
signal data_in_tb: std_logic_vector(DATA_WIDTH-1 downto 0):= (others => '0');
signal data_out_tb: std_logic_vector(DATA_WIDTH-1 downto 0);
signal fifo_full_tb: std_logic;
signal fifo_empty_tb: std_logic;

begin

uut: fifo
generic map (
    DATA_WIDTH => DATA_WIDTH,
    FIFO_DEPTH => FIFO_DEPTH
)
port map (
    clk => clk_tb,
    rst => rst_tb,
    wr_en => wr_en_tb,
    rd_en => rd_en_tb,
    data_in => data_in_tb,
    data_out => data_out_tb,
    fifo_full => fifo_full_tb,
    fifo_empty => fifo_empty_tb
);


clock: process
begin
    while true loop
        clk_tb <= '0';
        wait for clk_period / 2;
        clk_tb <= '1';
        wait for clk_period / 2;
    end loop;
end process;


test: process
begin

    wr_en_tb <= '0';
    rd_en_tb <= '0';
    data_in_tb <= (others => '0');

    --reset pulse
    rst_tb <= '1';
    wait for clk_period * 2;
    rst_tb <= '0';
    wait for clk_period;

    --simultaneous read/write when empty
    wr_en_tb <= '1';
    rd_en_tb <= '1';
    data_in_tb <= "1010000000000001";
    wait for clk_period;
    
    wr_en_tb <= '0';
    rd_en_tb <= '0';
    wait for clk_period;

    --fill fifo to full
    wr_en_tb <= '1';
    data_in_tb <= "1010000000000010"; wait for clk_period;
    data_in_tb <= "1010000000000011"; wait for clk_period;
    data_in_tb <= "1010000000000100"; wait for clk_period;
    wr_en_tb <= '0';
    wait for clk_period;

    --simultaneous read/write when full
    wr_en_tb <= '1';
    rd_en_tb <= '1';
    data_in_tb <= "1001100110011001";
    wait for clk_period;
    
    wr_en_tb <= '0';
    rd_en_tb <= '0';
    wait for clk_period;

    --normal simultaneous read/write (neither empty nor full)
    wr_en_tb <= '1';
    rd_en_tb <= '1';
    data_in_tb <= "1011000000000001";
    wait for clk_period;

    wr_en_tb <= '0';
    rd_en_tb <= '0';
    wait for clk_period;

    --read remaining elements until empty
    rd_en_tb <= '1';
    wait for clk_period * 3;
    
    --read when empty
    wait for clk_period;
    rd_en_tb <= '0';

    wait for clk_period * 2;
    wait;
end process;


end Behavioral;