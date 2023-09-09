-----------------Laboratorio Digital--------------------------------------
-- Arquivo   : circuito_pwm.vhd
-- Projeto   : Experiencia 1 - Controle de um servomotor
--------------------------------------------------------------------------
-- Descricao : 
--             codigo VHDL RTL gera saída digital com modulacao pwm
--
-- parametros de configuracao da saida pwm: conf_periodo e largura_xx
-- (considerando clock de 50MHz ou periodo de 20ns)
--
-- valores default:
-- conf_periodo=1250 gera um sinal periodo de 4 KHz (25us) com clock 50MHz
-- largura_xx controla o tempo de pulso em 1 para diferentes larguras:
-- 00=0 (saida nula), 01=pulso de 1us, 10=pulso de 10us, 11=pulso de 20us
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
use ieee.numeric_std.all;

entity circuito_pwm is
  generic (
      conf_periodo  : integer := 1000000;  -- periodo do sinal pwm [1000000 => f=50Hz (20ms)]
      largura_000   : integer :=   50000;  -- largura do pulso p/ 000 [50000 => 1ms]
      largura_001   : integer :=   57143;  -- largura do pulso p/ 001 [57143 => 1.14ms]
      largura_010   : integer :=   64286;  -- largura do pulso p/ 010 [64286 => 1.29ms]
      largura_011   : integer :=   71429;  -- largura do pulso p/ 011 [71429 => 1.43ms]
      largura_100   : integer :=   78571;  -- largura do pulso p/ 100 [78571 => 1.57ms]
      largura_101   : integer :=   85714;  -- largura do pulso p/ 101 [85714 => 1.71ms]
      largura_110   : integer :=   92857;  -- largura do pulso p/ 110 [92857 => 1.86ms]
      largura_111   : integer :=  100000   -- largura do pulso p/ 111 [100000 => 2ms]
  );
  port (
      clock   : in  std_logic;
      reset   : in  std_logic;
      largura : in  std_logic_vector(2 downto 0);  
      pwm     : out std_logic 
  );
end entity circuito_pwm;

architecture rtl of circuito_pwm is

  signal contagem     : integer range 0 to conf_periodo-1;
  signal largura_pwm  : integer range 0 to conf_periodo-1;
  signal s_largura    : integer range 0 to conf_periodo-1;
  
begin

  process(clock, reset, s_largura)
  begin
    -- inicia contagem e largura
    if(reset='1') then
      contagem    <= 0;
      pwm         <= '0';
      largura_pwm <= s_largura;
    elsif(rising_edge(clock)) then
        -- saida
        if(contagem < largura_pwm) then
          pwm  <= '1';
        else
          pwm  <= '0';
        end if;
        -- atualiza contagem e largura
        if(contagem = conf_periodo-1) then
          contagem    <= 0;
          largura_pwm <= s_largura;
        else
          contagem    <= contagem + 1;
        end if;
    end if;
  end process;

  -- define largura do pulso em ciclos de clock
  with largura select 
    s_largura <= largura_000 when "000",
                 largura_001 when "001",
                 largura_010 when "010",
                 largura_011 when "011",
                 largura_100 when "100",
                 largura_101 when "101",
                 largura_110 when "110",
                 largura_111 when "111",
                 largura_000 when others;

end architecture rtl;
