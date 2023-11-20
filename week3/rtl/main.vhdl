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
    db_sw       : in  std_logic_vector(1 downto 0); --! @brief Switch for choosing between lidar and HC-SR04 for debugging.
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

  signal P_control : std_logic_vector(15 downto 0);
  signal posicao   : std_logic_vector(2 downto 0);

  signal product  : std_logic_vector(31 downto 0);
  signal quotient : std_logic_vector(31 downto 0);

  signal db_product0 : std_logic_vector(6 downto 0);
  signal db_product1 : std_logic_vector(6 downto 0);
  signal db_product2 : std_logic_vector(6 downto 0);
  signal db_product3 : std_logic_vector(6 downto 0);

  signal db_quotient0 : std_logic_vector(6 downto 0);
  signal db_quotient1 : std_logic_vector(6 downto 0);
  signal db_quotient2 : std_logic_vector(6 downto 0);
  signal db_quotient3 : std_logic_vector(6 downto 0);

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

  P_controller: sklansky_adder
  generic map
  (
    WIDTH => 16
  )
  port map
  (
    a     => lidar_dist,
    b     => "1111111100110111", -- -200
    c_in  => '1',
    c_out => open,
    s     => P_control
  );

  posicao_logic: process(P_control)
  begin
    if P_control <= "0000000011001000" then -- 200
      posicao <= "000";
    elsif P_control <= "0000000010010110" then -- 150
      posicao <= "001";
    elsif P_control <= "0000000001100100" then -- 100
      posicao <= "010";
    elsif P_control <= "0000000000110010" then -- 50
      posicao <= "011";
    elsif P_control <= "0000000000000000" then -- 0
      posicao <= "100";
    elsif P_control <= "1111111111001101" then -- -50
      posicao <= "101";
    elsif P_control <= "1111111110011011" then -- -100
      posicao <= "110";
    else -- -150
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

  multiplier_component: multiplier_top
  port map
  (
    clock        => clock,
    reset        => reset,
    valid        => '1',
    ready        => open,
    multiplicand => lidar_dist,
    multiplier   => hcsr04_dist,
    product      => product
  );

  divisor_component: divisor_top
  port map
  (
    clock        => clock,
    reset        => reset,
    valid        => '1',
    ready        => open,
    dividend     => lidar_dist,
    divisor      => hcsr04_dist,
    quotient     => quotient,
    remainder    => open
  );

  product_h0: hexa7seg
  port map
  (
    hexa => product(3 downto 0),
    sseg => db_product0 
  );

  product_h1: hexa7seg
  port map
  (
    hexa => product(7 downto 4),
    sseg => db_product1 
  );

  product_h2: hexa7seg
  port map
  (
    hexa => product(11 downto 8),
    sseg => db_product2 
  );

  product_h3: hexa7seg
  port map
  (
    hexa => product(15 downto 12),
    sseg => db_product3 
  );

  quotient_h0: hexa7seg
  port map
  (
    hexa => quotient(3 downto 0),
    sseg => db_quotient0 
  );

  quotient_h1: hexa7seg
  port map
  (
    hexa => quotient(7 downto 4),
    sseg => db_quotient1 
  );

  quotient_h2: hexa7seg
  port map
  (
    hexa => quotient(11 downto 8),
    sseg => db_quotient2 
  );

  quotient_h3: hexa7seg
  port map
  (
    hexa => quotient(15 downto 12),
    sseg => db_quotient3 
  );

  -- Debugging signal assignments
  with db_sw select
    db_dist_l0 <= lidar_db_dist_l0 when "00",
						      hcsr04_db_dist_l0 when "01",
                  db_product0 when "10",
                  db_quotient0 when others;

  with db_sw select
    db_dist_l1 <= lidar_db_dist_l1 when "00",
						      hcsr04_db_dist_l1 when "01",
                  db_product1 when "10",
                  db_quotient1 when others;

  with db_sw select
    db_dist_h0 <= lidar_db_dist_h0 when "00",
						      hcsr04_db_dist_h0 when "01",
                  db_product2 when "10",
                  db_quotient2 when others;

  with db_sw select
    db_dist_h1 <= lidar_db_dist_h1 when "00",
						      hcsr04_db_dist_h1 when "01",
                  db_product3 when "10",
                  db_quotient3 when others;

end architecture structural;
