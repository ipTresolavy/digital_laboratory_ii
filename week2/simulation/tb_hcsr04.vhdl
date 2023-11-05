library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.env.stop;

entity tb_hcsr04 is
end entity tb_hcsr04;

architecture sim of tb_hcsr04 is
  signal clock            : std_logic := '0';
  signal reset            : std_logic := '0';
  signal echo             : std_logic := '0';
  signal trigger          : std_logic;
  signal pronto           : std_logic;
  signal dist             : std_logic_vector(15 downto 0);
  signal db_dist_l0       : std_logic_vector(6 downto 0);
  signal db_dist_l1       : std_logic_vector(6 downto 0);
  signal db_dist_h0       : std_logic_vector(6 downto 0);
  signal db_dist_h1       : std_logic_vector(6 downto 0);
  signal db_estado        : std_logic_vector(6 downto 0);

  constant clockPeriod : time := 20 ns; -- Clock period (50 MHz)

  component hcsr04 is
    port
    (
      clock       : in  std_logic;
      reset       : in  std_logic;
      echo        : in  std_logic;
      trigger     : out std_logic;
      pronto      : out std_logic;
      dist        : out std_logic_vector(15 downto 0);
      db_dist_l0  : out std_logic_vector(6 downto 0);
      db_dist_l1  : out std_logic_vector(6 downto 0);
      db_dist_h0  : out std_logic_vector(6 downto 0);
      db_dist_h1  : out std_logic_vector(6 downto 0);
      db_estado   : out std_logic_vector(6 downto 0)
    );
  end component hcsr04;

  type test_array_type is record
      id    : natural; 
      duration : integer;     
      distance_cm : std_logic_vector(15 downto 0);     
  end record;

  type test_array is array (natural range <>) of test_array_type;
  constant test_array_inst : test_array :=
      ( 
        ( 1,  294, std_logic_vector(to_unsigned(5, 16))), --   5cm ( 294us)
        ( 2,  353, std_logic_vector(to_unsigned(6, 16))), --   6cm ( 353us)
        ( 3, 5882, std_logic_vector(to_unsigned(100, 16))), -- 100cm (5882us)
        ( 4, 6176, std_logic_vector(to_unsigned(105, 16))), -- 105cm (6176us)
        ( 5,  882, std_logic_vector(to_unsigned(15, 16))), --  15cm ( 882us)
        ( 6,17646, std_logic_vector(to_unsigned(300, 16))) --  300cm ( 17646us)
      );

  signal pulse_width: time := 1 us;

begin

  uut_hcsr04: hcsr04
  port map
  (
    clock       => clock,
    reset       => reset,
    echo        => echo,
    trigger     => trigger,
    pronto      => pronto,
    dist        => dist,
    db_dist_l0  => db_dist_l0,
    db_dist_l1  => db_dist_l1,
    db_dist_h0  => db_dist_h0,
    db_dist_h1  => db_dist_h1,
    db_estado   => db_estado
  );

  -- Clock process
  clock <= not clock after clockPeriod / 2;

  stimulus_process : process
  begin
    -- Reset the system
    reset <= '1';
    wait for clockPeriod;
    reset <= '0';

    -- Initialize variables
    echo <= '0';
    for i in test_array_inst'range loop
      report "test case " & integer'image(test_array_inst(i).id);
      wait until trigger = '1';
      wait until trigger = '0';

      pulse_width <= test_array_inst(i).duration * 1 us;

      wait for clockPeriod*i;

      -- Simulate an echo signal
      echo <= '1';
      wait for pulse_width;
      echo <= '0';

      wait until pronto = '1';
      wait until pronto = '0';

      assert test_array_inst(i).distance_cm = dist report "distance incorrectly measured" severity error;
    end loop;

    -- Finish the simulation
    report "Calling 'stop'";
    stop;
    wait;
  end process stimulus_process;
end architecture sim;
