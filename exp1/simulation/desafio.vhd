library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_arith.all;


entity desafio is
  port (
    clock     : in  std_logic;
    reset     : in  std_logic;
    posicao   : in  std_logic_vector(2 downto 0);
    controle  : out std_logic
  );
end entity desafio;


architecture rtl of desafio is
  
  component circuito_pwm is
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
  end component circuito_pwm;


  component counter is
  port (
    clk,reset: in std_logic;
    clock_out: out std_logic
  );
  end component;

  signal s_clock : std_logic := '0';
  signal contagem: integer:=1;
  signal dec : std_logic := '0';
  signal s_largura : std_logic_vector(2 downto 0) := "000";

  begin

    s_largura <= conv_std_logic_vector(contagem, s_largura'length);

  contador: counter
    port map
    (
      clk   => clock,
      reset   => reset,
      clock_out     => s_clock
    );

  process (s_clock, reset) begin
    if (reset = '1') then
      contagem <= 0;
      dec <= '0';
    elsif (rising_edge(s_clock)) then

      if (dec = '1') then
        contagem <= contagem + 1;
      else
        contagem <= contagem - 1;
      end if;

      if ((contagem = 0 and dec = '1')) then
        dec <= not dec;
        contagem <= 0;
      end if;

      if ((contagem = 7 and dec = '0')) then
        dec <= not dec;
        contagem <= 7;
      end if;

    end if;
  end process;

  
    pwm_circuit: circuito_pwm
    port map
    (
      clock   => clock,
      reset   => reset,
      largura => s_largura,
      pwm     => controle
    );

end architecture rtl;
