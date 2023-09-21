library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity desafio is
  port (
    clock      : in  std_logic;
    reset      : in  std_logic;
    echo       : in  std_logic;
    trigger    : out std_logic;
    hex0       : out std_logic_vector(6 downto 0); -- digitos da medida
    hex1       : out std_logic_vector(6 downto 0);
    hex2       : out std_logic_vector(6 downto 0);
    pronto     : out std_logic;
    db_echo    : out std_logic;
    db_trigger : out std_logic;
    db_estado  : out std_logic_vector(6 downto 0) -- estado da UC
  );
end entity desafio;

architecture structural of desafio is

  component interface_hcsr04 is
    port (
      clock     : in  std_logic;
      reset     : in  std_logic;
      medir     : in  std_logic;
      echo      : in  std_logic;
      trigger   : out std_logic;
      medida    : out std_logic_vector(11 downto 0); -- 3 digitos BCD
      pronto    : out std_logic;
      db_estado : out std_logic_vector(3 downto 0) -- estado da UC
    );
  end component interface_hcsr04;

  component hexa7seg is
      port (
        hexa : in  std_logic_vector(3 downto 0);
        sseg : out std_logic_vector(6 downto 0)
      );
  end component hexa7seg;

  component contador_m
    generic (
      constant M : integer;
      constant N : integer
    );
    port (
      clock : in  std_logic;
      zera  : in  std_logic;
      conta : in  std_logic;
      Q     : out std_logic_vector(N-1 downto 0);
      fim   : out std_logic;
      meio  : out std_logic
    );
  end component;

  signal s_medida    : std_logic_vector(11 downto 0);
  signal s_db_estado : std_logic_vector(3 downto 0);
  signal s_medir     : std_logic;
  signal s_trigger   : std_logic;
  signal s_pronto    : std_logic;
  signal s_zera      : std_logic;

begin

  s_zera <= reset or s_pronto;
  continuous_measurement: contador_m 
  generic map (
    -- gera um comando de medição a cada 50ms 
    M => 2500000, 
    N => 27
  ) 
  port map
  (
    clock => clock, 
    zera  => s_zera, 
    conta => '1', 
    Q     => open, 
    fim   => s_medir, 
    meio  => open
  );

  INT: interface_hcsr04
  port map
  (
    clock     => clock,
    reset     => reset,
    echo      => echo,
    medir     => s_medir,
    trigger   => s_trigger,
    pronto    => s_pronto,
    medida    => s_medida,
    db_estado => s_db_estado
  );
  
  H0: hexa7seg
  port map
  (
    hexa => s_medida(3 downto 0),
    sseg => hex0
  );

  H1: hexa7seg
  port map
  (
    hexa => s_medida(7 downto 4),
    sseg => hex1
  );

  H2: hexa7seg
  port map
  (
    hexa => s_medida(11 downto 8),
    sseg => hex2
  );

  H5: hexa7seg
  port map
  (
    hexa => s_db_estado,
    sseg => db_estado
  );

  trigger    <= s_trigger;
  db_trigger <= s_trigger;
  db_echo    <= echo;
  pronto     <= s_pronto;

end architecture structural;
