library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
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
  signal expected_result : std_logic_vector(31 downto 0);

  begin
    uut_sp_fp_adder: sp_fp_adder_dpath
    port map (
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
      -- Test case 1: a and b are equal
      reset <= '1';
      wait until rising_edge(clock);
      reset <= '0';
      wait until falling_edge(clock);

      a <= "00111111100000000000000000000000";  -- a = 1.0
      b <= "00111111100000000000000000000000";  -- b = 1.0

      buffer_inputs <= '1';
      wait until falling_edge(clock);

      load_smaller <= '1';
      wait until falling_edge(clock);

      if equal_exps = '0' then
        shift_smaller_signif <= '1';
        wait until equal_exps = '1';
        shift_smaller_signif <= '0';
      end if;
      wait until falling_edge(clock);

      store_sum <= '1';
      wait until falling_edge(clock);

      count_zeroes <= '1';
      wait until (sum_is_zero or finished_shift) = '1';
      count_zeroes <= '0';

      -- Expected result: 2.0
      expected_result <= "01000000000000000000000000000000";
      stop;

      wait for 100 ns;

      -- Check the result
      assert y = expected_result
        report "Test Case 1 Failed" severity error;
      
      -- Test case 2: a is smaller than b
      reset <= '1';
      wait for clockPeriod;
      reset <= '0';

      a <= "00111111000000000000000000000000";  -- a = 0.5
      b <= "00111111100000000000000000000000";  -- b = 1.0
      buffer_inputs <= '1';
      load_smaller <= '1';
      shift_smaller_signif <= '1';
      store_sum <= '1';
      count_zeroes <= '1';

      -- Expected result: 1.5
      expected_result <= "00111111110000000000000000000000";

      wait for 100 ns;

      -- Check the result
      assert y = expected_result
        report "Test Case 2 Failed" severity error;

      -- Test case 3: b is smaller than a
      reset <= '1';
      wait for clockPeriod;
      reset <= '0';

      a <= "00111111000000000000000000000000";  -- a = 0.5
      b <= "00111111011000000000000000000000";  -- b = 0.75
      buffer_inputs <= '1';
      load_smaller <= '1';
      shift_smaller_signif <= '1';
      store_sum <= '1';
      count_zeroes <= '1';

      -- Expected result: 1.25
      expected_result <= "00111111100010000000000000000000";

      wait for 100 ns;

      -- Check the result
      assert y = expected_result
        report "Test Case 3 Failed" severity error;

      report "All test cases passed";
      stop;
      wait;
    end process stimulus_process;
end architecture sim;
