library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exp4_trena_top is
  port (
    reset           : in std_logic;
    clock           : in std_logic;
    mensurar        : in std_logic;
    echo            : in std_logic;
    trigger         : out std_logic;
    saida_serial    : out std_logic;
    medida0         : out std_logic_vector (6 downto 0);
    medida1         : out std_logic_vector (6 downto 0);
    medida2         : out std_logic_vector (6 downto 0);
    pronto          : out std_logic;
    db_mensurar     : out std_logic;
    db_saida_serial : out std_logic;
    db_trigger      : out std_logic;
    db_echo         : out std_logic;
    db_estado       : out std_logic_vector (6 downto 0)
  );
end entity exp4_trena_top;

architecture structural of exp4_trena_top is
  component exp4_trena is
    port (
      clock         : in std_logic;
      reset         : in std_logic;
      mensurar      : in std_logic;
      echo          : in std_logic;
      trigger       : out std_logic;
      saida_serial  : out std_logic;
      medida0       : out std_logic_vector (6 downto 0);
      medida1       : out std_logic_vector (6 downto 0);
      medida2       : out std_logic_vector (6 downto 0);
      pronto        : out std_logic;
      db_estado     : out std_logic_vector (6 downto 0)
    );
  end component exp4_trena;

  signal s_saida_serial : std_logic;
  signal s_trigger : std_logic;

begin

  exp4: exp4_trena
  port map
  (
      clock         => clock,
      reset         => reset,
      mensurar      => mensurar,
      echo          => echo,
      trigger       => s_trigger,
      saida_serial  => s_saida_serial,
      medida0       => medida0,
      medida1       => medida1,
      medida2       => medida2,
      pronto        => pronto,
      db_estado     => db_estado
  );
  trigger <= s_trigger;
  saida_serial <= s_saida_serial;


  db_mensurar <= mensurar;
  db_saida_serial <= s_saida_serial;
  db_trigger <= s_trigger;
  db_echo <= echo;

end architecture structural;
