library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_d is
  generic
  (
    WIDTH : natural := 8
  );
  port
  (
    clock         : in  std_logic;
    reset         : in  std_logic;
    enable        : in  std_logic;
    data_in       : in  std_logic_vector(WIDTH-1 downto 0);
    data_out      : out std_logic_vector(WIDTH-1 downto 0)
  );
end entity register_d;

architecture behavioral of register_d is
begin

  register_procedure: process(clock, reset) is
  begin
    if(reset = '1') then
      data_out <= (others => '0');
    elsif (enable = '1' and rising_edge(clock)) then
      data_out <= data_in;
    end if;
  end process;

end architecture behavioral;
