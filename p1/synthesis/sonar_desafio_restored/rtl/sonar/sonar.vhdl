library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sonar is
  port (
    clock         : in  std_logic;
    reset         : in  std_logic;
    ligar         : in  std_logic;
    echo          : in  std_logic;
    trigger       : out std_logic;
    pwm           : out std_logic;
    saida_serial  : out std_logic;
    fim_posicao   : out std_logic;
    medida0       : out std_logic_vector (6 downto 0);
    medida1       : out std_logic_vector (6 downto 0);
    medida2       : out std_logic_vector (6 downto 0);
    db_sw         : in  std_logic;
	 entrada_serial : in std_logic;
    db_estado     : out std_logic_vector (6 downto 0);
	 db_trigger    : out std_logic;
	 db_echo       : out std_logic;
	 db_ligar      : out std_logic;
	 db_saida_serial : out std_logic
  );
end entity sonar;

architecture structural of sonar is
  component hexa7seg is
    port (
      hexa : in  std_logic_vector(3 downto 0);
      sseg : out std_logic_vector(6 downto 0)
    );
  end component hexa7seg;

  component contador_m
  generic
  (
    constant M : integer;
    constant N : integer
  );
  port
  (
    clock : in  std_logic;
    zera  : in  std_logic;
    conta : in  std_logic;
    Q     : out std_logic_vector(N-1 downto 0);
    fim   : out std_logic;
    meio  : out std_logic
  );
  end component;
    
  component sonar_fd is
    port
    (
      -- sinais de sistema
      clock              : in  std_logic;
      reset              : in  std_logic;

      -- sinais de controle e condição
      ligar              : in  std_logic;
      generate_pulse     : in  std_logic;
      reset_counters     : in  std_logic;
      store_measurement  : in  std_logic;
      send_distance      : in  std_logic;
      send_angle         : in  std_logic;
      update_angle       : in  std_logic;
      pulse_sent         : out std_logic;
      angle_sent         : out std_logic;
      distance_sent      : out std_logic;
		goto_sweep 		    : out std_logic;
	   goto_alert 		    : out std_logic;
		pronto_rx 			 : out std_logic;

      -- sinais do toplevel
      echo          : in  std_logic;
	   entrada_serial : in std_logic;
      pwm           : out std_logic;
      medida0       : out std_logic_vector (6 downto 0);
      medida1       : out std_logic_vector (6 downto 0);
      medida2       : out std_logic_vector (6 downto 0);
      saida_serial  : out std_logic;
      trigger       : out std_logic;
      db_sw         : in std_logic
    );
  end component sonar_fd;

  component sonar_uc is
    port
    (
      -- sinais de sistema
      clock              : in std_logic;
      reset              : in std_logic;

      -- sinais de controle e condicao
      mensurar           : in  std_logic;
      echo               : in  std_logic;
      pulse_sent         : in  std_logic;
      angle_sent         : in  std_logic;
      distance_sent      : in  std_logic;
		pronto_rx 			 : in  std_logic;
		goto_sweep 		    : in  std_logic;
	   goto_alert 		    : in  std_logic;
      generate_pulse     : out std_logic;
      reset_counters     : out std_logic;
      store_measurement  : out std_logic;
      send_distance      : out std_logic;
      send_angle         : out std_logic;
      update_angle       : out std_logic;

      -- sinais do toplevel
      pronto             : out std_logic;
      db_estado          : out std_logic_vector(3 downto 0) -- estado da UC
    );
  end component sonar_uc;
  signal s_mensurar : std_logic;
  signal s_pulse_sent : std_logic;
  signal s_angle_sent : std_logic;
  signal s_distance_sent : std_logic;
  signal s_generate_pulse : std_logic;
  signal s_reset_counters : std_logic;
  signal s_store_measurement : std_logic;
  signal s_send_angle : std_logic;
  signal s_send_distance : std_logic;
  signal s_update_angle : std_logic;
  signal s_db_estado : std_logic_vector(3 downto 0);
  signal s_reset : std_logic;
  signal s_trigger : std_logic;
  signal s_saida_serial : std_logic;
  signal s_pronto_rx 	: std_logic;
  signal s_goto_alert : std_logic;
  signal s_goto_sweep : std_logic;
  
begin

  continuous_measurement: contador_m
  generic map 
  (
    -- gera um comando de medição a cada 2s
    M => 100000000,
    -- M => 2500000,
    N => 27
  )
  port map
  (
    clock => clock,
    zera  => reset,
    conta => ligar,
    Q     => open,
    fim   => s_mensurar,
    meio  => open
  );

  s_reset <= reset or (not ligar);
  uc: sonar_uc
  port map
  (
      clock              => clock,
      reset              => s_reset,
      mensurar           => s_mensurar,
      echo               => echo,
      pulse_sent         => s_pulse_sent,
      angle_sent         => s_angle_sent,
      distance_sent      => s_distance_sent,
      generate_pulse     => s_generate_pulse,
		pronto_rx 			 => s_pronto_rx,
		goto_sweep 			 => s_goto_sweep,
		goto_alert 			 => s_goto_alert,
      reset_counters     => s_reset_counters,
      store_measurement  => s_store_measurement,
      send_angle         => s_send_angle,
      send_distance      => s_send_distance,
      update_angle       => s_update_angle,
      pronto             => fim_posicao,
      db_estado          => s_db_estado
  );

  fd: sonar_fd
  port map
  (
      clock              => clock,
      reset              => reset,
      ligar              => ligar,
      generate_pulse     => s_generate_pulse,
      reset_counters     => s_reset_counters,
      store_measurement  => s_store_measurement,
      send_angle         => s_send_angle,
      send_distance      => s_send_distance,
      update_angle       => s_update_angle,
      pulse_sent         => s_pulse_sent,
      angle_sent         => s_angle_sent,
      distance_sent      => s_distance_sent,
		pronto_rx 			 => s_pronto_rx,
		goto_sweep 			 => s_goto_sweep,
		goto_alert 			 => s_goto_alert,
      echo               => echo,
		entrada_serial     => entrada_serial,
      pwm                => pwm,
      medida0            => medida0,
      medida1            => medida1,
      medida2            => medida2,
      saida_serial       => s_saida_serial,
      trigger            => s_trigger,
      db_sw              => db_sw
  );

  H5: hexa7seg
  port map
  (
    hexa => s_db_estado,
    sseg => db_estado
  );
  
  db_trigger <= s_trigger;
  trigger <= s_trigger;
  
  db_echo <= echo;

  saida_serial <= s_saida_serial;
  db_saida_serial <= s_saida_serial;
  
  db_ligar <= ligar;
end architecture structural;
