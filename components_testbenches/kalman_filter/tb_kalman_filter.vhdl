library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.env.stop;

entity tb_kalman_filter is
end entity tb_kalman_filter;

architecture sim of tb_kalman_filter is
  signal clock : std_logic := '0';
  signal reset : std_logic := '0';
  
  signal i_valid, o_valid, ready : std_logic := '0';
  signal lidar, hcsr04, dist : std_logic_vector(15 downto 0) := (others => '0');

  constant clockPeriod : time := 20 ns; -- Clock period (50 MHz)
  constant num_tests   : natural := 5;   -- Number of tests

  component kalman_filter
    port
    (
      clock          : in std_logic;
      reset          : in std_logic;
      i_valid        : in std_logic;
      o_valid        : out std_logic;
      ready          : out std_logic;
      lidar          : in std_logic_vector(15 downto 0);
      hcsr04         : in std_logic_vector(15 downto 0);
      dist           : out std_logic_vector(15 downto 0)
    );
  end component kalman_filter;

begin
  uut_kalman_filter : kalman_filter
  port map
  (
    clock          => clock,
    reset          => reset,
    i_valid        => i_valid,
    o_valid        => o_valid,
    ready          => ready,
    lidar          => lidar,
    hcsr04         => hcsr04,
    dist           => dist
  );

  -- Clock process
  clock <= not clock after clockPeriod / 2;

  stimulus_process : process
    variable seed1 : integer := 123456789; -- Initial seed value
    variable seed2 : integer := 987654321; -- Initial seed value
    variable real_dist : natural := 50;
    variable valid_output : boolean := false;

    impure function rand_int(min_val, max_val : integer) return integer is
      variable r : real;
    begin
      uniform(seed1, seed2, r);
      return integer(
        round(r * real(max_val - min_val + 1) + real(min_val) - 0.5));
    end function;

    procedure initialize is
    begin
      real_dist := rand_int(10, 400);
      wait for 0 ns;
      lidar  <= std_logic_vector(to_unsigned(real_dist + rand_int(-6, +6), 16));
      hcsr04 <= std_logic_vector(to_unsigned(real_dist + rand_int(-2, +2), 16));
      i_valid <= '1';
      wait until ready = '0';
      wait until rising_edge(clock);
      i_valid <= '0';
    end initialize;

  begin
    -- Reset the system
    reset <= '1';
    wait for clockPeriod;
    reset <= '0';

    initialize;

    for i in 1 to num_tests loop
      for i in 1 to 100 loop
        wait until ready = '1';
        wait until rising_edge(clock);
        lidar   <= std_logic_vector(to_unsigned(real_dist + rand_int(-6, +6), 16));
        hcsr04  <= std_logic_vector(to_unsigned(real_dist + rand_int(-2, +2), 16));
        i_valid <= '1';
        wait until ready = '0';
        wait until rising_edge(clock);
        i_valid <= '0';

        wait until o_valid = '1';
        wait until rising_edge(clock);
      end loop;
      real_dist := rand_int(10, 400);
      wait for 0 ns;
    end loop;

    -- Finish the simulation
    report "Calling 'stop'";
    stop;
    wait;
  end process stimulus_process;
end architecture sim;
