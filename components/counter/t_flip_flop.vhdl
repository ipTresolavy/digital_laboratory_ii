library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity t_flip_flop is
  port
  (
    clock : in  std_logic;
    reset : in  std_logic;
    en    : in  std_logic;
    q_in  : in  std_logic;
    load  : in  std_logic; 
    q     : out std_logic
  );
end entity t_flip_flop;

architecture behavioral of t_flip_flop is

  signal s_q : std_logic;

begin
  
  behavior: process(clock, reset)
  begin
    if reset  = '1' then
      s_q <= '0'; 
    elsif rising_edge(clock) then
      if load = '1' then
        s_q <= q_in; 
      else
        s_q <= s_q xor en; 
      end if;
    end if;
  end process behavior;
  
  q <= s_q;
  
end architecture behavioral;
