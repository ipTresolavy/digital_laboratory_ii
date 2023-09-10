library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity serial_7O1 is
  port (
    clock             : in  std_logic;
    reset             : in  std_logic;
    partida           : in  std_logic;
    dados_ascii       : in  std_logic_vector(6 downto 0);
    dado_serial       : in  std_logic;
    saida_serial      : out std_logic;
    dado_recebido0    : out std_logic_vector(6 downto 0);
    dado_recebido1    : out std_logic_vector(6 downto 0);
    paridade_recebida : out std_logic;
    pronto_tx         : out std_logic;
    pronto_rx         : out std_logic;
  -- debug
    db_clock          : out std_logic;
    db_tick           : out std_logic;
    db_partida        : out std_logic;
    db_saida_serial   : out std_logic;
    db_estado_tx      : out std_logic_vector(6 downto 0);
    db_estado_rx      : out std_logic_vector(6 downto 0)
  );
end entity;

architecture serial_7O1_arch of serial_7O1 is

  component rx_serial_7O1 is
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
  end component;

  component tx_serial_7O1 is
    port (
      clock           : in  std_logic;
      reset           : in  std_logic;
      partida         : in  std_logic;
      dados_ascii     : in  std_logic_vector(6 downto 0);
      saida_serial    : out std_logic;
      pronto          : out std_logic;
      db_clock        : out std_logic;
      db_tick         : out std_logic;
      db_partida      : out std_logic;
      db_saida_serial : out std_logic;
      db_estado       : out std_logic_vector(6 downto 0)
    );
  end component;

begin

  tx: tx_serial_7O1
    port map
    ( 
      clock           => clock,
      reset           => reset,
      partida         => partida,
      dados_ascii     => dados_ascii,
      saida_serial    => saida_serial,
      pronto          => pronto_tx,
      db_clock        => db_clock,
      db_tick         => db_tick,
      db_partida      => db_partida,
      db_saida_serial => db_saida_serial,
      db_estado       => db_estado_tx
    );

  rx: rx_serial_7O1
    port map (  
      clock             => clock, 
      reset             => reset,
      dado_serial       => dado_serial,
      paridade_recebida => paridade_recebida,
      pronto_rx         => pronto_rx,
      dado_recebido0    => dado_recebido0,
      dado_recebido1    => dado_recebido1,
      db_estado         => db_estado_rx
    );
  
end architecture;
