library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.stop;

entity tb_t_flip_flop is
end entity tb_t_flip_flop;

architecture sim of tb_t_flip_flop is
  signal clock : std_logic := '0';
  signal reset : std_logic := '0';
  signal en    : std_logic := '0';
  signal q     : std_logic;

  constant clockPeriod : time := 20 ns; -- 50 MHz
  signal stop_sim : boolean := false;

  component t_flip_flop is
    port
    (
      clock : in  std_logic;
      reset : in  std_logic;
      en    : in  std_logic;
      q     : out std_logic
    );
  end component t_flip_flop;

begin
  uut: t_flip_flop
  port map
  (
    clock => clock,
    reset => reset,
    en    => en,
    q     => q
  );

  clock <= not clock after clockPeriod / 2;

  stimulus_process : process
  begin
    -- Reset the system
    reset <= '1';
    en    <= '0';
    wait for clockPeriod;
    reset <= '0';

    -- Test case 1: Apply a rising edge on en
    wait until falling_edge(clock);
    en <= '1';
    wait until falling_edge(clock);
    assert q = '1' report "Test case 1 failed" severity error;
    en <= '0';

    -- Test case 2: Apply a falling edge on en
    wait until falling_edge(clock);
    en <= '1';
    wait until falling_edge(clock);
    assert q = '0' report "Test case 2 failed" severity error;
    en <= '0';

    -- Test case 3: Reset the flip-flop
    wait until falling_edge(clock);
    reset <= '1';
    wait until falling_edge(clock);
    assert q = '0' report "Test case 3 failed" severity error;
    reset <= '0';

    -- Finish the simulation
    report "Calling 'stop'";
    stop;
    wait;
  end process stimulus_process;

end architecture sim;
