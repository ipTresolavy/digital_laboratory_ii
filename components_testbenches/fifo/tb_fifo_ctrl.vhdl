library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.stop;

entity tb_fifo_ctrl is
end entity tb_fifo_ctrl;

architecture testbench of tb_fifo_ctrl is
  -- Constants
  constant ADDR_WIDTH : natural := 4;
  
  -- Signals
  signal clock    : std_logic := '0';
  signal reset    : std_logic := '0';
  signal rd       : std_logic := '0';
  signal wr       : std_logic := '0';
  signal empty    : std_logic;
  signal full     : std_logic;
  
  constant clockPeriod : time := 20 ns; -- 50MHz

  -- Instantiate the fifo_ctrl component
  component fifo_ctrl is
    generic
    (
      ADDR_WIDTH : natural := 4
    );
    port
    (
      clock  : in  std_logic;
      reset  : in  std_logic;
      rd     : in  std_logic;
      wr     : in  std_logic;
      empty  : out std_logic;
      full   : out std_logic;
      w_addr : out std_logic_vector(ADDR_WIDTH-1 downto 0);
      r_addr : out std_logic_vector(ADDR_WIDTH-1 downto 0)
    );
  end component fifo_ctrl;

begin
  -- Instantiate the fifo_ctrl component
  uut: fifo_ctrl
    generic map
    (
      ADDR_WIDTH => ADDR_WIDTH
    )
    port map
    (
      clock  => clock,
      reset  => reset,
      rd     => rd,
      wr     => wr,
      empty  => empty,
      full   => full,
      w_addr => open,
      r_addr => open
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
      wait until falling_edge(clock);
      assert empty = '0' report "FIFO should not be empty" severity error;
      assert full = '0' report "FIFO should not be full" severity error;
      
      wr <= '0';
      rd <= '1';
      wait until falling_edge(clock);
      
      -- Add assert statements to verify the FIFO operation (full, empty)
      assert empty = '1' report "FIFO should be empty" severity error;
      assert full = '0' report "FIFO should not be full" severity error;
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
