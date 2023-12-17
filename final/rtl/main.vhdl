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
      send_data         : in  std_logic;
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

  component register_d is
    generic
    (
      WIDTH : natural := 8 --! @brief Width of the register.
    );
    port
    (
      clock         : in  std_logic; --! @brief System clock signal.
      reset         : in  std_logic; --! @brief System reset signal.
      enable        : in  std_logic; --! @brief Enable signal for the register.
      data_in       : in  std_logic_vector(WIDTH-1 downto 0); --! @brief Input data for the register.
      data_out      : out std_logic_vector(WIDTH-1 downto 0) --! @brief Output data of the register.
    );
  end component register_d;
  
  component sync_par_counter is
    generic
    (
      constant MODU : natural := 16 --! @brief Modulus for the counter.
    );
    port
    (
      clock  : in  std_logic; --! @brief System clock signal.
      reset  : in  std_logic; --! @brief System reset signal.
      cnt_en : in  std_logic; --! @brief Counter enable signal.
      q_in   : in  std_logic_vector(natural(ceil(log2(real(MODU))))-1 downto 0); --! @brief Input value for the counter.
      load   : in  std_logic; --! @brief Load signal for the counter.
      q      : out std_logic_vector(natural(ceil(log2(real(MODU))))-1 downto 0)  --! @brief Output value of the counter.
    );
  end component sync_par_counter;

  -- Signal declarations
  signal lidar_dist          : std_logic_vector(15 downto 0);
  signal hcsr04_dist         : std_logic_vector(15 downto 0);
  signal lidar_dist_buf      : std_logic_vector(15 downto 0);
  signal hcsr04_dist_buf     : std_logic_vector(15 downto 0);
  signal estimate            : std_logic_vector(15 downto 0);
  signal buf_en              : std_logic;
  signal pronto              : std_logic;
  signal kalman_filter_ready : std_logic;
  signal send_data           : std_logic;
  signal lidar_db_dist_l0    : std_logic_vector(6 downto 0);
  signal lidar_db_dist_l1    : std_logic_vector(6 downto 0);
  signal lidar_db_dist_h0    : std_logic_vector(6 downto 0);
  signal lidar_db_dist_h1    : std_logic_vector(6 downto 0);
  signal hcsr04_db_dist_l0   : std_logic_vector(6 downto 0);
  signal hcsr04_db_dist_l1   : std_logic_vector(6 downto 0);
  signal hcsr04_db_dist_h0   : std_logic_vector(6 downto 0);
  signal hcsr04_db_dist_h1   : std_logic_vector(6 downto 0);
  signal q_watchdog : std_logic_vector(natural(ceil(log2(real(4500000))))-1 downto 0);
  constant q_watchdog_max : std_logic_vector(q_watchdog'LENGTH-1 downto 0) := std_logic_vector(to_unsigned(4500000-1, q_watchdog'LENGTH));
  signal s_reset : std_logic;
  signal s_timeout : std_logic;


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
  s_reset <= reset or s_timeout;
  hcsr04_inst : hcsr04
  port map
  (
    clock       => clock,
    reset       => s_reset,
    echo        => echo,
    trigger     => trigger,
    pronto      => pronto,
    dist        => hcsr04_dist,
    db_dist_l0  => hcsr04_db_dist_l0,
    db_dist_l1  => hcsr04_db_dist_l1,
    db_dist_h0  => hcsr04_db_dist_h0,
    db_dist_h1  => hcsr04_db_dist_h1,
    db_estado   => db_estado
  );

  buf_en <= pronto and kalman_filter_ready;

  lidar_dist_reg: register_d
  generic map
  (
    WIDTH => 16
  )
  port map
  (
    clock    => clock,
    reset    => reset,
    enable   => buf_en,
    data_in  => lidar_dist,
    data_out => lidar_dist_buf
  );

  hcsr04_dist_reg: register_d
  generic map
  (
    WIDTH => 16
  )
  port map
  (
    clock    => clock,
    reset    => reset,
    enable   => buf_en,
    data_in  => hcsr04_dist,
    data_out => hcsr04_dist_buf
  );

  kalman_filter_component: kalman_filter
  port map
  (
    clock   => clock,
    reset   => reset,
    i_valid => pronto,
    o_valid => send_data,
    ready   => kalman_filter_ready,
    lidar   => lidar_dist,
    hcsr04  => hcsr04_dist,
    dist    => estimate
  );

  -- Instantiate the Communication Interface component
  comm_interface_inst: comm_interface
  port map
  (
    clock         => clock,
    reset         => reset,
    lidar_dist    => lidar_dist_buf,
    hcsr04_dist   => hcsr04_dist_buf,
    dist_estimate => estimate,
    send_data     => send_data,
    rx            => rx,
    tx            => tx
  );

  posicao_logic: process(estimate)
  begin
    if estimate <= "0000000000001010" then
      posicao <= "111";
    elsif estimate <= "0000000000001111" then
      posicao <= "110";
    elsif estimate <= "0000000000010100" then
      posicao <= "101";
    elsif estimate <= "0000000000011001" then
      posicao <= "100";
    elsif estimate <= "0000000000011110" then
      posicao <= "011";
    elsif estimate <= "0000000000100011" then
      posicao <= "010";
    elsif estimate <= "0000000000101000" then
      posicao <= "001";
    else
      posicao <= "000";
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
  
  watchdog: sync_par_counter
  generic map
  (
    MODU => 4500000 --! @brief Generates a measurement timeout every 100ms.
  )
  port map
  (
    clock => clock,
    reset => pronto,
    cnt_en => '1',
    q_in => (others => '0'),
    load => '0',
    q => q_watchdog
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
  s_timeout <= '1' when q_watchdog = q_watchdog_max else
             '0';
end architecture structural;
