library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.float_pkg.all;
use std.env.stop;

entity tb_sp_fp_adder_dpath is
end entity tb_sp_fp_adder_dpath;

architecture sim of tb_sp_fp_adder_dpath is
  signal clock : std_logic := '0';
  signal reset : std_logic := '0';
  signal buffer_inputs : std_logic := '0';
  signal load_smaller : std_logic := '0';
  signal shift_smaller_signif : std_logic := '0';
  signal store_sum : std_logic := '0';
  signal count_zeroes : std_logic := '0';
  signal a : std_logic_vector(31 downto 0) := (others => '0');
  signal b : std_logic_vector(31 downto 0) := (others => '0');
  signal y : std_logic_vector(31 downto 0) := (others => '0');

  signal a_real : real := 0.0;
  signal b_real : real := 0.0;
  constant AMNT_OF_TESTS : integer := 5;

  constant clockPeriod : time := 20 ns;  -- Clock period (50 MHz)

  component sp_fp_adder_dpath is
    port (
      clock : in  std_logic;
      reset : in  std_logic;
      buffer_inputs : in std_logic;
      load_smaller : in std_logic;
      shift_smaller_signif : in std_logic;
      store_sum : in std_logic;
      count_zeroes : in std_logic;
      equal_exps : out std_logic;
      sum_is_zero : out std_logic;
      finished_shift : out std_logic;
      a : in std_logic_vector(31 downto 0);
      b : in std_logic_vector(31 downto 0);
      y : out std_logic_vector(31 downto 0)
    );
  end component sp_fp_adder_dpath;

  signal a_sign, b_sign, y_sign : std_logic;
  signal a_exp, b_exp, y_exp : std_logic_vector(7 downto 0);
  signal a_mant, b_mant, y_mant : std_logic_vector(23 downto 0);
  signal exp_b_gt_a, signif_b_gt_a : std_logic;
  signal equal_exps, sum_is_zero, finished_shift : std_logic;
  signal sum_is_zero_or_finished_shift : std_logic;
  signal expected_result : std_logic_vector(31 downto 0);

  begin

    sum_is_zero_or_finished_shift <= sum_is_zero or  finished_shift;

    uut_sp_fp_adder: sp_fp_adder_dpath
    port map
    (
      clock => clock,
      reset => reset,
      buffer_inputs => buffer_inputs,
      load_smaller => load_smaller,
      shift_smaller_signif => shift_smaller_signif,
      store_sum => store_sum,
      count_zeroes => count_zeroes,
      equal_exps => equal_exps,
      sum_is_zero => sum_is_zero,
      finished_shift => finished_shift,
      a => a,
      b => b,
      y => y
    );

    -- Clock process
    clock <= not clock after clockPeriod / 2;

    stimulus_process : process
    begin

      reset <= '1';
      wait until rising_edge(clock);
      reset <= '0';
      wait until falling_edge(clock);

      for i in 0 to AMNT_OF_TESTS loop
        a_real <= 1.0;
        b_real <= 1.0;
        expected_result <= to_std_logic_vector(to_float(a_real + b_real));

        a <= to_std_logic_vector(to_float(a_real));
        b <= to_std_logic_vector(to_float(b_real));

        buffer_inputs <= '1';
        wait until falling_edge(clock);
        buffer_inputs <= '0';

        load_smaller <= '1';
        wait until falling_edge(clock);
        load_smaller <= '0';

        if equal_exps = '0' then
          shift_smaller_signif <= '1';
          wait until equal_exps = '1';
          shift_smaller_signif <= '0';
        end if;
        wait until falling_edge(clock);

        store_sum <= '1';
        wait until falling_edge(clock);
        store_sum <= '0';

        if sum_is_zero_or_finished_shift = '0' then
          count_zeroes <= '1';
          wait until sum_is_zero_or_finished_shift = '1';
          count_zeroes <= '0';
        else
          count_zeroes <= '0';
        end if;

        wait until falling_edge(clock);
        assert y = expected_result report "incorrect sum" severity failure;
      end loop;

      report "All test cases passed";
      stop;
      wait;
    end process stimulus_process;
end architecture sim;
