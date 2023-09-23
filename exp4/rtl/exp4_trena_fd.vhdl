library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exp4_trena_fd is
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
end entity exp4_trena_fd;

architecture rtl of exp4_trena_fd is
  component deslocador_n
  generic
  (
      constant N : integer
  );
  port
  (
      clock          : in  std_logic;
      reset          : in  std_logic;
      carrega        : in  std_logic; 
      desloca        : in  std_logic; 
      entrada_serial : in  std_logic; 
      dados          : in  std_logic_vector(N-1 downto 0);
      saida          : out std_logic_vector(N-1 downto 0)
  );
  end component;

  component gerador_pulso is
    generic
    (
      largura: integer:= 25
    );
    port
    (
      clock  : in  std_logic;
      reset  : in  std_logic;
      gera   : in  std_logic;
      para   : in  std_logic;
      pulso  : out std_logic;
      pronto : out std_logic
    );
  end component gerador_pulso;

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
  signal s_half : std_logic;
    
  component contador_bcd_3digitos is 
    port
    ( 
      clock   : in  std_logic;
      zera    : in  std_logic;
      conta   : in  std_logic;
      digito0 : out std_logic_vector(3 downto 0);
      digito1 : out std_logic_vector(3 downto 0);
      digito2 : out std_logic_vector(3 downto 0);
      fim     : out std_logic
    );
  end component;
  signal s_digito0, s_digito1, s_digito2 : std_logic_vector(3 downto 0);

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

  -- reset do tick_generator, bcd_counter e bit_counter
  signal s_zera : std_logic;

  signal s_dados, s_saida : std_logic_vector(46 downto 0);

begin

  s_zera <= reset or reset_counters;

  pulse_generator: gerador_pulso
  generic map
  (
    largura => 500 -- 10us * 50MHz
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

  tick_generator: contador_m 
  generic map (
    -- divisão do clock de 50MHz por 5882/2
    M => 2941, 
    N => 12
  ) 
  port map
  (
    clock => clock, 
    zera  => s_zera, 
    conta => echo, 
    Q     => open, 
    fim   => open, 
    meio  => s_half
  );

  bcd_counter: contador_bcd_3digitos
  port map
  (
    clock   => clock,
    zera    => s_zera,
    conta   => s_half,
    digito0 => s_digito0,
    digito1 => s_digito1,
    digito2 => s_digito2,
    fim     => open
  );

  s_dados(46)           <= '1';  -- stop bit 
  s_dados(45)           <= '0';  -- paridade
  s_dados(44 downto 38) <= "0100011"; -- #
  s_dados(37 downto 36) <= "01"; -- start bit e repouso

  s_dados(35)           <= '1';  -- separador (opcional)
  s_dados(34)           <= '1';  -- stop bit 
  -- VHDL2008: s_dados(33)           <= not (xor s_digito2);
  s_dados(33)           <= not (s_digito0(3) xor s_digito0(2) xor s_digito0(1) xor s_digito0(0));
  s_dados(32 downto 26) <= "011" & s_digito0;
  s_dados(25 downto 24) <= "01"; -- start bit e repouso

  s_dados(23)           <= '1';  -- separador (opcional)
  s_dados(22)           <= '1';  -- stop bit 
  -- VHDL2008: s_dados(21)           <= not (xor s_digito1);
  s_dados(21)           <= not (s_digito1(3) xor s_digito1(2) xor s_digito1(1) xor s_digito1(0));
  s_dados(20 downto 14) <= "011" & s_digito1;
  s_dados(13 downto 12) <= "01"; -- start bit e repouso

  s_dados(11)           <= '1';  -- separador (opcional)
  s_dados(10)           <= '1';  -- stop bit 
  -- VHDL2008: s_dados(9)           <= not (xor s_digito0);
  s_dados(9)            <= not (s_digito2(3) xor s_digito2(2) xor s_digito2(1) xor s_digito2(0));
  s_dados(8 downto 2)   <= "011" & s_digito2;
  s_dados(1 downto 0)   <= "01"; -- start bit e repouso

  shifter: deslocador_n
  generic map
  (
    N => 47
  )
  port map
  (
    clock          => clock,
    reset          => reset,
    carrega        => store_measurement,
    desloca        => send_measurement,
    entrada_serial => '1',
    dados          => s_dados,
    saida          => s_saida
  );
  saida_serial <= s_saida(0);

  bit_counter: contador_m
  generic map
  (
    M => 48,
    N => 6
  )
  port map
  (
    clock => clock,
    zera  => s_zera,
    conta => send_measurement,
    Q     => open,
    fim   => measurement_sent,
    meio  => open
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

  H0: hexa7seg
  port map
  (
    hexa => s_data_out(3 downto 0),
    sseg => medida0
  );

  H1: hexa7seg
  port map
  (
    hexa => s_data_out(7 downto 4),
    sseg => medida1
  );

  H2: hexa7seg
  port map
  (
    hexa => s_data_out(11 downto 8),
    sseg => medida2
  );

end architecture rtl;
