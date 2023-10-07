library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity measurement_sender is
  port
  (
    clock               : in  std_logic;
    reset               : in  std_logic;
    reset_counter       : in  std_logic;
    digito0             : in  std_logic_vector(3 downto 0);
    digito1             : in  std_logic_vector(3 downto 0);
    digito2             : in  std_logic_vector(3 downto 0);
    end_char            : in  std_logic_vector(6 downto 0);
    store_measurement   : in  std_logic;
    send_measurement    : in  std_logic;
    saida_serial        : out std_logic;
    measurement_sent    : out std_logic
  );
end entity measurement_sender;

architecture rtl of measurement_sender is
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

  signal s_dados, s_saida : std_logic_vector(46 downto 0);
  signal s_zera : std_logic;

begin

  s_zera <= reset or reset_counter;
  
  s_dados(46)           <= '1';  -- stop bit 
  s_dados(45)           <= '0';  -- paridade
  s_dados(44 downto 38) <= end_char;
  s_dados(37 downto 36) <= "01"; -- start bit e repouso

  s_dados(35)           <= '1';  -- separador (opcional)
  s_dados(34)           <= '1';  -- stop bit 
  -- VHDL2008: s_dados(33)           <= not (xor digito2);
  s_dados(33)           <= not (digito0(3) xor digito0(2) xor digito0(1) xor digito0(0));
  s_dados(32 downto 26) <= "011" & digito0;
  s_dados(25 downto 24) <= "01"; -- start bit e repouso

  s_dados(23)           <= '1';  -- separador (opcional)
  s_dados(22)           <= '1';  -- stop bit 
  -- VHDL2008: s_dados(21)           <= not (xor digito1);
  s_dados(21)           <= not (digito1(3) xor digito1(2) xor digito1(1) xor digito1(0));
  s_dados(20 downto 14) <= "011" & digito1;
  s_dados(13 downto 12) <= "01"; -- start bit e repouso

  s_dados(11)           <= '1';  -- separador (opcional)
  s_dados(10)           <= '1';  -- stop bit 
  -- VHDL2008: s_dados(9)           <= not (xor digito0);
  s_dados(9)            <= not (digito2(3) xor digito2(2) xor digito2(1) xor digito2(0));
  s_dados(8 downto 2)   <= "011" & digito2;
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
  
end architecture rtl;
