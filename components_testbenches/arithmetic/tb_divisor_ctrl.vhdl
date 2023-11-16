library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;
use std.env.stop;

entity tb_divisor_ctrl is
end entity tb_divisor_ctrl;

architecture sim of tb_divisor_ctrl is
  signal clock            : std_logic := '0';
  signal reset            : std_logic := '0';
  signal valid            : std_logic := '0';
  signal neg_remainder    : std_logic := '0';
  signal finished         : std_logic := '0';
  signal ready            : std_logic;
  signal load             : std_logic;
  signal shift_quotient   : std_logic;
  signal set_quotient_bit : std_logic;
  signal shift_divisor    : std_logic;
  signal restore_sub      : std_logic;
  signal write_remainder  : std_logic;

  constant clockPeriod : time := 20 ns; -- Clock period (50 MHz)
  constant num_tests   : natural := 100;   -- Number of tests

  component divisor_ctrl is
    port
    (
      clock            : in std_logic;
      reset            : in std_logic;
      valid            : in std_logic;
      neg_remainder    : in std_logic;
      finished         : in std_logic;
      ready            : out std_logic;
      load             : out std_logic;
      shift_quotient   : out std_logic;
      set_quotient_bit : out std_logic;
      shift_divisor    : out std_logic;
      restore_sub      : out std_logic;
      write_remainder  : out std_logic
    );
  end component divisor_ctrl;

begin
  uut_divisor_ctrl: divisor_ctrl
  port map
  (
    clock            => clock,
    reset            => reset,
    valid            => valid,
    neg_remainder    => neg_remainder,
    finished         => finished,
    ready            => ready,
    load             => load,
    shift_quotient   => shift_quotient,
    set_quotient_bit => set_quotient_bit,
    shift_divisor    => shift_divisor,
    restore_sub      => restore_sub,
    write_remainder  => write_remainder
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
      valid <= '1';
      wait until falling_edge(clock);
      assert load = '1' report "load was not asserted" severity failure;
      finished <= '0';
      wait until falling_edge(clock);
      valid <= '0';
      assert load = '0' report "load was not deasserted" severity failure;
      assert ready = '0' report "ready was not deasserted" severity failure;

      for i in 1 to 32 loop
        assert write_remainder = '1' report "write_remainder was not asserted" severity failure;
        neg_remainder <= '1' when rand_int(0, 1) = 1 else '0';

        wait until falling_edge(clock);

        assert shift_divisor  = '1' report "shift_divisor was not asserted" severity failure;
        assert shift_quotient = '1' report "shift_quotient was not asserted" severity failure;
        if neg_remainder = '1' then
          assert restore_sub = '1' report "restore_sub was not asserted" severity failure;
          assert write_remainder = '1' report "write_remainder was not asserted" severity failure;
          assert set_quotient_bit = '0' report "set_quotient_bit was not deasserted" severity failure;
        else
          assert set_quotient_bit = '1' report "set_quotient_bit was not asserted" severity failure;
        end if;

        if i = 32 then
          finished <= '1';
        end if;

        wait until falling_edge(clock);
      end loop;

      assert write_remainder = '0' report "write_remainder was not deasserted" severity failure;

      wait until falling_edge(clock);

      assert ready = '1' report "ready was not asserted" severity failure;

      wait until rising_edge(clock);
    end loop;

    -- Finish the simulation
    report "Calling 'stop'";
    stop;
    wait;
  end process stimulus_process;

end architecture sim;
