library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity baud_gen is
  port
  (
    clock   : in  std_logic;
    reset   : in  std_logic;
  -- divisor calculation:
  -- divisor = clock freq. / (16 * baud rate) - 1
  -- (rounded up)
    divisor : in  std_logic_vector(10 downto 0);
    tick    : out std_logic
  );
end entity baud_gen;

architecture behavioral of baud_gen is

  signal r_reg, r_next : std_logic_vector(10 downto 0);

begin
  
  reg: process(clock, reset)
  begin
    if reset = '1' then
      r_reg <= (others => '0'); 
    elsif rising_edge(clock) then
      r_reg <= r_next; 
    end if;
  end process reg;

  r_next <= (others => '0') when r_reg = divisor else
            std_logic_vector(to_unsigned(to_integer(unsigned(r_reg)) + 1, r_next'LENGTH));

  tick <= '1' when r_reg = "00000000001" else
          '0';

end architecture behavioral;
