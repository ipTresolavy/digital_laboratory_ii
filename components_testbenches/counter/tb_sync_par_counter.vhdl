library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.env.stop;

entity tb_sync_par_counter is
end entity tb_sync_par_counter;

architecture sim of tb_sync_par_counter is
  signal clock   : std_logic := '0';
  signal reset   : std_logic := '0';
  signal cnt_en  : std_logic := '0';
  signal load    : std_logic := '0';
  signal q_in    : std_logic_vector(3 downto 0) := "0000";
  signal q       : std_logic_vector(3 downto 0);

  constant clockPeriod : time := 10 ns; -- Adjust this as needed

  component sync_par_counter is
    generic
    (
      constant MODU : natural := 16
    );
    port
    (
      clock  : in  std_logic;
      reset  : in  std_logic;
      cnt_en : in  std_logic;
      q_in   : in  std_logic_vector(natural(ceil(log2(real(MODU))))-1 downto 0);
      load   : in  std_logic;
      q      : out std_logic_vector(natural(ceil(log2(real(MODU))))-1 downto 0)
    );
  end component sync_par_counter;

begin
  uut: sync_par_counter
  generic map
  (
    MODU => 16 -- You can change MODU to the desired value
  )
  port map
  (
    clock  => clock,
    reset  => reset,
    cnt_en => cnt_en,
    load   => load,
    q_in   => q_in,
    q      => q
  );

  clock <= not clock after clockPeriod / 2;

  stimulus_process : process
  begin
    -- Reset the system
    reset <= '1';
    cnt_en <= '0';
    wait until falling_edge(clock);
    reset <= '0';

    -- Test case 1: Enable counter
    wait for 10 * clockPeriod;
    assert q = "0000" report "Counter value incorrect" severity error;
    cnt_en <= '1';
    wait for 10 * clockPeriod;
    assert q = "1010" report "Counter value incorrect" severity error;
    cnt_en <= '0';

    -- Test case 2: Reset counter
    wait for 10 * clockPeriod;
    reset <= '1';
    wait for 2 * clockPeriod;
    reset <= '0';
    wait for 10 * clockPeriod;
    assert q = "0000" report "Counter value incorrect" severity error;

    -- Test case 3: Test counter values
    wait for 10 * clockPeriod;
    cnt_en <= '1';
    wait for 10 * clockPeriod;
    assert q = "1010" report "Counter value incorrect" severity error;
    wait for 6 * clockPeriod;
    cnt_en <= '0';

    -- Assert counter values
    assert q = "0000" report "Counter value incorrect" severity error;

    -- Test case 4: Test value load
    wait for 10 * clockPeriod;
    cnt_en <= '1';
    q_in <= "1010";
    load <= '1';
    wait for 10 * clockPeriod;
    assert q = "1010" report "Counter value incorrect" severity error;
    wait for 6 * clockPeriod;
    load <= '0';
    cnt_en <= '0';

    -- Assert counter values
    assert q = "1010" report "Counter value incorrect" severity error;

    -- Finish the simulation
    report "Simulation finished";
    stop;
  end process stimulus_process;

end architecture sim;
