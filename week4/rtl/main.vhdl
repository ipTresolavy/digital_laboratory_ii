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

    -- DC motor interface
    pwm : out std_logic;

    -- debugging
    db_sw       : in  std_logic;                    --! @brief Switch for choosing between lidar and HC-SR04 for debugging.
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
      clock             : in  std_logic;
      reset             : in  std_logic;
      lidar_dist        : in  std_logic_vector(15 downto 0);
      hcsr04_dist       : in  std_logic_vector(15 downto 0);
      dist_estimate     : in  std_logic_vector(15 downto 0);
      send_measurements : in  std_logic;
      send_estimate     : in  std_logic;
      rx                : in  std_logic;
      tx                : out std_logic
    );
  end component comm_interface;

  component controle_servo is
    port (
      clock     : in  std_logic;
      reset     : in  std_logic;
      posicao   : in  std_logic_vector(2 downto 0);
      controle  : out std_logic
    );
  end component controle_servo;

  component sklansky_adder is
    generic
    (
      WIDTH : natural := 16
    );
    port
    (
      a     : in  std_logic_vector(WIDTH-1 downto 0);
      b     : in  std_logic_vector(WIDTH-1 downto 0);
      c_in  : in  std_logic;
      c_out : out std_logic;
      s     : out std_logic_vector(WIDTH-1 downto 0)
    );
  end component sklansky_adder;

  component multiplier_top is
    port
    (
      -- system signals
      clock : in std_logic;  
      reset : in std_logic;

      -- handshake signals
      valid : in  std_logic;
      ready : out std_logic;

      -- data inputs and outputs
      multiplicand : in  std_logic_vector(15 downto 0);
      multiplier   : in  std_logic_vector(15 downto 0);
      product      : out std_logic_vector(31 downto 0)
    );
  end component multiplier_top;

  component divisor_top is
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
  end component divisor_top;

  component hexa7seg is
    port
    (
      hexa : in  std_logic_vector(3 downto 0);
      sseg : out std_logic_vector(6 downto 0)
    );
  end component hexa7seg;

  component kalman_filter is
    port
    (
      -- system signals
      clock : in std_logic;
      reset : in std_logic;

      -- handshake signals
      i_valid : in  std_logic;
      o_valid : out std_logic;
      ready   : out std_logic;

      -- data inputs
      lidar  : in std_logic_vector(15 downto 0);
      hcsr04 : in std_logic_vector(15 downto 0);

      -- data output
      dist : out std_logic_vector(15 downto 0)
    );
  end component kalman_filter;

  -- Signal declarations
  signal lidar_dist        : std_logic_vector(15 downto 0);
  signal hcsr04_dist       : std_logic_vector(15 downto 0);
  signal estimate          : std_logic_vector(15 downto 0);
  signal send_measurements : std_logic;
  signal send_estimate     : std_logic;
  signal lidar_db_dist_l0  : std_logic_vector(6 downto 0);
  signal lidar_db_dist_l1  : std_logic_vector(6 downto 0);
  signal lidar_db_dist_h0  : std_logic_vector(6 downto 0);
  signal lidar_db_dist_h1  : std_logic_vector(6 downto 0);
  signal hcsr04_db_dist_l0 : std_logic_vector(6 downto 0);
  signal hcsr04_db_dist_l1 : std_logic_vector(6 downto 0);
  signal hcsr04_db_dist_h0 : std_logic_vector(6 downto 0);
  signal hcsr04_db_dist_h1 : std_logic_vector(6 downto 0);

  signal posicao   : std_logic_vector(2 downto 0);

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
    pronto      => send_measurements,
    dist        => hcsr04_dist,
    db_dist_l0  => hcsr04_db_dist_l0,
    db_dist_l1  => hcsr04_db_dist_l1,
    db_dist_h0  => hcsr04_db_dist_h0,
    db_dist_h1  => hcsr04_db_dist_h1,
    db_estado   => db_estado
  );

  kalman_filter_component: kalman_filter
  port map
  (
    clock   => clock,
    reset   => reset,
    i_valid => send_measurements,
    o_valid => send_estimate,
    ready   => open,
    lidar   => lidar_dist,
    hcsr04  => hcsr04_dist,
    dist    => estimate
  );

  -- Instantiate the Communication Interface component
  comm_interface_inst: comm_interface
  port map
  (
    clock              => clock,
    reset              => reset,
    lidar_dist         => lidar_dist,
    hcsr04_dist        => hcsr04_dist,
    dist_estimate      => estimate,
    send_measurements  => send_measurements,
    send_estimate      => send_estimate,
    rx                 => rx,
    tx                 => tx
  );

  posicao_logic: process(estimate)
  begin
    if lidar_dist <= "0000000000001010" then
      posicao <= "000";
    elsif lidar_dist <= "0000000000001111" then
      posicao <= "001";
    elsif lidar_dist <= "0000000000010100" then
      posicao <= "010";
    elsif lidar_dist <= "0000000000011001" then
      posicao <= "011";
    elsif lidar_dist <= "0000000000011110" then
      posicao <= "100";
    elsif lidar_dist <= "0000000000100011" then
      posicao <= "101";
    elsif lidar_dist <= "0000000000101000" then
      posicao <= "110";
    else
      posicao <= "111";
    end if;
  end process posicao_logic;

  motor_control: controle_servo
  port map
  (
    clock    => clock,
    reset    => reset,
    posicao  => posicao,
    controle => pwm
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
