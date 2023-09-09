library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rx_serial_7O1 is
 port (
    clock : in std_logic;
    reset : in std_logic;
    dado_serial : in std_logic;
    dado_recebido0 : out std_logic_vector(6 downto 0);
    dado_recebido1 : out std_logic_vector(6 downto 0);
    paridade_recebida : out std_logic;
    pronto_rx : out std_logic;
    db_estado : out std_logic_vector(6 downto 0)
);
end entity;

architecture estrutural of rx_serial_7O1 is

  component rx_serial_7O1_uc is 
    port ( 
        clock     : in  std_logic;
        reset     : in  std_logic;
        start_bit : in  std_logic;
        stop_bit  : in  std_logic;
        tick      : in  std_logic;
        fim       : in  std_logic;
        zera      : out std_logic;
        conta     : out std_logic;
        desloca   : out std_logic;
        pronto    : out std_logic;
        db_estado : out std_logic_vector(3 downto 0)
    );
  end component;

  component rx_serial_7O1_fd is
    port (
        reset          : in  std_logic;
        clock          : in  std_logic;
        zera           : in  std_logic;
        conta          : in  std_logic;
        desloca        : in  std_logic;
        entrada_serial : in  std_logic;
        dados_ascii    : out std_logic_vector(6 downto 0);
        paridade       : out std_logic;
        start_bit      : out std_logic;
        stop_bit       : out std_logic;
        fim            : out std_logic
    );
  end component;

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
  
  component edge_detector 
    port (  
        clock     : in  std_logic;
        signal_in : in  std_logic;
        output    : out std_logic
    );
  end component;

  component hexa7seg
    port (
        hexa : in  std_logic_vector(3 downto 0);
        sseg : out std_logic_vector(6 downto 0)
    );
  end component;  

  signal s_start_bit, s_n_start_bit, s_start_bit_ed, s_n_start_bit_ed, s_stop_bit : std_logic;
  signal s_tick : std_logic;
  signal s_fim : std_logic;
  signal s_zera : std_logic;
  signal s_conta : std_logic;
  signal s_desloca : std_logic;
  signal s_db_estado : std_logic_vector(3 downto 0);

  signal s_dados_ascii : std_logic_vector(6 downto 0);
  signal s_hex1 : std_logic_vector(3 downto 0);

begin
    -- gerador de tick
    -- fator de divisao para 9600 bauds (5208=50M/9600)
    -- fator de divisao para 115.200 bauds (434=50M/115200)
  RX_TICK: contador_m 
     generic map (
       M => 434, -- 115200 bauds
       N => 13
     ) 
     port map (
       clock => clock, 
       zera  => s_zera, 
       conta => '1', 
       Q     => open, 
       fim   => open, 
       meio  => s_tick
     );
 

  -- unidade de controle
  RX_UC: rx_serial_7O1_uc 
    port map (
      clock     => clock, 
      reset     => reset, 
      start_bit => s_start_bit_ed, 
      stop_bit  => s_stop_bit, 
      tick      => s_tick, 
      fim       => s_fim,
      zera      => s_zera, 
      conta     => s_conta, 
      desloca   => s_desloca, 
      pronto    => pronto_rx,
      db_estado => s_db_estado
    );

  -- fluxo de dados
  RX_DF: rx_serial_7O1_fd
    port map (
      reset            => reset, 
      clock            => clock, 
      zera             => s_zera, 
      conta            => s_conta, 
      desloca          => s_desloca, 
      entrada_serial   => dado_serial, 
      dados_ascii      => s_dados_ascii, 
      paridade         => paridade_recebida, 
      start_bit        => s_start_bit, 
      stop_bit         => s_stop_bit, 
      fim              => s_fim
    );

  s_n_start_bit <= not s_start_bit;
  s_start_bit_ed <= not s_n_start_bit_ed;
  RX_ED: edge_detector 
    port map (
      clock     => clock,
      signal_in => s_n_start_bit,
      output    => s_n_start_bit_ed
    );

  HEX0: hexa7seg
    port map (
        hexa => s_dados_ascii(3 downto 0),
        sseg => dado_recebido0
    );

  s_hex1 <= "0" & s_dados_ascii(6 downto 4);
  HEX1: hexa7seg
    port map (
        hexa => s_hex1,
        sseg => dado_recebido1
    );

  HEX2: hexa7seg
    port map (
        hexa => s_db_estado,
        sseg => db_estado
    );

end architecture;
