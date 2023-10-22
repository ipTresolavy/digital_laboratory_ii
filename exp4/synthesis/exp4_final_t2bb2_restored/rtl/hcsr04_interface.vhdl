library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hcsr04_interface is
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
end entity hcsr04_interface;

architecture rtl of hcsr04_interface is
  component gerador_pulso is
    generic (
        largura: integer:= 25
      );
    port (
      clock  : in  std_logic;
      reset  : in  std_logic;
      gera   : in  std_logic;
      para   : in  std_logic;
      pulso  : out std_logic;
      pronto : out std_logic
    );
  end component gerador_pulso;

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
  signal s_half : std_logic;
    
  component contador_bcd_3digitos is 
    port ( 
      clock   : in  std_logic;
      zera    : in  std_logic;
      conta   : in  std_logic;
      digito0 : out std_logic_vector(3 downto 0);
      digito1 : out std_logic_vector(3 downto 0);
      digito2 : out std_logic_vector(3 downto 0);
      fim     : out std_logic
    );
  end component;

  signal s_zera : std_logic;

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
    digito0 => digito0,
    digito1 => digito1,
    digito2 => digito2,
    fim     => open
  );
  
end architecture rtl;

