--! @file
--! @brief VHDL module for interfacing with the HCSR04 ultrasonic sensor.
--! @details This module provides the interface logic for the HCSR04 ultrasonic sensor,
--!          including pulse generation, echo timing, and distance measurement.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

--! @entity hcsr04_interface
--! @brief Entity for interfacing with the HCSR04 ultrasonic sensor.
entity hcsr04_interface is
  port
  (
    clock            : in  std_logic; --! @brief System clock signal.
    reset            : in  std_logic; --! @brief System reset signal.
    reset_counters    : in  std_logic; --! @brief Signal to reset the counters.
    generate_pulse    : in  std_logic; --! @brief Signal to generate a pulse.
    echo              : in  std_logic; --! @brief Echo signal from the sensor.
    store_measurement : in  std_logic; --! @brief Signal to store the measurement.
    watchdog_en       : in  std_logic; --! @brief Enable signal for the watchdog timer.
    reset_watchdog    : in  std_logic; --! @brief Reset signal for the watchdog timer.
    mensurar         : out std_logic; --! @brief Signal to trigger a measurement.
    pulse_sent       : out std_logic; --! @brief Signal indicating a pulse was sent.
    trigger          : out std_logic; --! @brief Trigger signal to the sensor.
    timeout          : out std_logic; --! @brief Timeout signal.
    dist_l           : out std_logic_vector(7 downto 0); --! @brief Lower byte of the measured distance.
    dist_h           : out std_logic_vector(7 downto 0)  --! @brief Higher byte of the measured distance.
  );
end entity hcsr04_interface;

architecture rtl of hcsr04_interface is
  -- Component declarations
  component gerador_pulso is
    generic
    (
      largura: integer:= 25 --! @brief Pulse width.
    );
    port
    (
      clock  : in  std_logic; --! @brief System clock signal.
      reset  : in  std_logic; --! @brief System reset signal.
      gera   : in  std_logic; --! @brief Signal to start pulse generation.
      para   : in  std_logic; --! @brief Signal to stop pulse generation.
      pulso  : out std_logic; --! @brief Output pulse signal.
      pronto : out std_logic  --! @brief Signal indicating pulse generation is complete.
    );
  end component gerador_pulso;

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
      data_out      : out std_logic_vector(WIDTH-1 downto 0)  --! @brief Output data of the register.
    );
  end component register_d;

  -- Signal declarations
  signal s_half : std_logic;
  signal q_mensurar : std_logic_vector(natural(ceil(log2(real(2500000))))-1 downto 0);
  signal q : std_logic_vector(natural(ceil(log2(real(2941))))-1 downto 0);
  signal q_dist : std_logic_vector(15 downto 0);
  signal s_zera : std_logic;
  signal s_watchdog_clear : std_logic;
  signal q_watchdog : std_logic_vector(natural(ceil(log2(real(4500000))))-1 downto 0);
  signal dist_h_l : std_logic_vector(15 downto 0);

  -- Constant declarations
  constant q_watchdog_max : std_logic_vector(q_watchdog'LENGTH-1 downto 0) := std_logic_vector(to_unsigned(4500000-1, q_watchdog'LENGTH));
  constant q_max : std_logic_vector(q'LENGTH-1 downto 0) := std_logic_vector(to_unsigned(2941/2, q'LENGTH));
  constant q_mensurar_max : std_logic_vector(q_mensurar'LENGTH-1 downto 0) := std_logic_vector(to_unsigned(2500000-1, q_mensurar'LENGTH));

begin
  -- Instantiations and port mappings
  mensurar_counter: sync_par_counter
  generic map
  (
    MODU => 2500000 --! @brief Generates a measurement command every 50ms.
  )
  port map
  (
    clock => clock,
    reset => reset,
    cnt_en => '1',
    q_in => (others => '0'),
    load => '0',
    q => q_mensurar
  );
  mensurar <= '1' when q_mensurar = q_mensurar_max else
              '0';

  s_zera <= reset or reset_counters;
  
  pulse_generator: gerador_pulso
  generic map
  (
    largura => 500 --! @brief 10us * 50MHz.
  )
  port map
  (
    clock  => clock,
    reset  => reset,
    gera   => generate_pulse,
    para   => '0',
    pulso  => trigger,
    pronto => pulse_sent
  );

  tick_generator: sync_par_counter
  generic map
  (
    MODU => 2941 --! @brief Divides the 50MHz clock by 5882/2.
  )
  port map
  (
    clock => clock,
    reset => s_zera,
    cnt_en => echo,
    q_in => (others => '0'),
    load => '0',
    q => q
  );
  s_half <= '1' when q = q_max else
            '0';

  dist_counter: sync_par_counter
  generic map
  (
    MODU => 2**16 --! @brief 16 bits output.
  )
  port map
  (
    clock => clock,
    reset => s_zera,
    cnt_en => s_half,
    q_in => (others => '0'),
    load => '0',
    q => q_dist
  );

  q_dist_reg: register_d
  generic map
  (
    WIDTH => 16
  )
  port map
  (
    clock    => clock,
    reset    => reset,
    enable   => store_measurement,
    data_in  => q_dist,
    data_out => dist_h_l
  );
  dist_h <= dist_h_l(15 downto 8);
  dist_l <= dist_h_l(7 downto 0);

  --s_watchdog_clear <= reset or reset_watchdog;
  s_watchdog_clear <= reset;
  watchdog: sync_par_counter
  generic map
  (
    MODU => 4500000 --! @brief Generates a measurement timeout every 100ms.
  )
  port map
  (
    clock => clock,
    reset => s_watchdog_clear,
    cnt_en => watchdog_en,
    q_in => (others => '0'),
    load => reset_watchdog,
    q => q_watchdog
  );
  timeout <= '1' when q_watchdog = q_watchdog_max else
             '0';
  
end architecture rtl;
