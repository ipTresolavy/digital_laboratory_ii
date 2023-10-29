library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.stop;

entity tb_fifo is
end entity tb_fifo;

architecture testbench of tb_fifo is
  -- Constants
  constant DATA_WIDTH : natural := 8;
  constant ADDR_WIDTH : natural := 4;
  
  -- Signals
  signal clock    : std_logic := '0';
  signal reset    : std_logic := '0';
  signal rd       : std_logic := '0';
  signal wr       : std_logic := '0';
  signal w_data   : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
  signal empty    : std_logic;
  signal full     : std_logic;
  signal r_data   : std_logic_vector(DATA_WIDTH-1 downto 0);
  
  constant clockPeriod : time := 20 ns; -- 50MHz

  -- Instantiate the fifo component
  component fifo is
    generic
    (
      DATA_WIDTH : natural := 8;
      ADDR_WIDTH : natural := 4
    );
    port
    (
      clock  : in  std_logic;
      reset  : in  std_logic;
      rd     : in  std_logic;
      wr     : in  std_logic;
      w_data : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      empty  : out std_logic;
      full   : out std_logic;
      r_data : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
  end component fifo;

begin
  -- Instantiate the fifo component
  uut: fifo
    generic map
    (
      DATA_WIDTH => DATA_WIDTH,
      ADDR_WIDTH => ADDR_WIDTH
    )
    port map
    (
      clock  => clock,
      reset  => reset,
      rd     => rd,
      wr     => wr,
      w_data => w_data,
      empty  => empty,
      full   => full,
      r_data => r_data
    );

  clock <= (not clock) after clockPeriod/2;

  -- Stimulus process
  process
  begin
    wait for 10 ns;  -- Wait for initial signals to settle
    
    -- Initialize the FIFO control
    reset <= '1';
    wait until rising_edge(clock);
    wait until falling_edge(clock);
    reset <= '0';
    assert empty = '1' report "FIFO should be empty" severity error;
    assert full = '0' report "FIFO should not be full" severity error;

    -- Write and read data from the FIFO
    for i in 0 to 2**ADDR_WIDTH - 1 loop
      wr <= '1';
      rd <= '0';
      w_data <= std_logic_vector(to_unsigned(i, DATA_WIDTH));
      wait until falling_edge(clock);
      assert empty = '0' report "FIFO should not be empty" severity error;
      assert full = '0' report "FIFO should not be full" severity error;
      
      wr <= '0';
      wait until falling_edge(clock);
      assert r_data = w_data report "data read is different from written data" severity error;

      rd <= '1';
      wait until falling_edge(clock);
      
      -- Add assert statements to verify the FIFO operation (full, empty, data)
      assert empty = '1' report "FIFO should be empty" severity error;
      assert full = '0' report "FIFO should not be full" severity error;
      -- Add more assert statements for data verification
    end loop;

    -- Test case to make the FIFO full
    for i in 0 to 2**ADDR_WIDTH - 1 loop
      wr <= '1';
      rd <= '0';
      wait until falling_edge(clock);
    end loop;
    -- Add assert statements to verify the FIFO operation (full)
    assert full = '1' report "FIFO should be full" severity error;
    
    report "Calling 'stop'";
    stop;
    wait;
  end process;
end architecture testbench;
