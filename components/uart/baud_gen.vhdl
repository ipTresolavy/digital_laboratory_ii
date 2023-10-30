library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity baud_gen is
  port
  (
    clock   : in  std_logic;
    reset   : in  std_logic;
  -- divisor calculation:
  -- divisor = clock freq. / (16 * baud rate)
  -- (rounded up)
    divisor : in  std_logic_vector(10 downto 0);
    tick    : out std_logic
  );
end entity baud_gen;

architecture behavioral of baud_gen is

  component sync_par_counter is
    generic
    (
      constant MODU : natural := 16
    );
    port
    (
      clock  : in  std_logic;
      reset  : in  std_logic;
      cnt_en : in  std_logic;
      q      : out std_logic_vector(natural(ceil(log2(real(MODU))))-1 downto 0)
    );
  end component sync_par_counter;

  signal s_reset : std_logic;
  signal count : std_logic_vector(10 downto 0);

begin

  s_reset <= '1' when reset = '1' else
             '1' when count = divisor else
             '0';
  main_counter: sync_par_counter
  generic map
  (
    MODU => 2**11
  )
  port map
  (
    clock => clock,
    reset => s_reset,
    cnt_en => '1',
    q => count
  );

  tick <= '1' when count = "00000000001" else
          '0';

end architecture behavioral;
