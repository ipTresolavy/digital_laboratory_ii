library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.env.stop;

entity tb_signed_multiplier is
end entity tb_signed_multiplier;

architecture sim of tb_signed_multiplier is
  signal clock           : std_logic := '0';
  signal reset           : std_logic := '0';
  signal valid           : std_logic := '0';
  signal ready           : std_logic;
  signal multiplicand    : std_logic_vector(15 downto 0) := (others => '0');
  signal multiplier      : std_logic_vector(15 downto 0) := (others => '0');
  signal tmp_multiplicand    : std_logic_vector(15 downto 0) := (others => '0');
  signal tmp_multiplier      : std_logic_vector(15 downto 0) := (others => '0');
  signal product         : std_logic_vector(31 downto 0);

  constant clockPeriod : time := 20 ns; -- Clock period (50 MHz)
  constant num_tests   : natural := 100;  -- Number of tests

  component signed_multiplier is
    port
    (
      clock          : in std_logic;  
      reset          : in std_logic;
      valid          : in std_logic;
      ready          : out std_logic;
      multiplicand   : in std_logic_vector(15 downto 0);
      multiplier     : in std_logic_vector(15 downto 0);
      product        : out std_logic_vector(31 downto 0)
    );
  end component signed_multiplier;

begin
  uut_signed_multiplier: signed_multiplier
  port map
  (
    clock        => clock,
    reset        => reset,
    valid        => valid,
    ready        => ready,
    multiplicand => multiplicand,
    multiplier   => multiplier,
    product      => product
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
      multiplicand <= std_logic_vector(to_signed(rand_int(-2**15, 2**15-1), 16));
      multiplier   <= std_logic_vector(to_signed(rand_int(-2**15, 2**15-1), 16));

      -- Assert valid
      valid <= '1';
      wait until rising_edge(clock);
      valid <= '0';
      wait for 0 ns;
      tmp_multiplicand <= multiplicand;
      tmp_multiplier <= multiplier;
      multiplicand <= (others => '0');
      multiplier <= (others => '0');


      -- Wait for the result
      wait until ready = '1';
      wait until rising_edge(clock);

      -- Assert correctness of the result
      assert (to_integer(signed(product)) = to_integer(signed(tmp_multiplicand)) * to_integer(signed(tmp_multiplier)))
        report "Multiplication result is incorrect"
        severity failure;

      wait for clockPeriod;
    end loop;

    -- Finish the simulation
    report "Calling 'stop'";
    stop;
    wait;
  end process stimulus_process;

end architecture sim;
