library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity interface_hcsr04 is
  port (
    clock : in std_logic;
    reset : in std_logic;
    medir : in std_logic;
    echo    : in std_logic;
    trigger : out std_logic;
    medida : out std_logic_vector(11 downto 0); -- 3 digitos BCD
    pronto : out std_logic;
    db_estado : out std_logic_vector(3 downto 0) -- estado da UC
  );
end entity interface_hcsr04;

architecture structural of interface_hcsr04 is

  component interface_hcsr04_uc is
    port (
      clock          : in  std_logic;
      reset          : in  std_logic;
      medir          : in  std_logic;
      echo           : in  std_logic;
      pulse_sent     : in  std_logic;
      generate_pulse : out std_logic;
      pronto         : out std_logic;
      db_estado      : out std_logic_vector(3 downto 0) -- estado da UC
    );
  end component interface_hcsr04_uc;

  signal s_pulse_sent     : std_logic;
  signal s_generate_pulse : std_logic;

begin

  uc: interface_hcsr04_uc
  port map
  (
      clock          => clock,
      reset          => reset,
      medir          => medir,
      echo           => echo,
      pulse_sent     => s_pulse_sent,
      generate_pulse => s_generate_pulse,
      pronto         => pronto,
      db_estado      => db_estado
  );

end architecture structural;
