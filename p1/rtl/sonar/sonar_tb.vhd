--------------------------------------------------------------------
-- Arquivo   : sonar_tb.vhd
-- Projeto   : Experiencia 5 - Sistema de Sonar
--------------------------------------------------------------------
-- Descricao : testbench BÁSICO para circuito do sistema de sonar
--
--             1) array de casos de teste contém valores de  
--                largura de pulso de echo do sensor
-- 
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     19/09/2021  1.0     Edson Midorikawa  versao inicial
--     24/09/2022  1.1     Edson Midorikawa  revisao
--     30/09/2022  1.1.1   Edson Midorikawa  revisao
--     24/09/2022  1.1.2   Edson Midorikawa  revisao
--------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;

entity sonar_tb is
end entity;

architecture tb of sonar_tb is
  
  -- Componente a ser testado (Device Under Test -- DUT)
  component sonar
    port (
        clock              : in  std_logic;
        reset              : in  std_logic;
        ligar              : in  std_logic;
        echo               : in  std_logic;
        trigger            : out std_logic;
        pwm                : out std_logic;
        saida_serial       : out std_logic;
        fim_posicao        : out std_logic;
        medida0            : out std_logic_vector (6 downto 0);
        medida1            : out std_logic_vector (6 downto 0);
        medida2            : out std_logic_vector (6 downto 0);
        db_sw              : in  std_logic;
	      entrada_serial     : in  std_logic;
        db_estado          : out std_logic_vector (6 downto 0);
        db_trigger         : out std_logic;
        db_echo            : out std_logic;
        db_ligar           : out std_logic;
        db_saida_serial    : out std_logic;
       db_modo 		         : out std_logic;
       db_pwm              : out std_logic
    );
  end component;
  
  -- Declaração de sinais para conectar o componente a ser testado (DUT)
  --   valores iniciais para fins de simulacao (GHDL ou ModelSim)
  signal clock_in          : std_logic := '0';
  signal reset_in          : std_logic := '0';
  signal ligar_in          : std_logic := '0';
  signal echo_in           : std_logic := '0';
  signal entrada_serial_in : std_logic := '1';
  signal trigger_out       : std_logic := '0';
  signal pwm_out           : std_logic := '0';
  signal saida_serial_out  : std_logic := '1';
  signal fim_posicao_out   : std_logic := '0';
  signal db_estado_out     : std_logic_vector (6 downto 0) := "0000000";
  --signal contagem_de_bits  : integer range 0 to 11;
  constant a : std_logic_vector(9 downto 0) := "1011000010";
  constant s : std_logic_vector(9 downto 0) := "1110100110";
  constant m : std_logic_vector(9 downto 0) := "1110100000";
  constant plus : std_logic_vector(9 downto 0) := "1101010110";


  -- Configurações do clock
  constant clockPeriod   : time      := 20 ns; -- clock de 50MHz
  signal keep_simulating : std_logic := '0';   -- delimita o tempo de geração do clock
  
  -- Array de posicoes de teste
  type posicoes_teste_type is record
      id    : natural; 
      tempo : integer;     
  end record;

  -- fornecida tabela com 2 posicoes (comentadas 6 posicoes)
  type posicoes_teste_array is array (natural range <>) of posicoes_teste_type;
  constant posicoes_teste : posicoes_teste_array :=
      ( 
        ( 1,  294),   --   5cm ( 294us)
        ( 2,  353),    --   6cm ( 353us)
        -- ( 2,  353),  --   6cm ( 353us)
        ( 3, 5882),  -- 100cm (5882us)
        ( 4, 5882),  -- 100cm (5882us)
        ( 5,  882),  --  15cm ( 882us)
        ( 6,  882)  --  15cm ( 882us)
        -- ( 7, 5882),  -- 100cm (5882us)
        -- ( 8,  588),   --  10cm ( 588us)
        -- inserir aqui outros posicoes de teste (inserir "," na linha anterior)
        -- ( 9,  1088), -- cm 
        -- ( 10, 5000), -- cm 
        -- ( 11, 2500)  --  m 
      );

  signal larguraPulso: time := 1 ns;

begin
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período
  -- especificado. Quando keep_simulating=0, clock é interrompido, bem como a 
  -- simulação de eventos
  clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;
  
  -- Conecta DUT (Device Under Test)
  dut: sonar
       port map( 
           clock           => clock_in,
           reset           => reset_in,
           ligar           => ligar_in,
           echo            => echo_in,
           trigger         => trigger_out,
           pwm             => pwm_out,
           saida_serial    => saida_serial_out,
           fim_posicao     => fim_posicao_out,
           medida0         => open,
           medida1         => open,
           medida2         => open,
           db_sw           => '0',
           entrada_serial  => entrada_serial_in,
           db_estado       => db_estado_out,
           db_trigger      => open,
           db_echo         => open,
           db_ligar        => open,
           db_saida_serial => open,
           db_modo         => open,
           db_pwm          => open
       );

  -- geracao dos sinais de entrada (estimulos)
  stimulus: process is
    variable j : integer := 0;
  begin
  
    assert false report "Inicio das simulacoes" severity note;
    keep_simulating <= '1';
    
    ---- valores iniciais ----------------
    ligar_in <= '0';
    echo_in  <= '0';

    ---- inicio: reset ----------------
    -- wait for 2*clockPeriod;
    reset_in <= '1'; 
    wait for 2 us;
    reset_in <= '0';
    wait until falling_edge(clock_in);

    ---- ligar sonar ----------------
    wait for 20 us;
    ligar_in <= '1';

    ---- espera de 20us
    wait for 20 us;

    ---- loop pelas posicoes de teste
    for i in posicoes_teste'range loop
        -- 1) Muda modo de operação
        j := 0;
        if i rem 3 = 0 then 
          while j < 10 loop
            entrada_serial_in <= a(j);
            j := j + 1;
            wait for 8680 ns;
          end loop;
        elsif i rem 3 = 1 then
          while j < 10 loop
            entrada_serial_in <= s(j);
            j := j + 1;
            wait for 8680 ns;
          end loop;
        else 
          while j < 10 loop
            entrada_serial_in <= m(j);
            j := j + 1;
            wait for 8680 ns;
          end loop;
          j := 0;
          while j < 10 loop
            entrada_serial_in <= '1';
            j := j + 1;
            wait for 200 ns;
          end loop;
          j := 0;
          while j < 10 loop
            entrada_serial_in <= plus(j);
            j := j + 1;
            wait for 8680 ns;
          end loop;
        end if;

        -- 2) determina largura do pulso echo para a posicao i
        assert false report "Posicao " & integer'image(posicoes_teste(i).id) & ": " &
            integer'image(posicoes_teste(i).tempo) & "us" severity note;
        larguraPulso <= posicoes_teste(i).tempo * 1 us; -- posicao de teste "i"

        -- 3) espera pelo pulso trigger
        wait until falling_edge(trigger_out);
     
        -- 4) espera por 400us (simula tempo entre trigger e echo)
        wait for 400 us;
     
        -- 5) gera pulso de echo (largura = larguraPulso)
        echo_in <= '1';
        wait for larguraPulso;
        echo_in <= '0';

        -- 6) espera sinal fim (indica final da medida de uma posicao do sonar)
        wait until fim_posicao_out = '1';     
    end loop;

    wait for 400 us;

    ---- final dos casos de teste da simulacao
    assert false report "Fim das simulacoes" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: aguarda indefinidamente (não retirar esta linha)
  end process;

end architecture;
