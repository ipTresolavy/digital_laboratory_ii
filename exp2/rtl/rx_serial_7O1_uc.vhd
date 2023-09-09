library ieee;
use ieee.std_logic_1164.all;

entity rx_serial_7O1_uc is 
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
end entity;

architecture rx_serial_uc_arch of rx_serial_7O1_uc is

    type tipo_estado is (inicial, preparacao, espera, amostra, checagem, final);
    signal Eatual: tipo_estado;  -- estado atual
    signal Eprox:  tipo_estado;  -- proximo estado

begin

  -- memoria de estado
  process (reset, clock)
  begin
      if reset = '1' then
          Eatual <= inicial;
      elsif clock'event and clock = '1' then
          Eatual <= Eprox; 
      end if;
  end process;

  -- logica de proximo estado
  process (start_bit, stop_bit, tick, fim, Eatual) 
  begin

    case Eatual is

      when inicial =>      if start_bit='0' then Eprox <= preparacao;
                           else                  Eprox <= inicial;
                           end if;

      when preparacao =>   Eprox <= espera;

      when espera =>   if tick='1'   then Eprox <= amostra;
                       elsif fim='0' then Eprox <= espera;
                       else               Eprox <= final;
                       end if;

      when amostra =>  if fim='0' then Eprox <= espera;
                       else            Eprox <= checagem;
                       end if;

      when checagem => if stop_bit='1' then Eprox <= final;
                       else Eprox <= inicial;
                       end if;

      when final =>    Eprox <= inicial;

      when others =>   Eprox <= inicial;

    end case;

  end process;

  -- logica de saida (Moore)
  with Eatual select
      zera <= '1' when preparacao, '0' when others;

  with Eatual select
      desloca <= '1' when amostra, '0' when others;

  with Eatual select
      conta <= '1' when amostra, '0' when others;

  with Eatual select
      pronto <= '1' when final, '0' when others;

  with Eatual select
      db_estado <= "0000" when inicial,
                   "0001" when preparacao, 
                   "0010" when espera, 
                   "0100" when amostra, 
                   "1000" when checagem, 
                   "1111" when final,    -- Final
                   "1110" when others;   -- Erro

end architecture rx_serial_uc_arch;
