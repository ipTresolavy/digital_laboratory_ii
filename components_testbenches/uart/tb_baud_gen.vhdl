library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.env.stop;

entity tb_baud_gen is
end entity tb_baud_gen;

architecture testbench of tb_baud_gen is
  -- Constants
  constant CLOCK_FREQ  : natural := 50_000_000; -- 50 MHz
  constant BAUD_RATE   : natural := 115_200;
  constant DIVISOR_VAL : natural := CLOCK_FREQ / (16 * BAUD_RATE) - 1;
  constant EXPECTED_TICKS : natural := 16;

  -- Signals
  signal clock    : std_logic := '0';
  signal reset    : std_logic := '0';
  signal divisor  : std_logic_vector(10 downto 0);
  signal tick     : std_logic;
  
  -- Time measurement signals
  signal start_time : time;
  signal end_time   : time;
  
  -- Instantiate the baud_gen component
  component baud_gen is
    port
    (
      clock   : in  std_logic;
      reset   : in  std_logic;
      divisor : in  std_logic_vector(10 downto 0);
      tick    : out std_logic
    );
  end component baud_gen;

  constant clockPeriod : time := 20 ns; -- 50 MHz
  
begin
  -- Instantiate the baud_gen component
  uut: baud_gen
    port map
    (
      clock   => clock,
      reset   => reset,
      divisor => std_logic_vector(to_unsigned(DIVISOR_VAL, 11)),
      tick    => tick
    );

  clock <= (not clock) after clockPeriod/2;

  -- Stimulus process
  process
    variable measured_baud_rate : real;
  begin
    wait for 10 ns;  -- Wait for initial signals to settle
    
    -- Set the reset signal to initialize the baud generator
    reset <= '1';
    wait for 10 ns;
    reset <= '0';
    
    -- Wait for one complete cycle to ensure tick is asserted
    wait until rising_edge(clock) and tick = '1';
    
    -- Measure the time for a specific number of baud rate periods
    start_time <= now;
    for i in 1 to EXPECTED_TICKS loop
      wait until rising_edge(clock) and tick = '1';
    end loop;
    end_time <= now;
    wait until falling_edge(clock);
    
    -- Calculate the actual baud rate
    measured_baud_rate := 1.0 / (real((end_time - start_time)/1 ns)) * 1000000000.0;
    report "measured baud rate: " & real'image(measured_baud_rate);

    -- Add additional test cases or assertions if needed
    report "Calling 'stop'";
    stop;
    wait;
  end process;
end architecture testbench;
