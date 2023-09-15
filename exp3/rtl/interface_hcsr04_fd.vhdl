library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity interface_hcsr04_fd is
  port (
    reset            : in  std_logic;
    clock            : in  std_logic;
    reset_counter    : in  std_logic;
    generate_pulse   : in  std_logic;
    echo             : in  std_logic;
    pulse_sent       : out std_logic;
    trigger          : out std_logic;
    medida           : out std_logic_vector(11 downto 0) -- 3 digitos BCD
  );
end entity interface_hcsr04_fd;

architecture structural of interface_hcsr04_fd is

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

begin

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

  contador_bcd: contador_bcd_3digitos
  port map
  (
    clock   => clock,
    zera    => reset_counter,
    conta   => echo,
    digito0 => medida(3 downto 0),
    digito1 => medida(7 downto 4),
    digito2 => medida(11 downto 8),
    fim     => open
  );

end architecture structural;
