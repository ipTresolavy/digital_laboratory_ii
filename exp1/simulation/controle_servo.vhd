library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controle_servo is
  port (
    clock     : in  std_logic;
    reset     : in  std_logic;
    posicao   : in  std_logic_vector(2 downto 0);
    controle  : out std_logic
  );
end entity controle_servo;

architecture rtl of controle_servo is

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
  end component;

  begin

    pwm_circuit: circuito_pwm
    port map
    (
      clock   => clock,
      reset   => reset,
      largura => posicao,
      pwm     => controle
    );

end architecture rtl;
