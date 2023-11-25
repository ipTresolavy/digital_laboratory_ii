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
  constant num_tests   : natural := 5;   -- Number of tests

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
      lidar  <= std_logic_vector(to_unsigned(real_dist + rand_int(-6, +6), 16));
      hcsr04 <= std_logic_vector(to_unsigned(real_dist + rand_int(-2, +2), 16));
      buffer_inputs <= '1';
      wait until rising_edge(clock);
      buffer_inputs <= '0';

      x_src <= "11";
      p_src <= "11";
      x_en  <= '1';
      p_en  <= '1';
      wait until rising_edge(clock);
      x_src <= "00";
      p_src <= "00";
      x_en  <= '0';
      p_en  <= '0';
    end initialize;

    procedure predict is
    begin
      x_src <= "00";
      p_src <= "00";
      x_en  <= '1';
      p_en  <= '1';
      pred_en <= '1';
      wait until rising_edge(clock);
      x_src <= "00";
      p_src <= "00";
      x_en  <= '0';
      p_en  <= '0';
      pred_en <= '0';
    end predict;

    procedure lidar_update is
    begin
      lidar  <= std_logic_vector(to_unsigned(real_dist + rand_int(-6, +6), 16));
      hcsr04 <= std_logic_vector(to_unsigned(real_dist + rand_int(-2, +2), 16));
      buffer_inputs <= '1';
      wait until rising_edge(clock);
      buffer_inputs <= '0';

      -- x update
      diff_src   <= '1';
      mult_src   <= '0';
      mult_valid <= '1';
      wait until mult_ready = '0';
      wait until rising_edge(clock);
      mult_valid <= '0';
      wait until mult_ready = '1';
      wait until rising_edge(clock);
      diff_src   <= '0';
      mult_src   <= '0';

      div_src   <= '1';
      div_valid <= '1';
      wait until div_ready = '0';
      wait until rising_edge(clock);
      div_valid <= '0';
      wait until div_ready = '1';
      wait until rising_edge(clock);
      div_src   <= '0';

      add_src <= '0';
      x_src <= "10";
      x_en <= '1';
      wait until rising_edge(clock);
      add_src <= '0';
      x_src <= "00";
      x_en <= '0';

      -- p update
      mult_src   <= '1';
      mult_valid <= '1';
      wait until mult_ready = '0';
      wait until rising_edge(clock);
      mult_valid <= '0';
      wait until mult_ready = '1';
      wait until rising_edge(clock);
      mult_src   <= '0';

      div_src   <= '1';
      div_valid <= '1';
      wait until div_ready = '0';
      wait until rising_edge(clock);
      div_valid <= '0';
      wait until div_ready = '1';
      wait until rising_edge(clock);
      div_src   <= '0';

      add_src <= '1';
      p_src <= "10";
      p_en <= '1';
      wait until rising_edge(clock);
      add_src <= '0';
      p_src <= "00";
      p_en <= '0';

    end lidar_update;

    procedure hcsr04_update is
    begin
      -- x update
      diff_src   <= '0';
      mult_src   <= '0';
      mult_valid <= '1';
      wait until mult_ready = '0';
      wait until rising_edge(clock);
      mult_valid <= '0';
      wait until mult_ready = '1';
      wait until rising_edge(clock);
      diff_src   <= '0';
      mult_src   <= '0';

      div_src   <= '0';
      div_valid <= '1';
      wait until div_ready = '0';
      wait until rising_edge(clock);
      div_valid <= '0';
      wait until div_ready = '1';
      wait until rising_edge(clock);
      div_src   <= '0';

      add_src <= '0';
      x_src <= "10";
      x_en <= '1';
      wait until rising_edge(clock);
      add_src <= '0';
      x_src <= "00";
      x_en <= '0';

      -- p update
      mult_src   <= '1';
      mult_valid <= '1';
      wait until mult_ready = '0';
      wait until rising_edge(clock);
      mult_valid <= '0';
      wait until mult_ready = '1';
      wait until rising_edge(clock);
      mult_src   <= '0';

      div_src   <= '0';
      div_valid <= '1';
      wait until div_ready = '0';
      wait until rising_edge(clock);
      div_valid <= '0';
      wait until div_ready = '1';
      wait until rising_edge(clock);
      div_src   <= '0';

      add_src <= '1';
      p_src <= "10";
      p_en <= '1';
      wait until rising_edge(clock);
      add_src <= '0';
      p_src <= "00";
      p_en <= '0';
    end hcsr04_update;
    
  begin
    -- Reset the system
    reset <= '1';
    wait for clockPeriod;
    reset <= '0';

    initialize;

    for i in 1 to num_tests loop
      for i in 1 to 100 loop
        predict;
        lidar_update;
        hcsr04_update;
        valid_output := true;
        wait until rising_edge(clock);
        valid_output := false;
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
