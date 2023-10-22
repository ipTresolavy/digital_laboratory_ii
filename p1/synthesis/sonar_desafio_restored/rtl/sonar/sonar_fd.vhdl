library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity sonar_fd is
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
    goto_sweep 		  : out std_logic;
	 goto_alert 		  : out std_logic;
	 pronto_rx 			  : out std_logic;
	 

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
end entity sonar_fd;

architecture rtl of sonar_fd is
  component contadorg_updown_m is
    generic
    (
      constant M: integer := 50 -- modulo do contador
    );
    port
    (
      clock  : in  std_logic;
      zera_as: in  std_logic;
      zera_s : in  std_logic;
      conta  : in  std_logic;
      Q      : out std_logic_vector (natural(ceil(log2(real(M))))-1 downto 0);
      inicio : out std_logic;
      fim    : out std_logic;
      meio   : out std_logic 
    );
  end component;
  component circuito_pwm is
    generic
    (
      conf_periodo  : integer := 1000000;  -- periodo do sinal pwm [1000000 => f=50Hz (20ms)]
      largura_000   : integer :=   35000;  -- largura do pulso p/ 000 [35000 => 0.7ms]
      largura_001   : integer :=   45700;  -- largura do pulso p/ 001 [45700 => 0.914ms]
      largura_010   : integer :=   56450;  -- largura do pulso p/ 010 [56450 => 1.129ms]
      largura_011   : integer :=   67150;  -- largura do pulso p/ 011 [67150 => 1.343ms]
      largura_100   : integer :=   77850;  -- largura do pulso p/ 100 [77850 => 1.557ms]
      largura_101   : integer :=   88550;  -- largura do pulso p/ 101 [88550 => 1.771ms]
      largura_110   : integer :=   99300;  -- largura do pulso p/ 110 [99300 => 1.986ms]
      largura_111   : integer :=  110000   -- largura do pulso p/ 111 [110000 => 2.2ms]
    );
    port
    (
      clock   : in  std_logic;
      reset   : in  std_logic;
      largura : in  std_logic_vector(2 downto 0);  
      pwm     : out std_logic 
    );
  end component circuito_pwm;
  component hcsr04_interface is
    port
    (
      clock            : in  std_logic;
      reset            : in  std_logic;
      reset_counters   : in  std_logic;
      generate_pulse   : in  std_logic;
      echo             : in  std_logic;
      pulse_sent       : out std_logic;
      trigger          : out std_logic;
      digito0          : out std_logic_vector(3 downto 0); -- 3 digitos BCD
      digito1          : out std_logic_vector(3 downto 0);
      digito2          : out std_logic_vector(3 downto 0)
    );
  end component hcsr04_interface;
  signal s_digito0, s_digito1, s_digito2 : std_logic_vector(3 downto 0);
  signal s_angle1, s_angle2    : std_logic_vector(3 downto 0);

  component measurement_sender is
    port
    (
      clock               : in  std_logic;
      reset               : in  std_logic;
      reset_counter       : in  std_logic;
      digito0             : in  std_logic_vector(3 downto 0);
      digito2             : in  std_logic_vector(3 downto 0);
      digito1             : in  std_logic_vector(3 downto 0);
      end_char            : in  std_logic_vector(6 downto 0);
      store_measurement   : in  std_logic;
      send_measurement    : in  std_logic;
      saida_serial        : out std_logic;
      measurement_sent    : out std_logic
    );
  end component measurement_sender;

  component register_d is 
    generic
    (
      WIDTH : natural := 8
    );
    port
    ( 
      clock    : in  std_logic;
      reset    : in  std_logic;
      enable   : in  std_logic;
      data_in  : in  std_logic_vector(WIDTH-1 downto 0);
      data_out : out std_logic_vector(WIDTH-1 downto 0)
    );
  end component;
  signal s_data_in, s_data_out : std_logic_vector(11 downto 0);

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
  
  component rx_serial_7O1 is
	port (
    clock : in std_logic;
    reset : in std_logic;
    dado_serial : in std_logic;
	 dado_recebido  : out std_logic_vector(6 downto 0);
    dado_recebido0 : out std_logic_vector(6 downto 0);
    dado_recebido1 : out std_logic_vector(6 downto 0);
    paridade_recebida : out std_logic;
    pronto_rx : out std_logic;
    db_estado : out std_logic_vector(6 downto 0)
	);
	end component;

  signal s_tick : std_logic;
  signal s_send_measurement : std_logic;
  signal s_send_angle : std_logic;
  signal s_send_distance : std_logic;
  signal s_pwm : std_logic;
  signal s_saida_serial_angle : std_logic;
  signal s_saida_serial_distance : std_logic;
  signal s_largura : std_logic_vector(2 downto 0);
  signal s_hex0 : std_logic_vector(3 downto 0);
  signal s_hex1 : std_logic_vector(3 downto 0);
  signal s_hex2 : std_logic_vector(3 downto 0);
  signal s_dado_recebido : std_logic_vector(6 downto 0);

