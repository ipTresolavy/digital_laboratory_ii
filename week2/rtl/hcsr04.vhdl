--! @file
--! @brief VHDL module for interfacing with the HCSR04 ultrasonic sensor.
--! @details This module provides an interface to the HCSR04 ultrasonic sensor,
--!          handling the generation of trigger pulses, echo timing, and distance calculation.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

--! @entity hcsr04
--! @brief Entity for interfacing with the HCSR04 ultrasonic sensor.
entity hcsr04 is
  port
  (
    clock       : in  std_logic; --! @brief System clock signal.
    reset       : in  std_logic; --! @brief System reset signal.
    echo        : in  std_logic; --! @brief Echo signal from the sensor.
    trigger     : out std_logic; --! @brief Trigger signal to the sensor.
    pronto      : out std_logic; --! @brief Signal indicating the process is complete.
    dist        : out std_logic_vector(15 downto 0); --! @brief Distance measured by the sensor.
    db_dist_l0  : out std_logic_vector(6 downto 0); --! @brief Debug signal for lower nibble of lower byte of distance.
    db_dist_l1  : out std_logic_vector(6 downto 0); --! @brief Debug signal for upper nibble of lower byte of distance.
    db_dist_h0  : out std_logic_vector(6 downto 0); --! @brief Debug signal for lower nibble of upper byte of distance.
    db_dist_h1  : out std_logic_vector(6 downto 0); --! @brief Debug signal for upper nibble of upper byte of distance.
    db_estado   : out std_logic_vector(6 downto 0)  --! @brief Debug signal representing the state of the control unit.
  );
end entity hcsr04;

architecture structural of hcsr04 is
  -- Component declarations
  component hexa7seg is
      port (
          hexa : in  std_logic_vector(3 downto 0); --! @brief 4-bit hexadecimal input.
          sseg : out std_logic_vector(6 downto 0)  --! @brief 7-segment display output.
      );
  end component hexa7seg;

  component hcsr04_interface is
    port
    (
      clock            : in  std_logic;
      reset            : in  std_logic;
      reset_counters    : in  std_logic;
      generate_pulse    : in  std_logic;
      echo              : in  std_logic;
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

  component hcsr04_ctrl is
    port
    (
      clock              : in std_logic;
      reset              : in std_logic;
      mensurar           : in  std_logic;
      echo               : in  std_logic;
      pulse_sent         : in  std_logic;
      timeout            : in  std_logic;
      generate_pulse     : out std_logic;
      reset_counters     : out std_logic;
      store_measurement  : out std_logic;
      watchdog_en        : out std_logic;
      reset_watchdog     : out std_logic;
      pronto             : out std_logic;
      db_estado          : out std_logic_vector(3 downto 0)
    );
  end component hcsr04_ctrl;

  -- Signal declarations
  signal reset_counters : std_logic;
  signal generate_pulse : std_logic;
  signal mensurar : std_logic;
  signal pulse_sent : std_logic;
  signal store_measurement : std_logic;
  signal watchdog_en : std_logic;
  signal reset_watchdog : std_logic;
  signal timeout : std_logic;
  signal s_db_estado : std_logic_vector(3 downto 0);
  signal dist_l : std_logic_vector(7 downto 0);
  signal dist_h : std_logic_vector(7 downto 0);
  
begin
  -- Instantiations and port mappings
  hcsr04_interface_inst: hcsr04_interface
  port map
  (
    clock             => clock,
    reset             => reset,
    reset_counters    => reset_counters,
    generate_pulse    => generate_pulse,
    echo              => echo,
    store_measurement => store_measurement,
    watchdog_en       => watchdog_en,
    reset_watchdog    => reset_watchdog,
    timeout           => timeout,
    mensurar          => mensurar,
    pulse_sent        => pulse_sent,
    trigger           => trigger,
    dist_l            => dist_l,
    dist_h            => dist_h
  );

  hcsr04_ctrl_inst: hcsr04_ctrl
  port map
  (
    clock => clock,
    reset => reset,
    mensurar => mensurar,
    echo => echo,
    pulse_sent => pulse_sent,
    generate_pulse => generate_pulse,
    reset_counters => reset_counters,
    store_measurement => store_measurement,
    watchdog_en => watchdog_en,
    reset_watchdog => reset_watchdog,
    timeout => timeout,
    pronto => pronto,
    db_estado => s_db_estado
  );
  
  H0: hexa7seg
  port map
  (
    hexa => dist_l(3 downto 0),
    sseg => db_dist_l0
  );

  H1: hexa7seg
  port map
  (
    hexa => dist_l(7 downto 4),
    sseg => db_dist_l1
  );

  H2: hexa7seg
  port map
  (
    hexa => dist_h(3 downto 0),
    sseg => db_dist_h0
  );

  H3: hexa7seg
  port map
  (
    hexa => dist_h(7 downto 4),
    sseg => db_dist_h1
  );
  
  H5: hexa7seg
  port map
  (
    hexa => s_db_estado,
    sseg => db_estado
  );

  -- Concatenate the high and low distance signals
  dist <= dist_h & dist_l;
  
end architecture structural;
