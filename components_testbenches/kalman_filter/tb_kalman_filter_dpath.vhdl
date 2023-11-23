library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.env.stop;

entity tb_kalman_filter_dpath is
end entity tb_kalman_filter_dpath;

architecture sim of tb_kalman_filter_dpath is
  signal clock : std_logic := '0';
  signal reset : std_logic := '0';
  
  signal buffer_inputs, x_en, p_en, diff_src, mult_src, mult_valid, div_src, div_valid, add_src, pred_en : std_logic := '0';
  signal x_src, p_src : std_logic_vector(1 downto 0) := "00";
  signal lidar, hcsr04 : std_logic_vector(15 downto 0) := x"0000";
  signal dist : std_logic_vector(15 downto 0);
  signal mult_ready, div_ready : std_logic;

  constant clockPeriod : time := 20 ns; -- Clock period (50 MHz)
  constant num_tests   : natural := 10;   -- Number of tests
  constant real_dist   : natural := 50;   -- Number of tests

  component kalman_filter_dpath
    port
    (
      clock          : in std_logic;
      reset          : in std_logic;
      buffer_inputs  : in std_logic;
      x_src, p_src   : in std_logic_vector(1 downto 0);
      x_en, p_en     : in std_logic;
      diff_src       : in std_logic;
      mult_src       : in std_logic;
      mult_valid     : in std_logic;
      div_src        : in std_logic;
      div_valid      : in std_logic;
      add_src        : in std_logic;
      pred_en        : in std_logic;
      mult_ready     : out std_logic;
      div_ready      : out std_logic;
      lidar          : in std_logic_vector(15 downto 0);
      hcsr04         : in std_logic_vector(15 downto 0);
      dist           : out std_logic_vector(15 downto 0)
    );
  end component kalman_filter_dpath;

begin
  uut_kalman_filter_dpath : kalman_filter_dpath
  port map
  (
    clock          => clock,
    reset          => reset,
    buffer_inputs  => buffer_inputs,
    x_src          => x_src,
    p_src          => p_src,
    x_en           => x_en,
    p_en           => p_en,
    diff_src       => diff_src,
    mult_src       => mult_src,
    mult_valid     => mult_valid,
    div_src        => div_src,
    div_valid      => div_valid,
    add_src        => add_src,
    pred_en        => pred_en,
    mult_ready     => mult_ready,
    div_ready      => div_ready,
    lidar          => lidar,
    hcsr04         => hcsr04,
    dist           => dist
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

    procedure initialize is
    begin
      lidar  <= std_logic_vector(to_unsigned(real_dist + rand_int(-6, +6), 16));
      hcsr04 <= std_logic_vector(to_unsigned(real_dist + rand_int(-6, +6), 16));
      buffer_inputs <= '1';
      wait until rising_edge(clock);

      x_src <= "11";
      p_src <= "11";
      x_en  <= '1';
      p_en  <= '1';
      wait until rising_edge(clock);
    end initialize;

    procedure predict is
    begin
    end predict;

    procedure update is
    begin
    end update;
    
  begin
    -- Reset the system
    reset <= '1';
    wait for clockPeriod;
    reset <= '0';

    initialize;

    for i in 1 to num_tests loop
      predict;
      update;

      wait for clockPeriod;
    end loop;

    -- Finish the simulation
    report "Calling 'stop'";
    stop;
    wait;
  end process stimulus_process;

end architecture sim;
