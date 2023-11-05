library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity hcsr04_interface is
  port
  (
    clock            : in  std_logic;
    reset            : in  std_logic;

    reset_counters    : in  std_logic;
    generate_pulse    : in  std_logic;
    echo              : in  std_logic;
    store_measurement : in  std_logic;
    watchdog_en       : in  std_logic;
    reset_watchdog    : in  std_logic;

    mensurar         : out std_logic;
    pulse_sent       : out std_logic;
    trigger          : out std_logic;
    timeout          : out std_logic;
    dist_l           : out std_logic_vector(7 downto 0);
    dist_h           : out std_logic_vector(7 downto 0)
  );
end entity hcsr04_interface;

architecture rtl of hcsr04_interface is
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

  component sync_par_counter is
    generic
    (
      constant MODU : natural := 16
    );
    port
    (
      clock  : in  std_logic;
      reset  : in  std_logic;
      cnt_en : in  std_logic;
      q_in   : in  std_logic_vector(natural(ceil(log2(real(MODU))))-1 downto 0);
      load   : in  std_logic;
      q      : out std_logic_vector(natural(ceil(log2(real(MODU))))-1 downto 0)
    );
  end component sync_par_counter;

  component register_d is
    generic
    (
      WIDTH : natural := 8
    );
    port
    (
      clock         : in  std_logic;
      reset         : in  std_logic;
      enable        : in  std_logic;
      data_in       : in  std_logic_vector(WIDTH-1 downto 0);
      data_out      : out std_logic_vector(WIDTH-1 downto 0)
    );
  end component register_d;

  signal s_half : std_logic;
  signal q_mensurar : std_logic_vector(natural(ceil(log2(real(2500000))))-1 downto 0);
  signal q : std_logic_vector(natural(ceil(log2(real(2941))))-1 downto 0);
  signal q_dist : std_logic_vector(15 downto 0);

  signal s_zera : std_logic;

  signal s_watchdog_clear : std_logic;
  signal q_watchdog : std_logic_vector(natural(ceil(log2(real(5000000))))-1 downto 0);

  signal dist_h_l : std_logic_vector(15 downto 0);

  constant q_watchdog_max : std_logic_vector(q_watchdog'LENGTH-1 downto 0) := std_logic_vector(to_unsigned(5018478-1, q_watchdog'LENGTH));
  constant q_max : std_logic_vector(q'LENGTH-1 downto 0) := std_logic_vector(to_unsigned(2941/2, q'LENGTH));
  constant q_mensurar_max : std_logic_vector(q_mensurar'LENGTH-1 downto 0) := std_logic_vector(to_unsigned(2500000-1, q_mensurar'LENGTH));

begin

  mensurar_counter: sync_par_counter
  generic map
  (
    -- gera um comando de medição a cada 50ms 
    MODU => 2500000
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

  tick_generator: sync_par_counter
  generic map
  (
    -- divisão do clock de 50MHz por 5882/2
    MODU => 2941
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
    -- 16 bits na saída
    MODU => 2**16
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

  s_watchdog_clear <= reset or reset_watchdog;
  watchdog: sync_par_counter
  generic map
  (
    -- gera timeout de medição a cada 40ms 
    MODU => 5018478
  )
  port map
  (
    clock => clock,
    reset => s_watchdog_clear,
    cnt_en => watchdog_en,
    q_in => (others => '0'),
    load => '0',
    q => q_watchdog
  );
  timeout <= '1' when q_watchdog = q_watchdog_max else
             '0';
  
end architecture rtl;

