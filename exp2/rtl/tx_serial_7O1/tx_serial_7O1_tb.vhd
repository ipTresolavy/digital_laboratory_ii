------------------------------------------------------------------------------
-- Arquivo   : tx_serial_7O1_tb.vhd
-- Projeto   : Experiencia 2 - Comunicacao Serial Assincrona
------------------------------------------------------------------------------
-- Descricao : circuito da experiencia 2 
-- > modelo de testbench para simulacao do circuito
-- > de transmissao serial assincrona
-- > 
-- > simula a entidade fornecida tx_serial_7O1
-- > usa um vetor de teste para especificar casos de teste
------------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2021  1.0     Edson Midorikawa  versao inicial
--     31/08/2022  2.0     Edson Midorikawa  revisao
--     17/08/2023  3.0     Edson Midorikawa  revisao para 7O1 e vetor de teste
------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tx_serial_7O1_tb is
end entity;

architecture tb of tx_serial_7O1_tb is
  
  -- Componente a ser testado (Device Under Test -- DUT)
  component tx_serial_7O1
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
  
  -- Declaração de sinais para conectar o componente a ser testado (DUT)
  --   valores iniciais para fins de simulacao (ModelSim)
  signal clock_in         : std_logic := '0';
  signal reset_in         : std_logic := '0';
  signal partida_in       : std_logic := '0';
  signal dados_ascii_7_in : std_logic_vector (6 downto 0) := "0000000";
  -- signal dados_ascii_8_in : std_logic_vector (7 downto 0) := "00000000";
  signal saida_serial_out : std_logic := '1';
  signal pronto_out       : std_logic := '0';
  -- signal db_estado_out    : std_logic_vector(6 downto 0) := "0000000";

  -- Configurações do clock
  signal keep_simulating : std_logic := '0'; -- delimita o tempo de geração do clock
  constant clockPeriod   : time := 20 ns;    -- clock de 50MHz
  
  signal caso : integer := 0;

begin
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período
  -- especificado. Quando keep_simulating=0, clock é interrompido, bem como a 
  -- simulação de eventos
  clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;
  
  -- Conecta DUT (Device Under Test)
  dut: tx_serial_7O1
       port map
       ( 
           clock           => clock_in,
           reset           => reset_in,
           partida         => partida_in,
           -- dados_ascii     => dados_ascii_8_in,
           dados_ascii     => dados_ascii_7_in,
           saida_serial    => saida_serial_out,
           pronto          => pronto_out,
           db_clock        => open,
           db_tick         => open,
           db_partida      => open,
           db_saida_serial => open,
           db_estado       => open
      );

  -- geracao dos sinais de entrada (estimulos)
  stimulus: process is

  type array_std_logic_vector_7 is array (natural range <>) of std_logic_vector(6 downto 0);
  constant vetor_teste: array_std_logic_vector_7 :=
     ("0110101",   -- 35h (5)
      "1010101",   -- 55h (U)
      "1111110",   -- 7Eh (~)
      "1111111");  -- 7Fh (DEL)

  begin
  
    assert caso = 0 severity note;
    assert false report "Inicio da simulacao" severity note;
    keep_simulating <= '1';
    
    ---- inicio da simulacao: reset ----------------
    partida_in <= '0';
    -- pulso largo de reset com 20 periodos de clock
    wait until falling_edge(clock_in);
    reset_in   <= '1'; 
    wait for 20*clockPeriod;
    reset_in   <= '0';
    wait until falling_edge(clock_in);
    wait for 50*clockPeriod;

    ---- Casos de teste

    -- Para cada padrao de teste no vetor
    for i in vetor_teste'range loop

        assert false report "caso: " & integer'image(i) severity note;
        caso <= i;

        ---- dado de entrada do vetor de teste
        dados_ascii_7_in <= vetor_teste(i);
        wait for 20*clockPeriod;
    
        ---- acionamento da partida (inicio da transmissao)
        wait until falling_edge(clock_in);
        partida_in <= '1';
        wait for 25*clockPeriod; -- pulso partida com 25 periodos de clock
        partida_in <= '0';
    
        ---- espera final da transmissao (pulso pronto em 1)
        wait until pronto_out='1';
        
        ---- final do caso de teste 
    
        -- intervalo entre casos de teste
        wait for 500*clockPeriod;
    

    end loop;

    ---- final dos casos de teste da simulacao
    assert false report "Fim da simulacao" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: aguarda indefinidamente
  end process;

end architecture;
