library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exp4_trena is
  port (
    clock         : in std_logic;
    reset         : in std_logic;
    mensurar      : in std_logic;
    echo          : in std_logic;
    trigger       : out std_logic;
    saida_serial  : out std_logic;
    medida0       : out std_logic_vector (6 downto 0);
    medida1       : out std_logic_vector (6 downto 0);
    medida2       : out std_logic_vector (6 downto 0);
    pronto        : out std_logic;
    db_estado     : out std_logic_vector (6 downto 0)
  );
end entity exp4_trena;

architecture structural of exp4_trena is
  component edge_detector is
    port (  
      clock     : in  std_logic;
      signal_in : in  std_logic;
      output    : out std_logic
    );
  end component edge_detector;
  signal s_mensurar_ed : std_logic;

  component exp4_trena_fd is
    port
    (
      -- sinais de sistema
      clock              : in  std_logic;
      reset              : in  std_logic;

      -- sinais de controle e condição
      generate_pulse     : in  std_logic;
      reset_counters     : in  std_logic;
      store_measurement  : in  std_logic;
      send_measurement   : in  std_logic;
      pulse_sent         : out std_logic;
      measurement_sent   : out std_logic;

      -- sinais do toplevel
      echo          : in std_logic;
      medida0       : out std_logic_vector (6 downto 0);
      medida1       : out std_logic_vector (6 downto 0);
      medida2       : out std_logic_vector (6 downto 0);
      saida_serial  : out std_logic;
      trigger       : out std_logic
    );
  end component exp4_trena_fd;

  component exp4_trena_uc is
    port
    (
      -- sinais de sistema
      clock              : in std_logic;
      reset              : in std_logic;

      -- sinais de controle e condição
      mensurar           : in  std_logic;
      echo               : in  std_logic;
      pulse_sent         : in  std_logic;
      measurement_sent   : in  std_logic;
      generate_pulse     : out std_logic;
      reset_counters     : out std_logic;
      store_measurement  : out std_logic;
      send_measurement   : out std_logic;

      -- sinais do toplevel
      pronto             : out std_logic;
      db_estado          : out std_logic_vector(3 downto 0) -- estado da UC
    );
  end component exp4_trena_uc;

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


  signal s_pulse_sent : std_logic;
  signal s_measurement_sent : std_logic;
  signal s_generate_pulse : std_logic;
  signal s_reset_counters : std_logic;
  signal s_store_measurement : std_logic;
  signal s_send_measurement : std_logic;
  signal s_db_estado : std_logic_vector(3 downto 0);
  signal s_tick : std_logic;
begin

  DB: edge_detector
  port map
  (
    clock     => clock,
    signal_in => mensurar,
    output    => s_mensurar_ed
  );
  
  -- gerador de tick
  -- fator de divisao para 9600 bauds (5208=50M/9600)
  -- fator de divisao para 115.200 bauds (434=50M/115200)
  U3_TICK: contador_m 
	 		 generic map (
	 			  M => 434, -- 115200 bauds
	 			  N => 13
			 ) 
			 port map (
				  clock => clock, 
				  zera  => reset, 
				  conta => s_send_measurement, 
				  Q     => open, 
				  fim   => s_tick, 
				  meio  => open
			 );

  uc: exp4_trena_uc
  port map
  (
      clock              => clock,
      reset              => reset,
      mensurar           => s_mensurar_ed,
      echo               => echo,
      pulse_sent         => s_pulse_sent,
      measurement_sent   => s_measurement_sent,
      generate_pulse     => s_generate_pulse,
      reset_counters     => s_reset_counters,
      store_measurement  => s_store_measurement,
      send_measurement   => s_send_measurement,
      pronto             => pronto,
      db_estado          => s_db_estado
  );

  fd: exp4_trena_fd
  port map
  (
      clock              => clock,
      reset              => reset,
      generate_pulse     => s_generate_pulse,
      reset_counters     => s_reset_counters,
      store_measurement  => s_store_measurement,
      send_measurement   => s_tick,
      pulse_sent         => s_pulse_sent,
      measurement_sent   => s_measurement_sent,
      echo               => echo,
      medida0            => medida0,
      medida1            => medida1,
      medida2            => medida2,
      saida_serial       => saida_serial,
      trigger            => trigger
  );

  H5: hexa7seg
  port map
  (
    hexa => s_db_estado,
    sseg => db_estado
  );

end architecture structural;
