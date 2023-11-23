library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.env.stop;

entity tb_signed_divisor is
end entity tb_signed_divisor;

architecture sim of tb_signed_divisor is
  signal clock            : std_logic := '0';
  signal reset            : std_logic := '0';
  signal valid            : std_logic := '0';
  signal ready            : std_logic;
  signal dividend         : std_logic_vector(15 downto 0) := (others => '0');
  signal divisor          : std_logic_vector(15 downto 0) := (others => '0');
  signal quotient         : std_logic_vector(31 downto 0);
  signal remainder        : std_logic_vector(31 downto 0);

  constant clockPeriod : time := 20 ns; -- Clock period (50 MHz)
  constant num_tests   : natural := 100;   -- Number of tests

  component signed_divisor is
    port
    (
      -- system signals
      clock : in std_logic;
      reset : in std_logic;
      
      -- handshake signals
      valid : in  std_logic;
      ready : out std_logic;

      -- data inputs and outputs
      dividend  : in  std_logic_vector(15 downto 0);
      divisor   : in  std_logic_vector(15 downto 0);
      quotient  : out std_logic_vector(31 downto 0);
      remainder : out std_logic_vector(31 downto 0)
    );
  end component signed_divisor;

begin
  uut_signed_divisor: signed_divisor
  port map
  (
    clock     => clock,
    reset     => reset,
    valid     => valid,
    ready     => ready,
    dividend  => dividend,
    divisor   => divisor,
    quotient  => quotient,
    remainder => remainder
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
      dividend <= std_logic_vector(to_signed(rand_int(-2**15, 2**15-1), 16));
      divisor  <= std_logic_vector(to_signed(rand_int(-2**15, 2**15-1), 16));
      wait for 0 ns;
      while divisor = x"0000" loop
        divisor  <= std_logic_vector(to_signed(rand_int(-2**15, 2**15-1), 16));
        wait for 0 ns;
      end loop;

      -- Assert valid
      valid <= '1';
      wait until ready = '0';
      valid <= '0';

      -- Wait for ready
      wait until ready = '1';

      -- Assert correctness of the result
      assert (to_integer(signed(quotient)) * to_integer(signed(divisor)) + to_integer(signed(remainder)) =
              to_integer(signed(dividend)))
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
