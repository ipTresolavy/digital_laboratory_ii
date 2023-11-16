library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.env.stop;

entity tb_divisor_dpath is
end entity tb_divisor_dpath;

architecture sim of tb_divisor_dpath is
  signal clock            : std_logic := '0';
  signal reset            : std_logic := '0';
  signal load             : std_logic := '0';
  signal shift_quotient   : std_logic := '0';
  signal set_quotient_bit : std_logic := '0';
  signal shift_divisor    : std_logic := '0';
  signal restore_sub      : std_logic := '0';
  signal write_remainder  : std_logic := '0';
  signal neg_remainder    : std_logic;
  signal finished         : std_logic;
  signal dividend         : std_logic_vector(15 downto 0) := (others => '0');
  signal divisor          : std_logic_vector(15 downto 0) := (others => '0');
  signal quotient         : std_logic_vector(31 downto 0);
  signal remainder        : std_logic_vector(31 downto 0);

  constant clockPeriod : time := 20 ns; -- Clock period (50 MHz)
  constant num_tests   : natural := 10;   -- Number of tests

  component divisor_dpath is
    port
    (
      clock            : in  std_logic;
      reset            : in  std_logic;
      load             : in  std_logic;
      shift_quotient   : in  std_logic;
      set_quotient_bit : in  std_logic;
      shift_divisor    : in  std_logic;
      restore_sub      : in  std_logic;
      write_remainder  : in  std_logic;
      neg_remainder    : out std_logic;
      finished         : out std_logic;
      dividend         : in  std_logic_vector(15 downto 0);
      divisor          : in  std_logic_vector(15 downto 0);
      quotient         : out std_logic_vector(31 downto 0);
      remainder        : out std_logic_vector(31 downto 0)
    );
  end component divisor_dpath;

begin
  uut_divisor_dpath: divisor_dpath
  port map
  (
    clock            => clock,
    reset            => reset,
    load             => load,
    shift_quotient   => shift_quotient,
    set_quotient_bit => set_quotient_bit,
    shift_divisor    => shift_divisor,
    restore_sub      => restore_sub,
    write_remainder  => write_remainder,
    neg_remainder    => neg_remainder,
    finished         => finished,
    dividend         => dividend,
    divisor          => divisor,
    quotient         => quotient,
    remainder        => remainder
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
    wait for clockPeriod;
    reset <= '0';

    for i in 1 to num_tests loop
      -- Generate random inputs using rand_int
      dividend <= std_logic_vector(to_unsigned(rand_int(0, 65535), 16));
      divisor  <= std_logic_vector(to_unsigned(rand_int(0, 65535), 16));

      -- Assert load
      load <= '1';
      wait until rising_edge(clock);
      load <= '0';
      wait until falling_edge(clock);

      while finished = '0' loop
        write_remainder <= '1';
        wait until rising_edge(clock);
        write_remainder <= '0';
        wait until falling_edge(clock);

        shift_divisor <= '1';
        if neg_remainder = '1' then
          restore_sub <= '1';
          write_remainder <= '1';
          set_quotient_bit <= '0';
          shift_quotient <= '1';
          wait until rising_edge(clock);
          restore_sub <= '0';
          write_remainder <= '0';
          set_quotient_bit <= '0';
          shift_quotient <= '0';
        else
          set_quotient_bit <= '1';
          shift_quotient <= '1';
          wait until rising_edge(clock);
          set_quotient_bit <= '0';
          shift_quotient <= '0';
        end if;
        shift_divisor <= '0';
        wait until falling_edge(clock);
      end loop;

      -- Assert correctness of the result
      assert (to_integer(unsigned(quotient)) * to_integer(unsigned(divisor)) + to_integer(unsigned(remainder)) =
              to_integer(unsigned(dividend)))
        report "Division result is incorrect"
        severity failure;

      wait for clockPeriod;
    end loop;

    -- Finish the simulation
    report "Calling 'stop'";
    stop;
    wait;
  end process stimulus_process;

end architecture sim;

