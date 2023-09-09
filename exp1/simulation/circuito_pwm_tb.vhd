-- circuito_pwm_tb
--------------------------------------------------------------------------
-- Descricao : 
--             testbench do componentge circuito_pwm
--
--------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     26/09/2021  1.0     Edson Midorikawa  criacao
--     24/08/2022  1.1     Edson Midorikawa  revisao
--     08/05/2023  1.2     Edson Midorikawa  revisao do componente
--     17/08/2023  1.3     Edson Midorikawa  revisao do componente
-------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;

entity circuito_pwm_tb is
end entity;

architecture tb of circuito_pwm_tb is
  
  -- Componente a ser testado (Device Under Test -- DUT)
  component circuito_pwm is
  generic (
      conf_periodo : integer;
      largura_00   : integer;
      largura_01   : integer;
      largura_10   : integer;
      largura_11   : integer
  );
    port (
      clock   : in  std_logic;
      reset   : in  std_logic;
      largura : in  std_logic_vector(1 downto 0);  
      pwm     : out std_logic 
    );
  end component;
  
  -- Declaração de sinais para conectar o componente a ser testado (DUT)
  --   valores iniciais para fins de simulacao (GHDL ou ModelSim)
  signal clock_in   : std_logic := '0';
  signal reset_in   : std_logic := '0';
  signal largura_in : std_logic_vector (1 downto 0) := "00";
  signal pwm_out    : std_logic := '0';


  -- Configurações do clock
  signal keep_simulating : std_logic := '0'; -- delimita o tempo de geração do clock
  constant clockPeriod   : time := 20 ns;    -- f=50MHz
  
begin
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período
  -- especificado. Quando keep_simulating=0, clock é interrompido, bem como a 
  -- simulação de eventos
  clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;

 
  -- Conecta DUT (Device Under Test)
  dut: circuito_pwm 
       generic map (
           conf_periodo => 1250, -- valores default
           largura_00   => 0,
           largura_01   => 50,
           largura_10   => 500,
           largura_11   => 1000
       )
       port map( 
           clock   => clock_in,
           reset   => reset_in,
           largura => largura_in,
           pwm     => pwm_out
       );

  -- geracao dos sinais de entrada (estimulos)
  stimulus: process is
  begin
  
    assert false report "Inicio da simulacao" & LF & "... Simulacao ate 800 us. Aguarde o final da simulacao..." severity note;
    keep_simulating <= '1';
    
    ---- inicio: reset ----------------
    reset_in <= '1'; 
    wait for 2*clockPeriod;
    reset_in <= '0';
    wait for 2*clockPeriod;

    ---- casos de teste
    -- posicao=00
    largura_in <= "00"; -- sem pulso
    wait for 200 us;

    -- posicao=01
    largura_in <= "01"; -- largura de pulso de 1ms
    wait for 200 us;

    -- posicao=10
    largura_in <= "10"; -- largura de pulso de 1,5ms
    wait for 200 us;

    -- posicao=11
    largura_in <= "11"; -- largura de pulso de 2ms
    wait for 200 us;

    ---- final dos casos de teste  da simulacao
    assert false report "Fim da simulacao" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: aguarda indefinidamente
  end process;

end architecture;
