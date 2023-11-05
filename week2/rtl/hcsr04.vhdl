library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity hcsr04 is
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
end entity hcsr04;

architecture structural of hcsr04 is
  component hexa7seg is
      port (
          hexa : in  std_logic_vector(3 downto 0);
          sseg : out std_logic_vector(6 downto 0)
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
      -- sinais de sistema
      clock              : in std_logic;
      reset              : in std_logic;

      -- sinais de controle e condicao
      mensurar           : in  std_logic;
      echo               : in  std_logic;
      pulse_sent         : in  std_logic;
      timeout            : in  std_logic;
      generate_pulse     : out std_logic;
      reset_counters     : out std_logic;
      store_measurement  : out std_logic;
      watchdog_en        : out std_logic;
      reset_watchdog     : out std_logic;

      -- sinais do toplevel
      pronto             : out std_logic;
      db_estado          : out std_logic_vector(3 downto 0) -- estado da UC
    );
  end component hcsr04_ctrl;

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
  
end architecture structural;