begin

  width_counter: contadorg_updown_m
  generic map
  (
    M => 8
  )
  port map
  (
    clock   => clock,
    zera_as => '0',
    zera_s  => '0',
    conta   => update_angle,
    Q       => s_largura,
    inicio  => open,
    fim     => open,
    meio    => open
  );

  pwm_generator: circuito_pwm
  port map
  (
    clock => clock,
    reset => reset,
    largura => s_largura,
    pwm => s_pwm
  );
  pwm <= s_pwm and ligar;

  -- gerador de tick
  -- fator de divisao para 9600 bauds (5208=50M/9600)
  -- fator de divisao para 115.200 bauds (434=50M/115200)
  s_send_measurement <= send_angle or send_distance;
  U3_TICK: contador_m 
  generic map
  (
    M => 434, -- 115200 bauds
    N => 13
  )
  port map
  (
    clock => clock,
    zera  => reset,
    conta => s_send_measurement,
    Q     => open,
    fim   => s_tick,
    meio  => open
  );

  sensor_interface: hcsr04_interface
  port map
  (
    clock            => clock,
    reset            => reset,
    reset_counters   => reset_counters,
    generate_pulse   => generate_pulse,
    echo             => echo,
    pulse_sent       => pulse_sent,
    trigger          => trigger,
    digito0          => s_digito0,
    digito1          => s_digito1,
    digito2          => s_digito2
  );

  s_send_angle <= s_tick and send_angle;
  angle_sender: measurement_sender
  port map
  (
    clock               => clock,
    reset               => reset,
    reset_counter       => reset_counters,
    digito0             => "0000",
    digito1             => s_angle1,
    digito2             => s_angle2,
    end_char            => "0101100", -- ,
    store_measurement   => store_measurement,
    send_measurement    => s_send_angle,
    saida_serial        => s_saida_serial_angle,
    measurement_sent    => angle_sent
  );

  s_send_distance <= s_tick and send_distance;
  distance_sender: measurement_sender
  port map
  (
    clock               => clock,
    reset               => reset,
    reset_counter       => reset_counters,
    digito0             => s_digito0,
    digito1             => s_digito1,
    digito2             => s_digito2,
    end_char            => "0100011", -- #
    store_measurement   => store_measurement,
    send_measurement    => s_send_distance,
    saida_serial        => s_saida_serial_distance,
    measurement_sent    => distance_sent
  );

  s_data_in <= s_digito2 & s_digito1 & s_digito0;
  data_register: register_d
  generic map
  (
    WIDTH => 12
  )
  port map
  (
    clock    => clock,
    reset    => reset,
    enable   => store_measurement,
    data_in  => s_data_in,
    data_out => s_data_out
  );
  
  rx: rx_serial_7O1
  port map
  (
		clock => clock,
		reset => reset,
		dado_serial => entrada_serial,
	   dado_recebido  => s_dado_recebido,
      dado_recebido0 => open,
      dado_recebido1 => open,
      paridade_recebida => open,
      pronto_rx => pronto_rx,
      db_estado => open
  );
  
  goto_alert <= '1' when s_dado_recebido="0011011" else
					 '0';

  goto_sweep <= '1' when s_dado_recebido="1111111" else
					 '0';

  with db_sw select
    s_hex0 <= s_data_out(3 downto 0) when '0',
              "0000" when others;
  H0: hexa7seg
  port map
  (
    hexa => s_hex0,
    sseg => medida0
  );

  with db_sw select
    s_hex1 <= s_data_out(7 downto 4) when '0',
              s_angle1 when others;
  H1: hexa7seg
  port map
  (
    hexa => s_hex1,
    sseg => medida1
  );

  with db_sw select
    s_hex2 <= s_data_out(11 downto 8) when '0',
              s_angle2 when others;
  H2: hexa7seg
  port map
  (
    hexa => s_hex2,
    sseg => medida2
  );

  with send_angle select
    saida_serial <= s_saida_serial_angle when '1',
                    s_saida_serial_distance when others;

  with s_largura select
    s_angle1 <= "0010" when "000",
                "0100" when "001",
                "0110" when "010",
                "1000" when "011",
                "0000" when "100",
                "0010" when "101",
                "0100" when "110",
                "0110" when others;

  with s_largura(2) select
    s_angle2 <= "0001" when '1',
                "0000" when others;

end architecture rtl;
