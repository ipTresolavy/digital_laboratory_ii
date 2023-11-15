library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;
use std.env.stop;

entity tb_multiplier_dpath is
end entity tb_multiplier_dpath;

architecture sim of tb_multiplier_dpath is
  signal clock            : std_logic := '0';
  signal reset            : std_logic := '0';
  signal load             : std_logic := '0';
  signal shift_operands   : std_logic := '0';
  signal finished         : std_logic;
  signal multiplicand     : std_logic_vector(15 downto 0) := (others => '0');
  signal multiplier       : std_logic_vector(15 downto 0) := (others => '0');
  signal product          : std_logic_vector(31 downto 0);

  constant clockPeriod : time := 20 ns; -- Clock period (50 MHz)
  constant num_tests   : natural := 100;   -- Number of tests

  component multiplier_dpath is
    port
    (
      clock         : in  std_logic;
      reset         : in  std_logic;
      load          : in  std_logic;
      shift_operands: in  std_logic;
      finished      : out std_logic;
      multiplicand  : in  std_logic_vector(15 downto 0);
      multiplier    : in  std_logic_vector(15 downto 0);
      product       : out std_logic_vector(31 downto 0)
    );
  end component multiplier_dpath;

  begin
    uut_multiplier_dpath: multiplier_dpath
    port map
    (
      clock          => clock,
      reset          => reset,
      load           => load,
      shift_operands => shift_operands,
      finished       => finished,
      multiplicand   => multiplicand,
      multiplier     => multiplier,
      product        => product
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

      for i in 1 to num_tests loop
        -- Generate random inputs using rand_int
        multiplicand <= std_logic_vector(to_unsigned(rand_int(0, 65535), 16));
        multiplier   <= std_logic_vector(to_unsigned(rand_int(0, 65535), 16));
        
        -- Load operands
        load <= '1';
        wait until rising_edge(clock);
        load <= '0';

        -- Shift operands
        shift_operands <= '1';

        -- Wait for the result
        wait until finished = '1';
        wait until rising_edge(clock);
        shift_operands <= '0';
        wait until falling_edge(clock);

        -- Assert correctness of the result
        assert (to_integer(unsigned(product)) = to_integer(unsigned(multiplicand)) * to_integer(unsigned(multiplier)))
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
