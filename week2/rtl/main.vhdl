--! @file
--! @brief VHDL module for the main system integration.
--! @details This module integrates the lidar, HC-SR04, and communication interfaces into a single system.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

--! @entity main
--! @brief Entity for the main system integration.
entity main is
  port
  (
    -- system signals
    clock    : in  std_logic; --! @brief System clock signal.
    reset    : in  std_logic; --! @brief System reset signal.

    -- lidar interface
    lidar_rx : in  std_logic; --! @brief Receive signal for lidar.
    lidar_tx : out std_logic; --! @brief Transmit signal for lidar.

    -- HC-SR04 interface
    echo     : in  std_logic; --! @brief Echo signal from HC-SR04 sensor.
    trigger  : out std_logic; --! @brief Trigger signal for HC-SR04 sensor.

    -- communication interface
    rx       : in  std_logic; --! @brief UART receive signal.
    tx       : out std_logic; --! @brief UART transmit signal.

    -- debugging
    db_sw       : in  std_logic; --! @brief Switch for choosing between lidar and HC-SR04 for debugging.
    db_estado   : out std_logic_vector(6 downto 0); --! @brief Debugging signal for state.
    db_dist_l0  : out std_logic_vector(6 downto 0); --! @brief Debugging signal for lower byte of distance.
    db_dist_l1  : out std_logic_vector(6 downto 0); --! @brief Debugging signal for upper byte of distance.
    db_dist_h0  : out std_logic_vector(6 downto 0); --! @brief Debugging signal for lower byte of distance.
    db_dist_h1  : out std_logic_vector(6 downto 0) --! @brief Debugging signal for upper byte of distance.
  );
end entity main;

architecture structural of main is
  -- Component declarations
  component lidar is
    port
    (
      clock       : in  std_logic;
      reset       : in  std_logic;
      rx          : in  std_logic;
      tx          : out std_logic;
      dist        : out std_logic_vector(15 downto 0);
      db_dist_l0  : out std_logic_vector(6 downto 0);
      db_dist_l1  : out std_logic_vector(6 downto 0);
      db_dist_h0  : out std_logic_vector(6 downto 0);
      db_dist_h1  : out std_logic_vector(6 downto 0)
    );
  end component lidar;

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

  component comm_interface is
    port
    (
      clock       : in  std_logic;
      reset       : in  std_logic;
      lidar_dist  : in  std_logic_vector(15 downto 0);
      hcsr04_dist : in  std_logic_vector(15 downto 0);
      send_data   : in  std_logic;
      rx          : in  std_logic;
      tx          : out std_logic
    );
  end component comm_interface;

  -- Signal declarations
  signal lidar_dist        : std_logic_vector(15 downto 0);
  signal hcsr04_dist       : std_logic_vector(15 downto 0);
  signal send_data         : std_logic;
  signal lidar_db_dist_l0  : std_logic_vector(6 downto 0);
  signal lidar_db_dist_l1  : std_logic_vector(6 downto 0);
  signal lidar_db_dist_h0  : std_logic_vector(6 downto 0);
  signal lidar_db_dist_h1  : std_logic_vector(6 downto 0);
  signal hcsr04_db_dist_l0 : std_logic_vector(6 downto 0);
  signal hcsr04_db_dist_l1 : std_logic_vector(6 downto 0);
  signal hcsr04_db_dist_h0 : std_logic_vector(6 downto 0);
  signal hcsr04_db_dist_h1 : std_logic_vector(6 downto 0);

  signal s_l0 : std_logic_vector(6 downto 0);
  signal s_l1 : std_logic_vector(6 downto 0);
  signal s_h0 : std_logic_vector(6 downto 0);
  signal s_h1 : std_logic_vector(6 downto 0);

begin
  -- Instantiate the Lidar component
  lidar_inst : lidar
  port map
  (
    clock       => clock,
    reset       => reset,
    rx          => lidar_rx,
    tx          => lidar_tx,
    dist        => lidar_dist,
    db_dist_l0  => lidar_db_dist_l0,
    db_dist_l1  => lidar_db_dist_l1,
    db_dist_h0  => lidar_db_dist_h0,
    db_dist_h1  => lidar_db_dist_h1
  );

  -- Instantiate the HCSR04 component
  hcsr04_inst : hcsr04
  port map
  (
    clock       => clock,
    reset       => reset,
    echo        => echo,
    trigger     => trigger,
    pronto      => send_data,
    dist        => hcsr04_dist,
    db_dist_l0  => hcsr04_db_dist_l0,
    db_dist_l1  => hcsr04_db_dist_l1,
    db_dist_h0  => hcsr04_db_dist_h0,
    db_dist_h1  => hcsr04_db_dist_h1,
    db_estado   => db_estado
  );

  -- Instantiate the Communication Interface component
  comm_interface_inst: comm_interface
  port map
  (
    clock       => clock,
    reset       => reset,
    lidar_dist  => lidar_dist,
    hcsr04_dist => hcsr04_dist,
    send_data   => send_data,
    rx          => rx,
    tx          => tx
  );

  -- Debugging signal assignments
  with db_sw select
    db_dist_l0 <= lidar_db_dist_l0 when '1',
						hcsr04_db_dist_l0 when others;

  with db_sw select
    db_dist_l1 <= lidar_db_dist_l1 when '1',
						hcsr04_db_dist_l1 when others;

  with db_sw select
    db_dist_h0 <= lidar_db_dist_h0 when '1',
						hcsr04_db_dist_h0 when others;

  with db_sw select
    db_dist_h1 <= lidar_db_dist_h1 when '1',
						hcsr04_db_dist_h1 when others;

end architecture structural;
