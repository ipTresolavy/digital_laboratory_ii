library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;
use std.env.stop;

entity tb_multiplier_ctrl is
end entity tb_multiplier_ctrl;

architecture sim of tb_multiplier_ctrl is
  signal clock            : std_logic := '0';
  signal reset            : std_logic := '0';
  signal valid            : std_logic := '0';
  signal finished         : std_logic := '0';
  signal ready            : std_logic;
  signal load             : std_logic;
  signal shift_operands   : std_logic;

  constant clockPeriod : time := 20 ns; -- Clock period (50 MHz)
  constant num_tests   : natural := 100;   -- Number of tests

  component multiplier_ctrl is
    port
    (
      clock          : in std_logic;
      reset          : in std_logic;
      valid          : in std_logic;
      finished       : in std_logic;
      ready          : out std_logic;
      load           : out std_logic;
      shift_operands : out std_logic
    );
  end component multiplier_ctrl;

begin
  uut_multiplier_ctrl: multiplier_ctrl
  port map
  (
    clock          => clock,
    reset          => reset,
    valid          => valid,
    finished       => finished,
    ready          => ready,
    load           => load,
    shift_operands => shift_operands
  );

  -- Clock process
  clock <= not clock after clockPeriod / 2;

  stimulus_process : process
      variable seed1 : integer := 123456789; -- Initial seed value
      variable seed2 : integer := 987654321; -- Initial seed value

      impure function rand_int(min_val, max_val : integer) return integer is
        variable r : real;
      begin
        uniform(seed1, seed2, r);
        return integer(
          round(r * real(max_val - min_val + 1) + real(min_val) - 0.5));
      end function;
  begin
    -- Reset the system
    reset <= '1';
    wait until rising_edge(clock);
    reset <= '0';
    wait until rising_edge(clock);

    for i in 1 to num_tests loop
      -- Generate random inputs
      valid <= '1';
      wait until falling_edge(clock);
      assert load  = '1' report "load signal was not asserted" severity failure;

      wait until rising_edge(clock);
      wait until falling_edge(clock);
      finished <= '0';
      valid <= '0';
      assert load  = '0' report "load signal was not deasserted" severity failure;
      assert ready = '0' report "ready signal was not deasserted" severity failure;
      assert shift_operands = '1' report "shift_operands was not asserted" severity failure;

      -- Wait for the multiplier_ctrl to finish
      wait for rand_int(1, 32)*clockPeriod;
      finished <= '1';
      wait until rising_edge(clock);
      wait until falling_edge(clock);
      assert ready = '1' report "ready signal was not asserted" severity failure;

      wait until rising_edge(clock);
    end loop;

    -- Finish the simulation
    report "Calling 'stop'";
    stop;
    wait;
  end process stimulus_process;

end architecture sim;
