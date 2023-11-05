library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.env.stop;

entity tb_hcsr04_interface is
end entity tb_hcsr04_interface;

architecture sim of tb_hcsr04_interface is
  signal clock            : std_logic := '0';
  signal reset            : std_logic := '0';
  signal reset_counters    : std_logic := '0';
  signal generate_pulse    : std_logic := '0';
  signal echo              : std_logic := '0';
  signal store_measurement : std_logic := '0';
  signal watchdog_en       : std_logic := '0';
  signal reset_watchdog    : std_logic := '0';
  signal mensurar         : std_logic;
  signal pulse_sent       : std_logic;
  signal trigger          : std_logic;
  signal timeout          : std_logic;
  signal dist_l           : std_logic_vector(7 downto 0);
  signal dist_h           : std_logic_vector(7 downto 0);

  constant clockPeriod : time := 20 ns; -- Clock period (50 MHz)

  component hcsr04_interface is
    port
    (
      clock            : in std_logic;
      reset            : in std_logic;
      reset_counters    : in std_logic;
      generate_pulse    : in std_logic;
      echo              : in std_logic;
      store_measurement : in std_logic;
      watchdog_en       : in std_logic;
      reset_watchdog    : in std_logic;
      mensurar         : out std_logic;
      pulse_sent       : out std_logic;
      trigger          : out std_logic;
      timeout          : out std_logic;
      dist_l           : out std_logic_vector(7 downto 0);
      dist_h           : out std_logic_vector(7 downto 0)
    );
  end component hcsr04_interface;

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
        ( 6,  882, std_logic_vector(to_unsigned(15, 16)))  --  15cm ( 882us)
      );

  signal pulse_width: time := 1 us;

begin

  uut_hcsr04_interface: hcsr04_interface
  port map
  (
    clock            => clock,
    reset            => reset,
    reset_counters    => reset_counters,
    generate_pulse    => generate_pulse,
    echo              => echo,
    store_measurement => store_measurement,
    watchdog_en       => watchdog_en,
    reset_watchdog    => reset_watchdog,
    mensurar         => mensurar,
    pulse_sent       => pulse_sent,
    trigger          => trigger,
    timeout          => timeout,
    dist_l           => dist_l,
    dist_h           => dist_h
  );

  -- Clock process
  clock <= not clock after clockPeriod / 2;

  stimulus_process : process
  begin
    -- Reset the system
    reset <= '1';
    reset_counters <= '1';
    reset_watchdog <= '1';
    wait for clockPeriod;
    reset <= '0';
    reset_counters <= '0';
    reset_watchdog <= '0';

    for i in test_array_inst'range loop
      wait until mensurar = '1';
      wait until rising_edge(clock);

      -- Generate a pulse
      generate_pulse <= '1';
      reset_counters <= '1';
      wait until trigger = '1';
      wait until pulse_sent = '1';
      assert trigger = '0' report "trigger did not descend" severity failure;
      reset_watchdog <= '1';
      wait until rising_edge(clock);
      generate_pulse <= '0';
      reset_counters <= '0';
      watchdog_en <= '1';
      reset_watchdog <= '0';

      -- Simulate an echo signal
      pulse_width <= test_array_inst(i).duration * 1 us; -- caso de teste "i"
      wait for clockPeriod * i;
      echo <= '1';
      reset_watchdog <= '1';
      wait until rising_edge(clock);
      reset_watchdog <= '0';
      wait for pulse_width - clockPeriod;
      echo <= '0';
      reset_watchdog <= '1';

      wait until rising_edge(clock);
      store_measurement <= '1';
      reset_watchdog <= '0';
      watchdog_en <= '0';
      wait until rising_edge(clock);
      store_measurement <= '0';

      wait until rising_edge(clock);

      assert test_array_inst(i).distance_cm = (dist_h & dist_l) report "distance incorrectly measured" severity error;
    end loop;

    -- Finish the simulation
    report "Calling 'stop'";
    stop;
    wait;
  end process stimulus_process;

end architecture sim;
